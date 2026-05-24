import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator

from routers import auth, invitados, presupuesto

app = FastAPI(
    title="Weddy API",
    description="Servicio proveedor para la plataforma de gestión de bodas Weddy.",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Expone /metrics en formato Prometheus.
Instrumentator().instrument(app).expose(app, tags=["Observability"])

# Trazas OTel hacia Jaeger — solo se activan si JAEGER_ENABLED=true.
if os.getenv("JAEGER_ENABLED", "false").lower() == "true":
    from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
    from telemetry.tracing import setup_tracing
    setup_tracing()
    FastAPIInstrumentor.instrument_app(app)

app.include_router(auth.router)
app.include_router(invitados.router)
app.include_router(presupuesto.router)


@app.get("/health", tags=["Health"])
def health_check():
    """Endpoint de salud para verificar que el servicio está activo."""
    return {"status": "ok", "service": "weddy-api"}
