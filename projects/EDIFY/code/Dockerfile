# ════════════════════════════════════════════════════════════════
# EDIFY - Production Dockerfile
# Python 3.11 | Multi-stage build for optimized image size
# ════════════════════════════════════════════════════════════════

# ────────────────────────────────────────────────────────────────
# Stage 1: Builder
# ────────────────────────────────────────────────────────────────
FROM python:3.11-slim as builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ────────────────────────────────────────────────────────────────
# Stage 2: Runtime
# ────────────────────────────────────────────────────────────────
FROM python:3.11-slim

# Metadata
LABEL maintainer="Santiago <rasanti2008@gmail.com>"
LABEL description="EDIFY - Enterprise AI Education Platform"
LABEL version="1.2.0"

# Create non-root user
RUN useradd -m -u 1000 edify

WORKDIR /app

# Copy Python dependencies from builder
COPY --from=builder /root/.local /home/edify/.local

# Copy application code
COPY --chown=edify:edify . .

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH=/home/edify/.local/bin:$PATH

# Switch to non-root user
USER edify

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')"

# Run application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
