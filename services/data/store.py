from typing import Dict, Any

# Almacenamiento en memoria para invitados
# Clave: id (int), Valor: dict con los datos del invitado
invitados: Dict[int, Any] = {}
_invitado_counter: int = 0

# Configuración del presupuesto
presupuesto: Dict[str, Any] = {
    "presupuesto_total": 20000.0,
    "costo_por_invitado_confirmado": 50.0,
}


def next_invitado_id() -> int:
    global _invitado_counter
    _invitado_counter += 1
    return _invitado_counter
