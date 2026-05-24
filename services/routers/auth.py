import bcrypt
from fastapi import APIRouter, HTTPException, status

from auth.jwt import create_access_token
from models.auth import LoginRequest, TokenResponse

router = APIRouter(prefix="/auth", tags=["Auth"])

# Usuario hardcoded para demo. En producción usar una base de datos.
# Credenciales: username=admin / password=weddy2024
_USERS: dict[str, bytes] = {
    "admin": bcrypt.hashpw(b"weddy2024", bcrypt.gensalt()),
}


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest):
    """
    Autentica al usuario y retorna un JWT Bearer token.

    Credenciales de prueba:
    - username: admin
    - password: weddy2024
    """
    hashed = _USERS.get(body.username)
    if not hashed or not bcrypt.checkpw(body.password.encode(), hashed):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario o contraseña incorrectos",
        )
    token = create_access_token(subject=body.username)
    return TokenResponse(access_token=token)
