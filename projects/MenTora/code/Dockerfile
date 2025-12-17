# ════════════════════════════════════════════════════════════════
# MenTora - Production Dockerfile
# Python 3.11 | Multi-stage build for optimized size
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

# Copy and install Python dependencies
COPY backend/requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ────────────────────────────────────────────────────────────────
# Stage 2: Frontend Builder
# ────────────────────────────────────────────────────────────────
FROM node:20-alpine as frontend-builder

WORKDIR /frontend

# Copy package files
COPY frontend/package*.json ./
RUN npm ci --only=production

# Copy frontend code and build
COPY frontend/ ./
RUN npm run build

# ────────────────────────────────────────────────────────────────
# Stage 3: Runtime
# ────────────────────────────────────────────────────────────────
FROM python:3.11-slim

# Metadata
LABEL maintainer="Santiago <rasanti2008@gmail.com>"
LABEL description="MenTora - EdTech for AI-Ready World"
LABEL version="1.0.0"

# Install nginx for serving frontend
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 mentora

# Backend setup
WORKDIR /app/backend
COPY --from=builder /root/.local /home/mentora/.local
COPY --chown=mentora:mentora backend/ ./

# Frontend setup
WORKDIR /app/frontend
COPY --from=frontend-builder /frontend/dist ./

# Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH=/home/mentora/.local/bin:$PATH

# Switch to non-root user
USER mentora

WORKDIR /app

# Expose ports
EXPOSE 8000 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')"

# Run both backend and nginx
CMD ["sh", "-c", "nginx && uvicorn backend.main:app --host 0.0.0.0 --port 8000"]
