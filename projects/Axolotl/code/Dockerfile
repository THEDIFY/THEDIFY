# ════════════════════════════════════════════════════════════════
# Axolotl - Production Dockerfile
# Python 3.11 | GPU Support | Multi-stage build
# ════════════════════════════════════════════════════════════════

# ────────────────────────────────────────────────────────────────
# Stage 1: Builder
# ────────────────────────────────────────────────────────────────
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as builder

ENV DEBIAN_FRONTEND=noninteractive

# Install Python and build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3-pip \
    gcc \
    g++ \
    make \
    ffmpeg \
    libsm6 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir --user -r requirements.txt

# ────────────────────────────────────────────────────────────────
# Stage 2: Runtime
# ────────────────────────────────────────────────────────────────
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Metadata
LABEL maintainer="Santiago <rasanti2008@gmail.com>"
LABEL description="Axolotl - AI Football Analysis Platform"
LABEL version="0.8.0"

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3-pip \
    ffmpeg \
    libsm6 \
    libxext6 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 axolotl

WORKDIR /app

# Copy Python dependencies from builder
COPY --from=builder /root/.local /home/axolotl/.local

# Copy application code
COPY --chown=axolotl:axolotl . .

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH=/home/axolotl/.local/bin:$PATH \
    CUDA_VISIBLE_DEVICES=0

# Switch to non-root user
USER axolotl

# Expose ports
EXPOSE 8000 5555

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python3 -c "import requests; requests.get('http://localhost:8000/health')"

# Run application
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
