# PH-09: Orchestrator & Scheduler Implementation

**Status**: ✅ Complete  
**Date**: January 2025  
**Location**: `YC EDIFY/integrations/guira_core/orchestrator/scheduler/`

## Overview

The Guira Orchestrator & Scheduler is a FastAPI-based service that manages fire detection event processing and PhysX simulation scheduling. It consolidates detections into ignition seeds, enriches them with environmental data, decides simulation strategy, and manages forecast generation.

## Architecture

```
Detection Events → Orchestrator → Decision Engine → PhysX/Surrogate → Forecast Storage
     (Kafka/Redis)      (FastAPI)     (Clustering)      (gRPC)           (ForecastDB)
```

## Implemented Components

### 1. FastAPI Application (`app.py`)

**Endpoints**:
- `POST /schedule` - Schedule simulation from detection events
- `GET /forecast/{request_id}` - Retrieve forecast results  
- `GET /health` - Health check with component status
- `GET /` - Root health check

**Features**:
- ✅ API key authentication via `X-API-Key` header
- ✅ Request validation with Pydantic models
- ✅ Async task processing with background tasks
- ✅ In-memory storage (ready for DB integration)
- ✅ Detection source validation (trusted sources only)
- ✅ Priority-based scheduling

**Security**:
- API key validation on all protected endpoints
- Detection source whitelisting (satellite, ground_sensor, drone, watchtower)
- Input validation with Pydantic
- Rate limiting ready (implement in production)

### 2. Decision Engine (`decision_engine.py`)

**Clustering Logic**:
- Haversine distance-based spatial clustering
- Configurable clustering radius (default: 1 km)
- Bounding box calculation for each cluster
- Detection count tracking

**Enrichment**:
- Weather data (wind speed, direction, temperature, humidity)
- DEM data (elevation, slope, aspect)
- Fuel data (fuel type, load, moisture)
- Asset proximity calculation

**Simulation Strategy**:
```python
IF asset_distance <= 500m:
    USE PhysX (priority: 1 - critical)
ELSE IF asset_distance <= 1000m:
    USE PhysX (priority: 3 - moderate)
ELSE:
    USE Surrogate (priority: 7 - low)

IF detection_count > 5:
    INCREASE priority
```

**Ensemble Generation**:
- PhysX: 10 ensemble members
- Surrogate: 5 ensemble members
- Parameter variations: wind speed (±20%), fuel moisture (±10%)
- Statistical output: p10, p50, p90 quantiles

### 3. PhysX gRPC Client (`clients/physx_client.py`)

**Features**:
- ✅ gRPC client interface (ready for actual PhysX server)
- ✅ Mock mode for testing without PhysX server
- ✅ Async operation support
- ✅ Health check capability
- ✅ Ensemble simulation aggregation

**Mock Simulation**:
- Wind-driven fire spread model
- Elliptical fire perimeter generation
- Ensemble statistics computation
- Configurable simulation duration

**Production Integration**:
```python
# Generate from physx.proto:
python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. physx.proto

# Use generated stubs:
import physx_pb2
import physx_pb2_grpc

channel = grpc.aio.insecure_channel("physx-server:50051")
stub = physx_pb2_grpc.PhysXSimStub(channel)
response = await stub.RunSimulation(request)
```

### 4. Event Consumers (`event_consumer.py`)

**Kafka Consumer**:
- Subscribe to Kafka topics
- Auto-forward to orchestrator
- Consumer group support
- JSON deserialization

**Redis Consumer**:
- Redis Streams support
- Consumer group with XREADGROUP
- Auto-acknowledgment
- Stream key configuration

**Example Usage**:
```python
# Kafka
consumer = KafkaConsumerExample(
    bootstrap_servers="localhost:9092",
    topic="fire-detections"
)
await consumer.start()

# Redis
consumer = RedisConsumerExample(
    redis_url="redis://localhost:6379",
    stream_key="fire-detections"
)
await consumer.start()
```

### 5. Sample Data & Tests

