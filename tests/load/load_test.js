// Prueba de carga con k6: simula tráfico concurrente sobre la API Weddy
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = 'http://localhost:8000';

export const options = {
  stages: [
    { duration: '30s', target: 10 },
    { duration: '1m', target: 10 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

export function setup() {
  const res = http.post(
    `${BASE_URL}/auth/login`,
    JSON.stringify({ username: 'admin', password: 'weddy2024' }),
    { headers: { 'Content-Type': 'application/json' } }
  );

  const ok = check(res, {
    'login exitoso en setup': (r) => r.status === 200,
    'token presente en setup': (r) => r.json('access_token') !== undefined,
  });

  if (!ok) {
    console.error(`Setup falló: status=${res.status} body=${res.body}`);
  }

  return { token: res.json('access_token') };
}

export default function (data) {
  const authHeaders = {
    headers: {
      Authorization: `Bearer ${data.token}`,
      'Content-Type': 'application/json',
    },
  };

  // Escenario 1: listar invitados sin auth
  const resInvitados = http.get(`${BASE_URL}/invitados/`);
  const okInvitados = check(resInvitados, {
    'GET /invitados/ → 200': (r) => r.status === 200,
    'respuesta es array': (r) => Array.isArray(r.json()),
  });
  if (!okInvitados) {
    console.error(`GET /invitados/ falló: status=${resInvitados.status}`);
  }

  // Escenario 2: obtener presupuesto sin auth
  const resPresupuesto = http.get(`${BASE_URL}/presupuesto/`);
  const okPresupuesto = check(resPresupuesto, {
    'GET /presupuesto/ → 200': (r) => r.status === 200,
    'tiene presupuesto_total': (r) => r.json('presupuesto_total') !== undefined,
  });
  if (!okPresupuesto) {
    console.error(`GET /presupuesto/ falló: status=${resPresupuesto.status}`);
  }

  // Escenario 3: crear invitado con auth
  const ts = Date.now();
  const resCrear = http.post(
    `${BASE_URL}/invitados/`,
    JSON.stringify({
      nombre: `Invitado K6 ${ts}`,
      email: `k6_${ts}@loadtest.com`,
      estado: 'pendiente',
    }),
    authHeaders
  );
  const okCrear = check(resCrear, {
    'POST /invitados/ → 201': (r) => r.status === 201,
    'invitado tiene id': (r) => r.json('id') !== undefined,
  });
  if (!okCrear) {
    console.error(`POST /invitados/ falló: status=${resCrear.status} body=${resCrear.body}`);
  }

  sleep(1);
}
