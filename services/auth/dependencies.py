from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from auth.jwt import decode_access_token

_bearer = HTTPBearer()


def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(_bearer)) -> str:
    """
    Dependencia FastAPI para proteger endpoints.
    Extrae y valida el Bearer token del header Authorization.
    Retorna el username del token si es válido.
    """
    username = decode_access_token(credentials.credentials)
    if username is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido o expirado",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return username
