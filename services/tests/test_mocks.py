# Pruebas autónomas con mocks — simulan dependencias sin tocar estado real
from unittest.mock import MagicMock, patch


# ─── Auth / JWT ────────────────────────────────────────────────────────────────

def test_login_llama_bcrypt_checkpw(client):
    """Verifica que el login invoca bcrypt.checkpw para validar la contraseña."""
    with patch("routers.auth.bcrypt.checkpw", return_value=True) as mock_check:
        client.post("/auth/login", json={"username": "admin", "password": "cualquier"})
        mock_check.assert_called_once()


def test_login_falla_sin_llamar_create_token_si_checkpw_es_false(client):
    """Si bcrypt.checkpw retorna False, create_access_token no debe llamarse."""
    with patch("routers.auth.bcrypt.checkpw", return_value=False):
        with patch("routers.auth.create_access_token") as mock_token:
            response = client.post(
                "/auth/login", json={"username": "admin", "password": "mal"}
            )
            assert response.status_code == 401
            mock_token.assert_not_called()


def test_login_usa_token_generado_por_create_access_token(client):
    """El token retornado en la respuesta debe ser el que genera create_access_token."""
    token_falso = "header.payload.signature"
    with patch("routers.auth.bcrypt.checkpw", return_value=True):
        with patch("routers.auth.create_access_token", return_value=token_falso):
            response = client.post(
                "/auth/login", json={"username": "admin", "password": "any"}
            )
            assert response.status_code == 200
            assert response.json()["access_token"] == token_falso


# ─── Invitados — mock del store ────────────────────────────────────────────────

def test_crear_invitado_llama_next_invitado_id(client, auth_headers):
    """Verifica que crear un invitado incrementa el contador del store."""
    import data.store as store
    original = store.next_invitado_id

    llamadas = []

    def mock_next_id():
        llamadas.append(1)
        return original()

    with patch("routers.invitados.store.next_invitado_id", side_effect=mock_next_id):
        client.post(
            "/invitados/",
            json={"nombre": "Mock Test", "estado": "pendiente"},
            headers=auth_headers,
        )
    assert len(llamadas) == 1


def test_listar_invitados_retorna_datos_del_store(client, auth_headers):
    """Listar invitados debe reflejar exactamente lo que hay en store.invitados."""
    import data.store as store

    store.invitados.clear()
    store._invitado_counter = 0
    store.invitados[1] = {"id": 1, "nombre": "Mock A", "email": None, "mesa": None, "estado": "pendiente"}
    store.invitados[2] = {"id": 2, "nombre": "Mock B", "email": None, "mesa": None, "estado": "confirmado"}

    response = client.get("/invitados/")
    nombres = [i["nombre"] for i in response.json()]
    assert "Mock A" in nombres
    assert "Mock B" in nombres


def test_eliminar_invitado_elimina_del_store(client, auth_headers):
    """DELETE debe remover la clave del diccionario en store."""
    import data.store as store

    store.invitados[999] = {
        "id": 999, "nombre": "Para Mock Delete",
        "email": None, "mesa": None, "estado": "pendiente",
    }
    response = client.delete("/invitados/999")
    assert response.status_code == 204
    assert 999 not in store.invitados


# ─── Presupuesto — mock del cálculo ───────────────────────────────────────────

def test_presupuesto_usa_datos_del_store(client):
    """El resumen del presupuesto debe calcularse con los valores del store."""
    import data.store as store

    store.presupuesto["presupuesto_total"] = 9999.0
    store.presupuesto["costo_por_invitado_confirmado"] = 111.0

    response = client.get("/presupuesto/")
    data = response.json()
    assert data["presupuesto_total"] == 9999.0
    assert data["costo_por_invitado_confirmado"] == 111.0


def test_jwt_decode_invalido_retorna_none():
    """decode_access_token debe retornar None para tokens malformados."""
    from auth.jwt import decode_access_token
    assert decode_access_token("token.invalido.xxx") is None


def test_jwt_decode_valido_retorna_subject():
    """decode_access_token debe retornar el subject del token generado."""
    from auth.jwt import create_access_token, decode_access_token
    token = create_access_token("usuario_test")
    assert decode_access_token(token) == "usuario_test"


def test_get_current_user_lanza_401_si_decode_retorna_none(client):
    """Si decode_access_token retorna None, el endpoint protegido debe retornar 401."""
    with patch("auth.dependencies.decode_access_token", return_value=None):
        response = client.post(
            "/invitados/",
            json={"nombre": "Fail", "estado": "pendiente"},
            headers={"Authorization": "Bearer cualquier.token.aqui"},
        )
    assert response.status_code == 401
