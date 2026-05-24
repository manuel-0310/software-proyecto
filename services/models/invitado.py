from pydantic import BaseModel
from typing import Optional
from enum import Enum


class EstadoInvitado(str, Enum):
    pendiente = "pendiente"
    confirmado = "confirmado"
    cancelado = "cancelado"


class InvitadoCreate(BaseModel):
    nombre: str
    email: Optional[str] = None
    mesa: Optional[int] = None
    estado: EstadoInvitado = EstadoInvitado.pendiente


class InvitadoUpdate(BaseModel):
    estado: EstadoInvitado


class InvitadoResponse(BaseModel):
    id: int
    nombre: str
    email: Optional[str] = None
    mesa: Optional[int] = None
    estado: EstadoInvitado
