# GUIRA API Documentation

REST API for real-time fire detection, smoke analysis, vegetation monitoring, and fire spread prediction.

**Base URL:** `http://localhost:8000/api/v1`  
**Authentication:** API Key (header: `X-API-Key`)

---

## 📋 Table of Contents

- [Authentication](#authentication)
- [Detection Endpoints](#detection-endpoints)
- [Prediction Endpoints](#prediction-endpoints)
- [Monitoring Endpoints](#monitoring-endpoints)
- [Map Generation](#map-generation)
- [Data Models](#data-models)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)
- [Examples](#examples)

---

## Authentication

All API requests require an API key in the header:

```bash
curl -H "X-API-Key: your_api_key_here" http://localhost:8000/api/v1/health
```

**Obtaining an API Key:**
- Contact: rasanti2008@gmail.com
- Include: organization name, use case, expected load

---

## Detection Endpoints

### POST /detect/fire

Detect fire and smoke in uploaded image or video frame.

**Request:**

```json
{
  "image": "base64_encoded_image_data",
  "confidence_threshold": 0.85,
  "return_annotated": true
}
```

**Response:**

```json
{
  "status": "success",
  "detections": [
    {
      "class": "fire",
      "confidence": 0.94,
      "bbox": {
        "x": 320,
        "y": 240,
        "width": 150,
        "height": 120
      },
      "area_pixels": 18000,
      "timestamp": "2025-12-17T22:50:00Z"
    }
  ],
  "processing_time_ms": 45,
  "annotated_image": "base64_encoded_annotated_image"
}
```

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `image` | string | Yes | - | Base64 encoded image data |
| `confidence_threshold` | float | No | 0.85 | Minimum detection confidence |
| `return_annotated` | boolean | No | false | Return image with bounding boxes |
| `geolocation` | object | No | null | GPS coordinates for geospatial mapping |

**Status Codes:**
- `200` - Success
- `400` - Invalid image data
- `401` - Authentication failed
- `413` - Image too large (max 10MB)
- `500` - Internal server error

---

### POST /detect/smoke/temporal

Analyze video sequence for smoke detection using TimeSFormer.

**Request:**

```json
{
  "video_frames": ["frame1_base64", "frame2_base64", ...],
  "sequence_length": 8,
  "confidence_threshold": 0.80
}
```

**Response:**

```json
{
  "status": "success",
  "smoke_detected": true,
  "confidence": 0.87,
  "behavior_analysis": {
    "movement_direction": "northwest",
    "spread_rate_mps": 2.3,
    "density_increasing": true
  },
  "frame_predictions": [
    {"frame": 0, "confidence": 0.75},
    {"frame": 1, "confidence": 0.82},
    ...
  ],
  "processing_time_ms": 120
}
```

---

### POST /detect/vegetation

Analyze satellite imagery for vegetation health using ResNet50+VARI.

**Request:**

```json
{
  "satellite_image": "base64_geotiff_data",
  "compute_vari": true,
  "return_health_map": true
}
```

**Response:**

```json
{
  "status": "success",
  "health_distribution": {
    "healthy": 0.45,
    "dry": 0.35,
    "burned": 0.20
  },
  "risk_level": "high",
  "vari_mean": 0.23,
  "health_map": "base64_encoded_heatmap",
  "processing_time_ms": 850
}
```

---

### POST /detect/wildlife

Detect and count wildlife using YOLOv8 + CSRNet.

**Request:**

```json
{
  "image": "base64_encoded_image",
  "detect_species": true,
  "density_estimation": true
}
```

**Response:**

```json
{
  "status": "success",
  "detections": [
    {
      "species": "deer",
      "confidence": 0.91,
      "bbox": {"x": 150, "y": 200, "width": 80, "height": 100},
      "health_status": "healthy"
    }
  ],
  "density_estimate": 12,
  "density_map": "base64_heatmap",
  "processing_time_ms": 95
}
```

---

## Prediction Endpoints

### POST /predict/fire-spread

Simulate fire spread using hybrid physics-neural model.

**Request:**

```json
{
  "fire_location": {
    "lat": 40.7128,
    "lon": -74.0060
  },
  "current_fire_perimeter": "geojson_polygon",
  "environmental_data": {
    "wind_speed_mps": 5.5,
    "wind_direction_degrees": 270,
    "humidity_percent": 25,
    "temperature_celsius": 35
  },
  "dem_data": "base64_geotiff_dem",
  "vegetation_data": "base64_geotiff_vegetation",
  "prediction_hours": 2,
  "timestep_minutes": 15
}
```

**Response:**

```json
{
  "status": "success",
  "predictions": [
    {
      "time_offset_minutes": 15,
      "fire_perimeter": "geojson_polygon",
      "area_hectares": 45.2,
      "intensity_level": "high",
      "spread_direction": "west"
    },
    {
      "time_offset_minutes": 30,
      "fire_perimeter": "geojson_polygon",
      "area_hectares": 68.5,
      "intensity_level": "extreme",
      "spread_direction": "west-northwest"
    }
  ],
  "confidence": 0.82,
  "warnings": [
    "High wind speeds may increase prediction uncertainty",
    "Vegetation data is 48 hours old"
  ],
  "processing_time_ms": 3500
}
```

---

### POST /predict/risk-assessment

Generate comprehensive fire risk assessment for area.

**Request:**

```json
{
  "area_bounds": {
    "north": 40.75,
    "south": 40.70,
    "east": -73.95,
    "west": -74.05
  },
  "include_factors": ["vegetation", "weather", "topography", "historical"],
  "timeframe_hours": 24
}
```

**Response:**

```json
{
  "status": "success",
  "overall_risk_level": "high",
  "risk_score": 7.8,
  "risk_factors": {
    "vegetation_health": {
      "score": 8.5,
      "details": "65% of area shows drought stress"
    },
    "weather_conditions": {
      "score": 7.2,
      "details": "Low humidity, high winds forecasted"
    },
    "topography": {
      "score": 6.5,
      "details": "Steep slopes in 40% of area"
    }
  },
  "high_risk_zones": ["geojson_polygon1", "geojson_polygon2"],
  "recommendations": [
    "Increase monitoring in high-risk zones",
    "Pre-position resources in zone A",
    "Notify residents in evacuation zone B"
  ]
}
```

---

## Monitoring Endpoints

### GET /monitor/stream

WebSocket endpoint for real-time monitoring updates.

**Connection:**

```javascript
const ws = new WebSocket('ws://localhost:8000/api/v1/monitor/stream?api_key=YOUR_KEY');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Detection update:', data);
};
```

**Message Format:**

```json
{
  "type": "fire_detection",
  "timestamp": "2025-12-17T22:50:00Z",
  "location": {
    "lat": 40.7128,
    "lon": -74.0060
  },
  "confidence": 0.94,
  "severity": "high",
  "data": {
    "class": "fire",
    "area_m2": 150
  }
}
```

---

### GET /monitor/status

Get current system status and active alerts.

**Response:**

```json
{
  "status": "operational",
  "active_alerts": 3,
  "alerts": [
    {
      "id": "alert_12345",
      "type": "fire_detected",
      "location": {"lat": 40.7128, "lon": -74.0060},
      "severity": "high",
      "created_at": "2025-12-17T22:45:00Z",
      "status": "active"
    }
  ],
  "system_health": {
    "api_uptime": "99.8%",
    "model_status": "all_operational",
    "processing_queue": 5
  }
}
```

---

## Map Generation

### POST /maps/risk-map

Generate interactive risk map with fire spread predictions.

**Request:**

```json
{
  "center": {
    "lat": 40.7128,
    "lon": -74.0060
  },
  "zoom": 12,
  "layers": ["fire_detection", "smoke_zones", "evacuation_routes", "risk_zones"],
  "include_predictions": true,
  "prediction_hours": 2
}
```

**Response:**

```json
{
  "status": "success",
  "map_url": "https://api.guira.com/maps/risk_12345.html",
  "geojson_data": {
    "fire_detections": "geojson_features",
    "smoke_zones": "geojson_features",
    "evacuation_routes": "geojson_features",
    "risk_zones": "geojson_features"
  },
  "legend": {
    "risk_low": "#10B981",
    "risk_medium": "#F59E0B",
    "risk_high": "#EF4444"
  }
}
```

---

## Data Models

### Detection

```typescript
interface Detection {
  class: "fire" | "smoke" | "fauna";
  confidence: number;  // 0.0 to 1.0
  bbox: BoundingBox;
  timestamp: string;   // ISO 8601 format
  metadata?: object;
}

interface BoundingBox {
  x: number;
  y: number;
  width: number;
  height: number;
}
```

### GeoLocation

```typescript
interface GeoLocation {
  lat: number;         // Latitude (WGS84)
  lon: number;         // Longitude (WGS84)
  elevation_m?: number;
}
```

### FireSpreadPrediction

```typescript
interface FireSpreadPrediction {
  time_offset_minutes: number;
  fire_perimeter: GeoJSON.Polygon;
  area_hectares: number;
  intensity_level: "low" | "medium" | "high" | "extreme";
  spread_direction: string;
  confidence: number;
}
```

---

## Error Handling

### Error Response Format

```json
{
  "error": {
    "code": "INVALID_IMAGE_FORMAT",
    "message": "Image must be JPEG, PNG, or GeoTIFF format",
    "details": {
      "received_format": "BMP",
      "supported_formats": ["JPEG", "PNG", "TIFF"]
    },
    "timestamp": "2025-12-17T22:50:00Z",
    "request_id": "req_abc123"
  }
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `INVALID_API_KEY` | 401 | API key missing or invalid |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `INVALID_IMAGE_FORMAT` | 400 | Unsupported image format |
| `MISSING_PARAMETER` | 400 | Required parameter missing |
| `MODEL_UNAVAILABLE` | 503 | AI model temporarily unavailable |
| `PROCESSING_ERROR` | 500 | Internal processing error |

---

## Rate Limiting

**Default Limits:**
- 100 requests per minute (standard tier)
- 1000 requests per minute (premium tier)

**Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 75
X-RateLimit-Reset: 1702851600
```

**429 Response:**
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again in 45 seconds.",
    "retry_after": 45
  }
}
```

---

## Examples

### Python Client

```python
import requests
import base64

# Initialize client
API_KEY = "your_api_key_here"
BASE_URL = "http://localhost:8000/api/v1"
headers = {"X-API-Key": API_KEY}

# Detect fire in image
with open("fire_image.jpg", "rb") as f:
    image_data = base64.b64encode(f.read()).decode()

response = requests.post(
    f"{BASE_URL}/detect/fire",
    json={
        "image": image_data,
        "confidence_threshold": 0.85,
        "return_annotated": True
    },
    headers=headers
)

result = response.json()
if result["status"] == "success":
    print(f"Detections: {len(result['detections'])}")
    for det in result["detections"]:
        print(f"  {det['class']}: {det['confidence']:.2%}")
```

### JavaScript Client

```javascript
const axios = require('axios');
const fs = require('fs');

const API_KEY = 'your_api_key_here';
const BASE_URL = 'http://localhost:8000/api/v1';

async function detectFire(imagePath) {
  const imageBuffer = fs.readFileSync(imagePath);
  const imageBase64 = imageBuffer.toString('base64');
  
  const response = await axios.post(
    `${BASE_URL}/detect/fire`,
    {
      image: imageBase64,
      confidence_threshold: 0.85
    },
    {
      headers: { 'X-API-Key': API_KEY }
    }
  );
  
  return response.data;
}

detectFire('fire_image.jpg')
  .then(result => console.log('Detections:', result.detections))
  .catch(error => console.error('Error:', error));
```

### cURL Examples

```bash
# Health check
curl -H "X-API-Key: your_key" http://localhost:8000/api/v1/health

# Fire detection
curl -X POST http://localhost:8000/api/v1/detect/fire \
  -H "X-API-Key: your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "image": "base64_encoded_image",
    "confidence_threshold": 0.85
  }'

# Get system status
curl -H "X-API-Key: your_key" http://localhost:8000/api/v1/monitor/status
```

---

## Interactive API Documentation

**Swagger UI:** `http://localhost:8000/docs`  
**ReDoc:** `http://localhost:8000/redoc`

Access interactive API documentation with example requests, response schemas, and testing interface.

---

## Support

**Questions or Issues:**
- Email: rasanti2008@gmail.com
- GitHub Issues: [github.com/THEDIFY/THEDIFY/issues](https://github.com/THEDIFY/THEDIFY/issues)
- Documentation: [Full API Docs](README.md)

---

*Last Updated: December 17, 2025*  
*API Version: v1.0.0*
