from fastapi import APIRouter, Depends, HTTPException, status
from typing import Annotated, List

from auth.dependencies import get_current_user
from models.invitado import InvitadoCreate, InvitadoUpdate, InvitadoResponse
import data.store as store

router = APIRouter(prefix="/invitados", tags=["Invitados"])

_NOT_FOUND = "Invitado no encontrado"


@router.get("/", response_model=List[InvitadoResponse])
def listar_invitados():
    """Retorna la lista completa de invitados."""
    return list(store.invitados.values())


@router.get("/{invitado_id}", response_model=InvitadoResponse)
def obtener_invitado(invitado_id: int):
    """Retorna un invitado por su ID."""
    invitado = store.invitados.get(invitado_id)
    if not invitado:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=_NOT_FOUND)
    return invitado


@router.post("/", response_model=InvitadoResponse, status_code=status.HTTP_201_CREATED)
def crear_invitado(invitado: InvitadoCreate, _: Annotated[str, Depends(get_current_user)]):
    """Crea un nuevo invitado. Requiere Bearer token JWT en el header Authorization."""
    nuevo_id = store.next_invitado_id()
    nuevo_invitado = {"id": nuevo_id, **invitado.model_dump()}
    store.invitados[nuevo_id] = nuevo_invitado
    return nuevo_invitado


@router.patch("/{invitado_id}/estado", response_model=InvitadoResponse)
def actualizar_estado(invitado_id: int, body: InvitadoUpdate):
    """Actualiza el estado de un invitado (pendiente / confirmado / cancelado)."""
    invitado = store.invitados.get(invitado_id)
    if not invitado:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=_NOT_FOUND)
    invitado["estado"] = body.estado
    return invitado


@router.delete("/{invitado_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_invitado(invitado_id: int):
    """Elimina un invitado por su ID."""
    if invitado_id not in store.invitados:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=_NOT_FOUND)
    del store.invitados[invitado_id]
