// Pruebas de GUI — flujo completo de invitados a través de la API
describe('Weddy API — Flujo de Invitados', () => {
  let token;
  let invitadoId;

  before(() => {
    cy.loginWeddy().then((t) => {
      token = t;
    });
  });

  it('Health check retorna status ok', () => {
    cy.request('/health').then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body.status).to.eq('ok');
    });
  });

  it('GET /invitados/ retorna lista (público)', () => {
    cy.request('/invitados/').then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body).to.be.an('array');
    });
  });

  it('POST /invitados/ sin token retorna 401 o 403', () => {
    cy.request({
      method: 'POST',
      url: '/invitados/',
      body: { nombre: 'Sin Token', estado: 'pendiente' },
      headers: { 'Content-Type': 'application/json' },
      failOnStatusCode: false,
    }).then((response) => {
      expect(response.status).to.be.oneOf([401, 403]);
    });
  });

  it('POST /invitados/ con token crea invitado correctamente', () => {
    cy.request({
      method: 'POST',
      url: '/invitados/',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: { nombre: 'Cypress GUI Test', email: 'cypress@test.com', estado: 'pendiente' },
    }).then((response) => {
      expect(response.status).to.be.oneOf([200, 201]);
      expect(response.body).to.have.property('id');
      expect(response.body.nombre).to.eq('Cypress GUI Test');
      invitadoId = response.body.id;
    });
  });

  it('PATCH /invitados/{id}/estado actualiza estado a confirmado', () => {
    cy.request({
      method: 'PATCH',
      url: `/invitados/${invitadoId}/estado`,
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: { estado: 'confirmado' },
    }).then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body.estado).to.eq('confirmado');
    });
  });

  it('GET /presupuesto/ refleja el costo del invitado confirmado', () => {
    cy.request('/presupuesto/').then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body.total_invitados_confirmados).to.be.at.least(1);
      expect(response.body.costo_total).to.be.greaterThan(0);
    });
  });

  it('DELETE /invitados/{id} elimina el invitado creado', () => {
    cy.request({
      method: 'DELETE',
      url: `/invitados/${invitadoId}`,
      headers: { Authorization: `Bearer ${token}` },
    }).then((response) => {
      expect(response.status).to.be.oneOf([200, 204]);
    });
  });

});
