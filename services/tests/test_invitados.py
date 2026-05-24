# Tests de CRUD completo para el recurso invitados


def test_listar_invitados_sin_auth(client):
    response = client.get("/invitados/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_crear_invitado_con_auth(client, auth_headers):
    response = client.post(
        "/invitados/",
        json={"nombre": "Juan Test", "email": "juan@test.com", "estado": "pendiente"},
        headers=auth_headers,
    )
    assert response.status_code in (200, 201)
    data = response.json()
    assert "id" in data
    assert data["nombre"] == "Juan Test"


def test_crear_invitado_sin_auth(client):
    response = client.post(
        "/invitados/",
        json={"nombre": "Sin Auth", "email": "noauth@test.com", "estado": "pendiente"},
    )
    assert response.status_code in (401, 403)


def test_crear_invitado_datos_invalidos(client, auth_headers):
    # nombre es requerido; enviarlo sin él debe retornar 422
    response = client.post(
        "/invitados/",
        json={"email": "sin_nombre@test.com", "estado": "pendiente"},
        headers=auth_headers,
    )
    assert response.status_code == 422


def test_actualizar_invitado(client, auth_headers):
    crear = client.post(
        "/invitados/",
        json={"nombre": "Para Actualizar", "estado": "pendiente"},
        headers=auth_headers,
    )
    invitado_id = crear.json()["id"]

    response = client.patch(
        f"/invitados/{invitado_id}/estado",
        json={"estado": "confirmado"},
    )
    assert response.status_code == 200
    assert response.json()["estado"] == "confirmado"


def test_eliminar_invitado(client, auth_headers):
    crear = client.post(
        "/invitados/",
        json={"nombre": "Para Eliminar", "estado": "pendiente"},
        headers=auth_headers,
    )
    invitado_id = crear.json()["id"]

    response = client.delete(f"/invitados/{invitado_id}")
    assert response.status_code in (200, 204)


def test_eliminar_invitado_inexistente(client):
    response = client.delete("/invitados/99999")
    assert response.status_code == 404


def test_invitado_creado_aparece_en_lista(client, auth_headers):
    client.post(
        "/invitados/",
        json={"nombre": "Visible en Lista", "email": "lista@test.com", "estado": "pendiente"},
        headers=auth_headers,
    )

    lista = client.get("/invitados/").json()
    nombres = [i["nombre"] for i in lista]
    assert "Visible en Lista" in nombres
