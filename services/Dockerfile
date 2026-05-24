# Conteneriza el backend FastAPI de Weddy con usuario no-root y health check
FROM python:3.11-slim

LABEL maintainer="manuel-0310" \
      project="weddy-backend" \
      version="2.0.0"

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Instala dependencias y crea usuario no-root en una sola capa
COPY requirements.lock .
RUN pip install --no-cache-dir --only-binary :all: --require-hashes -r requirements.lock \
    && addgroup --system appgroup \
    && adduser --system --ingroup appgroup appuser

COPY main.py tracing.py ./
COPY auth/ ./auth/
COPY data/ ./data/
COPY models/ ./models/
COPY routers/ ./routers/
COPY telemetry/ ./telemetry/

# Transfiere propiedad de los archivos al usuario sin privilegios
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
