# Tests unitarios del módulo de autenticación JWT


def test_login_exitoso(client):
    response = client.post(
        "/auth/login",
        json={"username": "admin", "password": "weddy2024"},
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["access_token"]


def test_login_credenciales_incorrectas(client):
    response = client.post(
        "/auth/login",
        json={"username": "admin", "password": "password_incorrecto"},
    )
    assert response.status_code == 401


def test_login_usuario_inexistente(client):
    response = client.post(
        "/auth/login",
        json={"username": "usuario_fantasma", "password": "cualquier"},
    )
    assert response.status_code == 401


def test_token_tiene_formato_jwt(client):
    response = client.post(
        "/auth/login",
        json={"username": "admin", "password": "weddy2024"},
    )
    token = response.json()["access_token"]
    partes = token.split(".")
    assert len(partes) == 3, "Un JWT debe tener exactamente 3 partes separadas por '.'"


def test_acceso_sin_token(client):
    response = client.post(
        "/invitados/",
        json={"nombre": "Sin Token", "estado": "pendiente"},
    )
    assert response.status_code in (401, 403)


def test_acceso_con_token_invalido(client):
    headers = {"Authorization": "Bearer token.falso.invalido"}
    response = client.post(
        "/invitados/",
        json={"nombre": "Token Falso", "estado": "pendiente"},
        headers=headers,
    )
    assert response.status_code in (401, 403)
