# Tests del módulo de presupuesto (configuración y cálculo del resumen)


def test_obtener_presupuesto_sin_auth(client):
    response = client.get("/presupuesto/")
    assert response.status_code == 200


def test_presupuesto_tiene_campos_requeridos(client):
    response = client.get("/presupuesto/")
    data = response.json()
    assert "presupuesto_total" in data
    assert "costo_total" in data
    assert "saldo_restante" in data


def test_configurar_presupuesto_con_auth(client, auth_headers):
    response = client.post(
        "/presupuesto/configurar",
        json={"presupuesto_total": 15000.0, "costo_por_invitado_confirmado": 75.0},
        headers=auth_headers,
    )
    assert response.status_code == 200
    data = response.json()
    assert data["presupuesto_total"] == 15000.0
    assert data["costo_por_invitado_confirmado"] == 75.0


def test_configurar_presupuesto_sin_auth(client):
    response = client.post(
        "/presupuesto/configurar",
        json={"presupuesto_total": 15000.0, "costo_por_invitado_confirmado": 75.0},
    )
    assert response.status_code in (401, 403)


def test_presupuesto_total_negativo_es_invalido(client, auth_headers):
    # El modelo usa Field(gt=0), por lo que un valor negativo debe retornar 422
    response = client.post(
        "/presupuesto/configurar",
        json={"presupuesto_total": -5000.0, "costo_por_invitado_confirmado": 50.0},
        headers=auth_headers,
    )
    assert response.status_code in (400, 422)


def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
