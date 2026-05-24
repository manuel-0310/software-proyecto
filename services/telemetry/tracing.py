# Configuración de OpenTelemetry para enviar trazas a Jaeger via OTLP HTTP.
# Se usa el exportador HTTP (puerto 4318) para compatibilidad con
# jaegertracing/all-in-one que tiene el OTLP collector integrado.

import os

from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor


def setup_tracing() -> None:
    """Inicializa el TracerProvider con exportación OTLP HTTP hacia Jaeger."""
    endpoint = os.getenv(
        "OTEL_EXPORTER_OTLP_ENDPOINT",
        "http://localhost:4318/v1/traces",
    )

    resource = Resource.create({"service.name": "weddy-api"})
    provider = TracerProvider(resource=resource)
    exporter = OTLPSpanExporter(endpoint=endpoint)
    provider.add_span_processor(BatchSpanProcessor(exporter))
    trace.set_tracer_provider(provider)
