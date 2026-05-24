"""
Utilidades JWT para Weddy API.

Credenciales de prueba (hardcoded para demo):
  usuario:   admin
  password:  weddy2024

Para obtener un token de prueba con curl:
  curl -X POST http://localhost:8000/auth/login \
       -H "Content-Type: application/json" \
       -d '{"username": "admin", "password": "weddy2024"}'

Luego úsalo en endpoints protegidos:
  curl -X POST http://localhost:8000/invitados/ \
       -H "Authorization: Bearer <token>" \
       -H "Content-Type: application/json" \
       -d '{"nombre": "María López"}'

IMPORTANTE: En producción, mover SECRET_KEY a una variable de entorno.
"""

import os
from datetime import datetime, timedelta, timezone
from typing import Optional

from jose import JWTError, jwt

SECRET_KEY = os.environ.get("SECRET_KEY", "weddy-dev-secret-key-cambiar-en-produccion")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 180


def create_access_token(subject: str) -> str:
    """Genera un JWT firmado con el subject (username) y expiración definida."""
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    payload = {"sub": subject, "exp": expire}
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def decode_access_token(token: str) -> Optional[str]:
    """Verifica y decodifica un JWT. Retorna el subject o None si el token es inválido/expirado."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload.get("sub")
    except JWTError:
        return None