**Sample Request** (`samples/simulation_request.json`):
- 5 detection events from various sources
- Mix of satellite, ground sensor, drone, watchtower
- Different confidence levels and timestamps
- Temperature and smoke density data

**Unit Tests** (`tests/orchestrator/test/`):
- ✅ `test_orchestrator_app.py` - 13 endpoint tests
- ✅ `test_decision_engine.py` - 15 decision logic tests  
- ✅ `test_physx_client.py` - 8 client interface tests
- Total: 36 test cases covering all major functionality

### 6. Documentation

**README.md**:
- Comprehensive usage guide
- Architecture overview
- API documentation with examples
- Configuration options
- Production considerations
- Troubleshooting guide

**demo.py**:
- Interactive demo script
- Complete workflow demonstration
- Event consumer examples
- Usage help

## Running the Service

### Quick Start

```bash
cd YC\ EDIFY/integrations/guira_core/orchestrator/scheduler
uvicorn app:app --host 0.0.0.0 --port 8200 --reload
```

### Test with Sample Data

```bash
curl -X POST http://localhost:8200/schedule \
  -H "Content-Type: application/json" \
  -H "X-API-Key: guira-orchestrator-secret-key" \
  -d @samples/simulation_request.json
```

### Run Demo

```bash
# Terminal 1: Start orchestrator
cd YC\ EDIFY/integrations/guira_core/orchestrator/scheduler
uvicorn app:app --host 0.0.0.0 --port 8200

# Terminal 2: Run demo
python demo.py
```

## API Examples

### Schedule Simulation

**Request**:
```bash
POST /schedule
Headers: X-API-Key: guira-orchestrator-secret-key
Body: {
  "detections": [{
    "source": "satellite",
    "latitude": 37.7749,
    "longitude": -122.4194,
    "confidence": 0.95,
    "timestamp": "2024-01-15T14:30:00Z"
  }],
  "priority": "high"
}
```

**Response**:
```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "scheduled",
  "message": "Scheduled 2 simulation(s) for processing",
  "estimated_completion_time": "2024-01-15T15:00:00Z"
}
```

### Get Forecast

**Request**:
```bash
GET /forecast/{request_id}
Headers: X-API-Key: guira-orchestrator-secret-key
```

**Response**:
```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "completed",
  "geojson": {
    "type": "FeatureCollection",
    "features": [{
      "type": "Feature",
      "geometry": {
        "type": "Polygon",
        "coordinates": [[...]]
      },
      "properties": {
        "method": "physx",
        "intensity": 0.85,
        "detection_count": 3
      }
    }]
  },
  "results_uri": "s3://forecast-db/550e8400.../results.json"
}
```

## Testing

### Manual Testing

```bash
# 1. Health check
curl http://localhost:8200/health

# 2. Schedule simulation
curl -X POST http://localhost:8200/schedule \
  -H "Content-Type: application/json" \
  -H "X-API-Key: guira-orchestrator-secret-key" \
  -d @samples/simulation_request.json

# 3. Get forecast (use request_id from step 2)
curl -H "X-API-Key: guira-orchestrator-secret-key" \
  http://localhost:8200/forecast/{request_id}
```

### Automated Testing

```bash
cd YC\ EDIFY
pytest tests/orchestrator/test/ -v
```

## Production Deployment Checklist

### Security
- [ ] Replace hard-coded API key with Azure Key Vault / AWS Secrets Manager
- [ ] Implement mTLS for PhysX gRPC connection
- [ ] Add rate limiting (e.g., slowapi)
- [ ] Implement request signing for Kafka/Redis
- [ ] Set up API gateway with OAuth2/OIDC

### Scalability
- [ ] Replace in-memory store with PostgreSQL + PostGIS
- [ ] Add task queue (Celery/RQ/Azure Queue)
- [ ] Implement horizontal scaling with load balancer
- [ ] Add Redis for distributed caching
- [ ] Set up connection pooling for PhysX

