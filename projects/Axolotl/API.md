# API Documentation

## Table of Contents
- [Overview](#overview)
- [Authentication](#authentication)
- [Base URL](#base-url)
- [Response Format](#response-format)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)
- [API Endpoints](#api-endpoints)
  - [Scan API](#scan-api)
  - [Feedback API](#feedback-api)
  - [Live Analysis API](#live-analysis-api)
  - [Calendar API](#calendar-api)
  - [Dashboard API](#dashboard-api)
  - [Session API](#session-api)
  - [Pairing API](#pairing-api)
  - [Local Edge API](#local-edge-api)
- [WebSocket Events](#websocket-events)
- [Code Examples](#code-examples)

## Overview

The Axolotl API is a RESTful API that provides programmatic access to the AI-powered football analysis platform. It supports video upload and analysis, performance metrics retrieval, AI-powered coaching feedback, training planning, and real-time tracking.

**API Version:** 1.0  
**Protocol:** HTTP/HTTPS  
**Data Format:** JSON  
**Real-time Communication:** WebSocket (Socket.IO)  
**Max Request Size:** 500MB (video uploads)

## Authentication

### API Key Authentication

All API endpoints (except health check) require authentication via API key.

**Header:**
```
Authorization: Bearer YOUR_API_KEY
```

**Example:**
```bash
curl -H "Authorization: Bearer abc123..." \
  https://api.axolotl.app/api/sessions
```

### Device Pairing

Mobile and edge devices use QR code pairing to obtain API keys securely.

**Pairing Flow:**
1. Request pairing session: `POST /api/pairing/start`
2. Display QR code with pairing token
3. Scan QR code with mobile app
4. Mobile app confirms pairing: `POST /api/pairing/confirm`
5. Receive API key in response
6. Use API key for all subsequent requests

## Base URL

### Development
```
http://localhost:8080
```

### Production
```
https://api.axolotl.app
```

## Response Format

### Success Response

```json
{
  "success": true,
  "data": {
    // Response data
  },
  "message": "Operation completed successfully",
  "timestamp": "2025-12-17T22:40:00Z"
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      "Field 'player_name' is required",
      "Field 'video' must be a valid video file"
    ]
  },
  "timestamp": "2025-12-17T22:40:00Z"
}
```

### Paginated Response

```json
{
  "success": true,
  "data": [
    // Array of items
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 145,
    "pages": 8,
    "has_next": true,
    "has_prev": false,
    "next_page": 2,
    "prev_page": null
  },
  "timestamp": "2025-12-17T22:40:00Z"
}
```

## Error Handling

### HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request succeeded |
| 201 | Created | Resource created successfully |
| 202 | Accepted | Request accepted for processing |
| 400 | Bad Request | Invalid request parameters |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource already exists |
| 422 | Unprocessable Entity | Validation error |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | Service temporarily unavailable |

### Error Codes

| Code | Description |
|------|-------------|
| `VALIDATION_ERROR` | Input validation failed |
| `AUTH_ERROR` | Authentication failed |
| `NOT_FOUND` | Resource not found |
| `PROCESSING_ERROR` | Video/data processing failed |
| `RATE_LIMIT` | Rate limit exceeded |
| `INVALID_FILE` | Invalid file format or size |
| `JOB_FAILED` | Background job failed |
| `GPU_ERROR` | GPU processing error |
| `MODEL_ERROR` | AI model inference error |
| `STORAGE_ERROR` | File storage error |

## Rate Limiting

### Limits

| Endpoint Category | Limit | Window |
|-------------------|-------|--------|
| Authentication | 10 requests | 1 minute |
| Video Upload | 5 uploads | 1 hour |
| Analysis Requests | 100 requests | 1 hour |
| Feedback Generation | 50 requests | 1 hour |
| Dashboard/Metrics | 200 requests | 1 hour |

### Rate Limit Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000
```

### Rate Limit Exceeded Response

```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT",
    "message": "Rate limit exceeded. Please retry after 3600 seconds",
    "retry_after": 3600
  }
}
```

---

## API Endpoints

## Scan API

Video upload and analysis endpoints.

### POST `/api/scan/upload`

Upload a video for analysis.

**Request:**
```http
POST /api/scan/upload
Content-Type: multipart/form-data
Authorization: Bearer YOUR_API_KEY

video: <video_file>
player_name: "John Doe"
position: "midfielder"
age: 16
session_date: "2025-12-17"
metadata: {"field_conditions": "wet", "weather": "rainy"}
```

**Response (202 Accepted):**
```json
{
  "success": true,
  "data": {
    "job_id": "job_abc123",
    "session_id": "sess_456",
    "status": "queued",
    "status_url": "/api/scan/status/job_abc123",
    "estimated_time_seconds": 120
  },
  "message": "Video uploaded successfully. Processing started.",
  "timestamp": "2025-12-17T22:40:00Z"
}
```

**Validation:**
- Video file size: max 500MB
- Supported formats: mp4, mov, avi
- Required fields: video, player_name

### GET `/api/scan/status/{job_id}`

Check processing status of uploaded video.

**Response:**
```json
{
  "success": true,
  "data": {
    "job_id": "job_abc123",
    "status": "processing",
    "progress": 65,
    "current_step": "pose_estimation",
    "steps_completed": ["detection", "tracking"],
    "steps_remaining": ["pose_estimation", "kpi_calculation"],
    "estimated_time_remaining_seconds": 45
  }
}
```

**Status Values:**
- `queued` - Job in queue, not started
- `processing` - Currently processing
- `completed` - Processing completed successfully
- `failed` - Processing failed with error

### GET `/api/scan/results/{session_id}`

Retrieve analysis results for completed session.

**Response:**
```json
{
  "success": true,
  "data": {
    "session_id": "sess_456",
    "player_name": "John Doe",
    "duration_seconds": 3600,
    "video_url": "/storage/videos/sess_456.mp4",
    "kpis": {
      "distance_covered_meters": 8540.5,
      "max_speed_kmh": 28.3,
      "avg_speed_kmh": 6.8,
      "sprints_count": 47,
      "ball_contacts": 89,
      "passes_attempted": 56,
      "passes_completed": 48,
      "pass_accuracy": 85.7
    },
    "tracking_data": {
      "tracked_frames": 108000,
      "total_frames": 108000,
      "tracking_quality": 98.5
    },
    "created_at": "2025-12-17T22:40:00Z"
  }
}
```

---

## Feedback API

AI-powered coaching feedback endpoints.

### POST `/api/feedback/generate`

Generate AI coaching feedback for a session.

**Request:**
```json
{
  "session_id": "sess_456",
  "player_track_id": 1,
  "question": "How can the player improve sprint speed?",
  "context": {
    "age": 16,
    "position": "midfielder",
    "skill_level": "intermediate"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "feedback_id": "fb_789",
    "advice": "Focus on improving sprint technique through proper form drills. The player shows good speed potential but would benefit from enhanced knee drive and forward lean during acceleration phases.",
    "drills": [
      {
        "name": "High Knee Drive Drill",
        "description": "Practice exaggerated knee lift during acceleration",
        "duration": "3 x 20m",
        "rest": "90 seconds between sets",
        "focus_points": [
          "Drive knees up to hip height",
          "Maintain forward lean from ankles",
          "Quick ground contact time"
        ]
      }
    ],
    "evidence_refs": [
      {
        "source": "Professional sprint training methodology",
        "relevance": "Shows 15-20% speed gains in youth athletes"
      }
    ],
    "confidence": 0.87,
    "safety_notes": "Age-appropriate intensity for U16 athletes",
    "suggested_calendar_action": {
      "title": "Sprint Technique Training",
      "duration_minutes": 45,
      "suggested_date": "2025-12-20"
    }
  }
}
```

### GET `/api/feedback/history/{session_id}`

Retrieve all feedback generated for a session.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "feedback_id": "fb_789",
      "question": "How can the player improve sprint speed?",
      "advice": "...",
      "created_at": "2025-12-17T22:45:00Z"
    }
  ]
}
```

---

## Live Analysis API

Real-time session tracking and analysis.

### POST `/api/live/start`

Start a live analysis session.

**Request:**
```json
{
  "player_name": "John Doe",
  "position": "midfielder",
  "session_type": "training"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "live_session_id": "live_abc123",
    "websocket_url": "ws://localhost:8080/socket.io",
    "stream_key": "stream_abc123",
    "status": "ready"
  }
}
```

### POST `/api/live/{session_id}/frame`

Submit a frame for real-time analysis.

**Request:**
```http
POST /api/live/live_abc123/frame
Content-Type: multipart/form-data

frame: <image_data>
timestamp_ms: 1640000000
```

**Response:**
```json
{
  "success": true,
  "data": {
    "detections": [
      {
        "bbox": [100, 200, 150, 300],
        "confidence": 0.95,
        "class": "person",
        "track_id": 1
      }
    ],
    "instant_metrics": {
      "speed_kmh": 12.5,
      "position": {"x": 45.2, "y": 30.8}
    }
  }
}
```

### POST `/api/live/{session_id}/stop`

Stop live analysis session.

**Response:**
```json
{
  "success": true,
  "data": {
    "session_id": "sess_789",
    "duration_seconds": 1800,
    "summary": {
      "total_frames": 54000,
      "avg_speed": 6.2,
      "max_speed": 24.5
    }
  }
}
```

---

## Calendar API

Training planning and scheduling.

### GET `/api/calendar/events`

Retrieve training calendar events.

**Query Parameters:**
- `start_date`: ISO 8601 date (e.g., "2025-12-01")
- `end_date`: ISO 8601 date
- `player_id`: Filter by player (optional)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "event_id": "evt_123",
      "title": "Sprint Technique Training",
      "start": "2025-12-20T10:00:00Z",
      "end": "2025-12-20T11:30:00Z",
      "type": "training",
      "description": "Focus on knee drive and acceleration",
      "ai_generated": true,
      "player_id": "player_456"
    }
  ]
}
```

### POST `/api/calendar/events`

Create new calendar event.

**Request:**
```json
{
  "title": "Passing Drills",
  "start": "2025-12-21T14:00:00Z",
  "end": "2025-12-21T15:30:00Z",
  "type": "training",
  "description": "Short and long passing practice",
  "player_id": "player_456"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "event_id": "evt_124",
    "title": "Passing Drills",
    "created_at": "2025-12-17T22:50:00Z"
  }
}
```

### GET `/api/calendar/ai-recommendations`

Get AI-powered training recommendations.

**Response:**
```json
{
  "success": true,
  "data": {
    "recommendations": [
      {
        "title": "Speed Endurance Training",
        "suggested_date": "2025-12-22",
        "duration_minutes": 60,
        "rationale": "Based on recent performance data showing fatigue in final 20 minutes",
        "priority": "high",
        "drills": ["Interval sprints", "Recovery runs"]
      }
    ]
  }
}
```

---

## Dashboard API

Performance metrics and analytics.

### GET `/api/dashboard/overview/{player_id}`

Get player performance overview.

**Response:**
```json
{
  "success": true,
  "data": {
    "player_id": "player_456",
    "player_name": "John Doe",
    "total_sessions": 45,
    "total_training_hours": 67.5,
    "current_metrics": {
      "avg_speed_kmh": 6.8,
      "max_speed_kmh": 28.3,
      "pass_accuracy": 85.7,
      "distance_per_session_km": 8.5
    },
    "trends": {
      "speed_change_percent": 12.5,
      "accuracy_change_percent": 5.3,
      "distance_change_percent": 8.1
    },
    "last_session": "2025-12-17T22:40:00Z"
  }
}
```

### GET `/api/dashboard/metrics/{session_id}`

Get detailed metrics for specific session.

**Response:**
```json
{
  "success": true,
  "data": {
    "session_id": "sess_456",
    "technical_metrics": {
      "ball_contacts": 89,
      "passes_attempted": 56,
      "passes_completed": 48,
      "shots": 12,
      "dribbles_successful": 15
    },
    "physical_metrics": {
      "distance_covered_m": 8540.5,
      "sprint_distance_m": 1250.3,
      "max_speed_kmh": 28.3,
      "avg_speed_kmh": 6.8,
      "sprints_count": 47,
      "calories_burned": 850
    },
    "tactical_metrics": {
      "positioning_score": 82.5,
      "defensive_actions": 23,
      "attacking_actions": 45,
      "touches_in_box": 18
    }
  }
}
```

---

## Session API

Session management endpoints.

### GET `/api/session/list`

List all sessions with pagination.

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 20, max: 100)
- `player_id`: Filter by player
- `sort`: Sort field (created_at, duration, etc.)
- `order`: asc or desc

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "session_id": "sess_456",
      "player_name": "John Doe",
      "created_at": "2025-12-17T22:40:00Z",
      "duration_seconds": 3600,
      "status": "completed",
      "kpi_summary": {
        "distance_km": 8.5,
        "max_speed_kmh": 28.3
      }
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 145,
    "pages": 8
  }
}
```

### DELETE `/api/session/{session_id}`

Delete a session and all associated data.

**Response:**
```json
{
  "success": true,
  "message": "Session sess_456 deleted successfully"
}
```

---

## Pairing API

Device pairing for mobile apps and edge devices.

### POST `/api/pairing/start`

Start pairing session.

**Request:**
```json
{
  "device_type": "mobile",
  "device_name": "iPhone 14 Pro"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "pairing_token": "pair_abc123",
    "qr_code_url": "/api/pairing/qr/pair_abc123.png",
    "expires_at": "2025-12-17T23:40:00Z"
  }
}
```

### POST `/api/pairing/confirm`

Confirm pairing from mobile device.

**Request:**
```json
{
  "pairing_token": "pair_abc123",
  "device_id": "device_unique_id_123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "api_key": "sk_live_abc123...",
    "expires_at": null,
    "permissions": ["read", "write", "upload"]
  }
}
```

---

## Local Edge API

Edge device coordination.

### POST `/api/local-edge/register`

Register edge device.

**Request:**
```json
{
  "device_id": "edge_rpi_001",
  "capabilities": ["detection", "tracking"],
  "gpu_available": false
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "device_id": "edge_rpi_001",
    "api_key": "edge_key_123",
    "sync_endpoint": "/api/local-edge/sync",
    "model_urls": {
      "detection": "/models/yolov8n_lite.pt",
      "tracking": "/models/bytetrack.pth"
    }
  }
}
```

---

## WebSocket Events

### Connection

```javascript
const socket = io('http://localhost:8080', {
  auth: {
    token: 'YOUR_API_KEY'
  }
});
```

### Events

#### Server → Client

**`analysis_update`** - Real-time analysis progress
```javascript
{
  "job_id": "job_abc123",
  "status": "processing",
  "progress": 65,
  "current_step": "pose_estimation"
}
```

**`live_metrics`** - Real-time performance metrics
```javascript
{
  "session_id": "live_abc123",
  "timestamp": 1640000000,
  "metrics": {
    "speed": 12.5,
    "position": {"x": 45.2, "y": 30.8}
  }
}
```

**`calendar_update`** - Calendar event changes
```javascript
{
  "event_id": "evt_123",
  "action": "created",
  "event": {/* event data */}
}
```

#### Client → Server

**`subscribe_session`** - Subscribe to session updates
```javascript
socket.emit('subscribe_session', {
  session_id: 'sess_456'
});
```

**`live_frame`** - Submit frame for live analysis
```javascript
socket.emit('live_frame', {
  session_id: 'live_abc123',
  frame_data: base64EncodedImage,
  timestamp: Date.now()
});
```

---

## Code Examples

### Python

```python
import requests
import json

API_KEY = "your_api_key_here"
BASE_URL = "http://localhost:8080"

headers = {
    "Authorization": f"Bearer {API_KEY}"
}

# Upload video
with open("match.mp4", "rb") as video_file:
    files = {"video": video_file}
    data = {
        "player_name": "John Doe",
        "position": "midfielder",
        "age": 16
    }
    
    response = requests.post(
        f"{BASE_URL}/api/scan/upload",
        headers=headers,
        files=files,
        data=data
    )
    
    result = response.json()
    job_id = result["data"]["job_id"]
    print(f"Upload successful. Job ID: {job_id}")

# Check status
status_response = requests.get(
    f"{BASE_URL}/api/scan/status/{job_id}",
    headers=headers
)

status = status_response.json()
print(f"Status: {status['data']['status']}")
print(f"Progress: {status['data']['progress']}%")
```

### JavaScript/TypeScript

```typescript
const API_KEY = "your_api_key_here";
const BASE_URL = "http://localhost:8080";

// Upload video
async function uploadVideo(videoFile: File, playerName: string) {
  const formData = new FormData();
  formData.append("video", videoFile);
  formData.append("player_name", playerName);
  formData.append("position", "midfielder");
  
  const response = await fetch(`${BASE_URL}/api/scan/upload`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${API_KEY}`
    },
    body: formData
  });
  
  const result = await response.json();
  return result.data.job_id;
}

// Get dashboard metrics
async function getDashboardMetrics(playerId: string) {
  const response = await fetch(
    `${BASE_URL}/api/dashboard/overview/${playerId}`,
    {
      headers: {
        "Authorization": `Bearer ${API_KEY}`
      }
    }
  );
  
  const result = await response.json();
  return result.data;
}

// WebSocket connection
import io from "socket.io-client";

const socket = io(BASE_URL, {
  auth: { token: API_KEY }
});

socket.on("analysis_update", (data) => {
  console.log("Analysis progress:", data.progress);
});

socket.on("live_metrics", (data) => {
  console.log("Current speed:", data.metrics.speed);
});
```

### cURL Examples

```bash
# Upload video
curl -X POST http://localhost:8080/api/scan/upload \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -F "video=@match.mp4" \
  -F "player_name=John Doe" \
  -F "position=midfielder"

# Check status
curl -X GET http://localhost:8080/api/scan/status/job_abc123 \
  -H "Authorization: Bearer YOUR_API_KEY"

# Get dashboard metrics
curl -X GET http://localhost:8080/api/dashboard/overview/player_456 \
  -H "Authorization: Bearer YOUR_API_KEY"

# Generate AI feedback
curl -X POST http://localhost:8080/api/feedback/generate \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "sess_456",
    "question": "How can the player improve sprint speed?"
  }'
```

---

## Additional Resources

- **[Architecture Overview](documentation/architecture/overview.md)** - System architecture details
- **[WebSocket Guide](documentation/architecture/websocket.md)** - Real-time communication
- **[Rate Limiting](documentation/architecture/rate-limiting.md)** - Rate limit details
- **[Error Codes](documentation/architecture/error-codes.md)** - Complete error reference
- **[Changelog](CHANGELOG.md)** - API version history

---

**API Version:** 1.0  
**Last Updated:** December 17, 2025  
**Support:** rasanti2008@gmail.com
