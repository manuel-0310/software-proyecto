# Fixtures compartidos para todos los tests pytest del backend Weddy
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import pytest
from fastapi.testclient import TestClient

import data.store as store
from main import app


@pytest.fixture(autouse=True)
def reset_store():
    store.invitados.clear()
    store._invitado_counter = 0
    store.presupuesto["presupuesto_total"] = 20000.0
    store.presupuesto["costo_por_invitado_confirmado"] = 50.0
    yield


@pytest.fixture
def client():
    return TestClient(app)


@pytest.fixture
def auth_token(client):
    response = client.post(
        "/auth/login",
        json={"username": "admin", "password": "weddy2024"},
    )
    return response.json()["access_token"]


@pytest.fixture
def auth_headers(auth_token):
    return {"Authorization": f"Bearer {auth_token}"}
