from pydantic import BaseModel, Field


class PresupuestoConfig(BaseModel):
    presupuesto_total: float = Field(gt=0, description="Presupuesto total de la boda")
    costo_por_invitado_confirmado: float = Field(gt=0, description="Costo fijo por cada invitado confirmado")


class PresupuestoResumen(BaseModel):
    presupuesto_total: float
    costo_por_invitado_confirmado: float
    total_invitados_confirmados: int
    costo_invitados: float
    costo_total: float
    saldo_restante: float
    dentro_del_presupuesto: bool
    porcentaje_utilizado: float
