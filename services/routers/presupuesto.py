from fastapi import APIRouter, Depends

from auth.dependencies import get_current_user
from models.presupuesto import PresupuestoConfig, PresupuestoResumen
import data.store as store

router = APIRouter(prefix="/presupuesto", tags=["Presupuesto"])


def _calcular_resumen() -> PresupuestoResumen:
    """Calcula el resumen del presupuesto a partir del estado actual en memoria."""
    confirmados = [i for i in store.invitados.values() if i["estado"] == "confirmado"]
    total_confirmados = len(confirmados)
    costo_invitados = total_confirmados * store.presupuesto["costo_por_invitado_confirmado"]
    costo_total = costo_invitados
    presupuesto_total = store.presupuesto["presupuesto_total"]
    saldo_restante = presupuesto_total - costo_total
    porcentaje = round((costo_total / presupuesto_total) * 100, 2) if presupuesto_total > 0 else 0.0

    return PresupuestoResumen(
        presupuesto_total=presupuesto_total,
        costo_por_invitado_confirmado=store.presupuesto["costo_por_invitado_confirmado"],
        total_invitados_confirmados=total_confirmados,
        costo_invitados=costo_invitados,
        costo_total=costo_total,
        saldo_restante=saldo_restante,
        dentro_del_presupuesto=saldo_restante >= 0,
        porcentaje_utilizado=porcentaje,
    )


@router.get("/", response_model=PresupuestoResumen)
def obtener_presupuesto():
    """Retorna el resumen actual del presupuesto calculado en tiempo real."""
    return _calcular_resumen()


@router.post("/configurar", response_model=PresupuestoResumen)
def configurar_presupuesto(config: PresupuestoConfig, _: str = Depends(get_current_user)):
    """Actualiza la configuración del presupuesto. Requiere Bearer token JWT en el header Authorization."""
    store.presupuesto["presupuesto_total"] = config.presupuesto_total
    store.presupuesto["costo_por_invitado_confirmado"] = config.costo_por_invitado_confirmado
    return _calcular_resumen()