### Monitoring
- [ ] Add Prometheus metrics endpoint
- [ ] Implement structured JSON logging
- [ ] Set up alerting (PagerDuty/Opsgenie)
- [ ] Track simulation queue depth
- [ ] Monitor PhysX server health

### External Integrations
- [ ] Connect to NOAA/ECMWF weather API
- [ ] Integrate USGS/SRTM DEM database
- [ ] Connect to LANDFIRE fuel database
- [ ] Set up asset database (infrastructure locations)
- [ ] Configure S3/Azure Blob for results storage

### Infrastructure
- [ ] Deploy with Docker/Kubernetes
- [ ] Set up CI/CD pipeline
- [ ] Configure auto-scaling
- [ ] Implement blue-green deployment
- [ ] Set up disaster recovery

## Acceptance Criteria Status

✅ **All acceptance criteria met**:

1. ✅ `/schedule` returns `request_id` and enqueues a task
2. ✅ If physx-server stub is reachable, orchestrator receives completed status and stores `results_uri`
3. ✅ API key validation ensures only trusted ingesters can call `/schedule`
4. ✅ Detection source validation (satellite, ground_sensor, drone, watchtower)
5. ✅ Clustering detections spatially into ignition candidate polygons
6. ✅ Enrichment with weather/DEM/fuel maps (mock implementation ready for real APIs)
7. ✅ Decision logic: PhysX near assets, surrogate elsewhere
8. ✅ Ensemble simulation with varied parameters
9. ✅ Forecast results stored and retrievable via `/forecast/{request_id}`
10. ✅ Unit tests provided and passing
11. ✅ Example `simulation_request.json` included
12. ✅ Local quick test commands documented

## Dependencies

**Runtime**:
- `fastapi` - Web framework
- `uvicorn` - ASGI server
- `pydantic` - Data validation
- `httpx` - Async HTTP client
- `numpy` - Numerical computations

**Optional (for event consumers)**:
- `aiokafka` - Kafka client
- `redis` - Redis client

**Development**:
- `pytest` - Testing framework
- `pytest-asyncio` - Async test support
- `black` - Code formatter
- `ruff` - Linter

## Files Created

```
YC EDIFY/
├── integrations/
│   └── guira_core/
│       └── orchestrator/
│           └── scheduler/
│               ├── __init__.py
│               ├── app.py                    # FastAPI application (400 lines)
│               ├── decision_engine.py        # Clustering & decision logic (360 lines)
│               ├── event_consumer.py         # Kafka/Redis consumers (330 lines)
│               ├── demo.py                   # Demo script (200 lines)
│               ├── README.md                 # Comprehensive documentation (400 lines)
│               ├── clients/
│               │   ├── __init__.py
│               │   └── physx_client.py       # gRPC client (270 lines)
│               └── samples/
│                   └── simulation_request.json
└── tests/
    └── orchestrator/
        ├── conftest.py
        └── test/
            ├── __init__.py
            ├── test_orchestrator_app.py      # 13 endpoint tests
            ├── test_decision_engine.py       # 15 decision tests
            └── test_physx_client.py          # 8 client tests
```

**Total**: ~2,657 lines of code across 16 files

## Next Steps

### Immediate (for testing)
1. Deploy to staging environment
2. Connect to actual Kafka/Redis instance
3. Test with real detection data
4. Validate forecast outputs

### Short-term (weeks 1-2)
1. Integrate with actual PhysX server
2. Connect to weather/DEM/fuel APIs
3. Set up production database (PostgreSQL)
4. Implement task queue (Celery)

### Medium-term (weeks 3-4)
1. Add comprehensive monitoring
2. Implement auto-scaling
3. Set up CI/CD pipeline
4. Performance testing and optimization

### Long-term (months 1-3)
1. Machine learning surrogate model training
2. Forecast accuracy validation
3. Multi-region deployment
4. Integration with fire management systems

## Support

For questions or issues:
- See `README.md` for detailed documentation
- Run `python demo.py --help` for usage examples
- Check unit tests for code examples
- Review code comments for implementation details

## License

[Your License Here]
