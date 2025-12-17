# ════════════════════════════════════════════════════════════════
# GUIRA - Production Dockerfile
# Python 3.11 | Geospatial Support | Multi-stage build
# ════════════════════════════════════════════════════════════════

# ────────────────────────────────────────────────────────────────
# Stage 1: Builder with GDAL
# ────────────────────────────────────────────────────────────────
FROM osgeo/gdal:ubuntu-small-3.8.0 as builder

ENV DEBIAN_FRONTEND=noninteractive

# Install Python and build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3-pip \
    gcc \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir --user -r requirements.txt

# ────────────────────────────────────────────────────────────────
# Stage 2: Runtime
# ────────────────────────────────────────────────────────────────
FROM osgeo/gdal:ubuntu-small-3.8.0

# Metadata
LABEL maintainer="Santiago <rasanti2008@gmail.com>"
LABEL description="GUIRA - Fire Prevention & Disaster AI"
LABEL version="0.4.0"

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3-pip \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 guira

WORKDIR /app

# Copy Python dependencies from builder
COPY --from=builder /root/.local /home/guira/.local

# Copy application code
COPY --chown=guira:guira . .

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH=/home/guira/.local/bin:$PATH \
    GDAL_DATA=/usr/share/gdal \
    PROJ_LIB=/usr/share/proj

# Switch to non-root user
USER guira

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python3 -c "import requests; requests.get('http://localhost:8000/health')"

# Run application
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
