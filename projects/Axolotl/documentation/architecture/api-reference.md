# API Reference

## Table of Contents
- [Overview](#overview)
- [Authentication](#authentication)
- [Base URL](#base-url)
- [Response Format](#response-format)
- [Error Handling](#error-handling)
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

## Overview

The Axolotl API is a RESTful API that provides programmatic access to the football analysis platform. It supports video analysis, performance metrics, AI-powered coaching feedback, training planning, and real-time tracking.

**API Version**: 1.0  
**Protocol**: HTTP/HTTPS  
**Data Format**: JSON  
**Real-time**: WebSocket (Socket.IO)

## Authentication

### API Key Authentication

Most endpoints require an API key for authentication.

**Header**:
```
Authorization: Bearer YOUR_API_KEY
```

**Example**:
```bash
curl -H "Authorization: Bearer abc123..." https://api.axolotl.app/api/sessions
```

### Device Pairing

Mobile and edge devices use QR code pairing to obtain API keys.

**Flow**:
1. Request pairing session
2. Display QR code
3. Scan with mobile app
4. Receive API key
5. Use key for subsequent requests

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
  "timestamp": "2025-10-24T00:00:00Z"
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": ["Additional error details"]
  },
  "timestamp": "2025-10-24T00:00:00Z"
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
    "has_prev": false
  },
  "timestamp": "2025-10-24T00:00:00Z"
}
```

## Error Handling

### HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request succeeded |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid request parameters |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
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

## API Endpoints

## Scan API

Video upload and analysis endpoints.

### Quick Scan

Upload and analyze a single video.

**Endpoint**: `POST /api/scan/quick`

**Request**:
```http
POST /api/scan/quick
Content-Type: multipart/form-data

video: <video_file>
player_id: player_123
session_type: training
```

**Parameters**:
- `video` (file, required): Video file (mp4, avi, mov, mkv)
- `player_id` (string, required): Player identifier
- `session_type` (string, optional): Type of session ('training', 'match', 'analysis')
- `title` (string, optional): Session title
- `description` (string, optional): Session description

**Response**:
```json
{
  "success": true,
  "data": {
    "session_id": "sess_20251024_001",
    "job_id": "job_abc123",
    "status": "queued",
    "estimated_time": "5 minutes"
  }
}
```

**Example**:
```bash
curl -X POST http://localhost:8080/api/scan/quick \
  -F "video=@session_video.mp4" \
  -F "player_id=player_123" \
  -F "session_type=training"
```

---

### SMPL Fitting

Submit pose data for SMPL body model fitting.

**Endpoint**: `POST /api/scan/smpl`

**Request**:
```json
{
  "session_id": "sess_20251024_001",
  "pose_data": {
    "keypoints": [...],
    "confidence": [...]
  },
  "gender": "neutral",
  "optimize": true
}
```

**Parameters**:
- `session_id` (string, required): Session identifier
- `pose_data` (object, required): Pose estimation results
- `gender` (string, optional): Model gender ('male', 'female', 'neutral')
- `optimize` (boolean, optional): Enable optimization (default: true)

**Response**:
```json
{
  "success": true,
  "data": {
    "job_id": "smpl_job_xyz789",
    "status": "queued",
    "estimated_time": "2 minutes"
  }
}
```

---

### Check SMPL Job Status

Get status of SMPL fitting job.

**Endpoint**: `GET /api/scan/smpl/status/{job_id}`

**Response**:
```json
{
  "success": true,
  "data": {
    "job_id": "smpl_job_xyz789",
    "status": "completed",
    "progress": 100,
    "result": {
      "vertices": [...],
      "faces": [...],
      "joint_angles": {...}
    }
  }
}
```

**Status Values**:
- `queued`: Job is waiting in queue
- `running`: Job is being processed
- `completed`: Job finished successfully
- `failed`: Job failed with error

---

## Feedback API

AI-powered coaching feedback endpoints.

### Generate Feedback

Generate AI coaching feedback for a session.

**Endpoint**: `POST /api/feedback/generate`

**Request**:
```json
{
  "session_id": "sess_20251024_001",
  "player_id": "player_123",
  "feedback_type": "comprehensive",
  "focus_areas": ["technical", "physical"],
  "include_recommendations": true
}
```

**Parameters**:
- `session_id` (string, required): Session to analyze
- `player_id` (string, required): Player identifier
- `feedback_type` (string, optional): Type of feedback ('comprehensive', 'quick', 'specific')
- `focus_areas` (array, optional): Areas to focus on
- `include_recommendations` (boolean, optional): Include training recommendations

**Response**:
```json
{
  "success": true,
  "data": {
    "feedback_id": "fb_20251024_001",
    "session_id": "sess_20251024_001",
    "feedback": {
      "summary": "Overall strong performance with areas for improvement...",
      "technical": {
        "strengths": ["First touch", "Passing accuracy"],
        "improvements": ["Shooting technique"]
      },
      "physical": {
        "strengths": ["Speed", "Endurance"],
        "improvements": ["Acceleration off the mark"]
      },
      "recommendations": [
        {
          "area": "technical",
          "drill": "Shooting accuracy drill",
          "duration": "15 minutes",
          "frequency": "3x per week"
        }
      ]
    },
    "generated_at": "2025-10-24T10:30:00Z"
  }
}
```

---

### Validate Feedback

Validate feedback quality (for internal use).

**Endpoint**: `POST /api/feedback/validate`

**Request**:
```json
{
  "feedback_id": "fb_20251024_001",
  "rating": 4,
  "notes": "Very helpful insights"
}
```

---

### Get Feedback Templates

Get available feedback templates.

**Endpoint**: `GET /api/feedback/templates`

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "name": "comprehensive",
      "description": "Complete analysis with all metrics",
      "categories": ["technical", "physical", "tactical", "mental"]
    },
    {
      "name": "quick",
      "description": "Quick overview of key points",
      "categories": ["summary"]
    }
  ]
}
```

---

## Live Analysis API

Real-time session tracking endpoints.

### Health Check

Check live service status.

**Endpoint**: `GET /health`

**Response**:
```json
{
  "status": "healthy",
  "service": "live_analysis",
  "timestamp": "2025-10-24T10:00:00Z"
}
```

---

### Submit Frame

Submit video frame for real-time analysis.

**Endpoint**: `POST /{session_id}/frame`

**Request**:
```http
POST /sess_live_001/frame
Content-Type: multipart/form-data

frame: <image_data>
timestamp: 125.5
```

**Parameters**:
- `frame` (file, required): Video frame (JPEG/PNG)
- `timestamp` (float, required): Frame timestamp in seconds

**Response**:
```json
{
  "success": true,
  "data": {
    "frame_id": "frame_001",
    "detections": [
      {
        "player_id": 1,
        "bbox": [100, 200, 150, 300],
        "confidence": 0.95
      }
    ],
    "metrics": {
      "players_detected": 1,
      "avg_speed": 15.5,
      "processing_time_ms": 45
    }
  }
}
```

---

### Request Live Feedback

Request AI feedback during live session.

**Endpoint**: `POST /{session_id}/feedback`

**Request**:
```json
{
  "query": "How is the player's stamina?",
  "context": "current_session"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "feedback": "Player is showing good stamina with consistent speed...",
    "recommendations": ["Consider hydration break in 10 minutes"],
    "timestamp": "2025-10-24T10:15:00Z"
  }
}
```

---

## Calendar API

Training planning and scheduling endpoints.

### Get User Calendar

Get calendar events for a user.

**Endpoint**: `GET /api/user/{user_id}`

**Query Parameters**:
- `start_date` (string, optional): Filter start date (ISO 8601)
- `end_date` (string, optional): Filter end date (ISO 8601)
- `event_type` (string, optional): Filter by event type

**Response**:
```json
{
  "success": true,
  "data": {
    "events": [
      {
        "id": "event_001",
        "title": "Speed Training",
        "start_time": "2025-10-24T10:00:00Z",
        "end_time": "2025-10-24T11:30:00Z",
        "event_type": "training",
        "player_id": "player_123",
        "drills": [
          {
            "name": "Sprint intervals",
            "duration": 20,
            "description": "6x40m sprints with 90s rest"
          }
        ],
        "ai_generated": false
      }
    ]
  }
}
```

---

### Propose Training Plan

Get AI-generated training recommendations.

**Endpoint**: `POST /api/user/{user_id}/calendar/propose`

**Request**:
```json
{
  "player_id": "player_123",
  "start_date": "2025-10-24",
  "end_date": "2025-10-31",
  "focus_areas": ["speed", "technical"],
  "sessions_per_week": 4
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "proposed_events": [
      {
        "title": "Speed Development Session",
        "start_time": "2025-10-24T10:00:00Z",
        "end_time": "2025-10-24T11:30:00Z",
        "event_type": "training",
        "drills": [...],
        "rationale": "Based on recent performance, speed development is recommended..."
      }
    ],
    "validation": {
      "passes_safety_checks": true,
      "warnings": []
    }
  }
}
```

---

### Commit Training Plan

Commit proposed plan to calendar.

**Endpoint**: `POST /api/user/{user_id}/calendar/commit`

**Request**:
```json
{
  "events": [
    {
      "title": "Speed Training",
      "start_time": "2025-10-24T10:00:00Z",
      "end_time": "2025-10-24T11:30:00Z",
      "drills": [...]
    }
  ]
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "created_events": [
      {
        "id": "event_002",
        "title": "Speed Training",
        "status": "scheduled"
      }
    ]
  }
}
```

---

### Modify Event with LLM

Modify event using natural language.

**Endpoint**: `POST /api/user/{user_id}/calendar/llm_modify`

**Request**:
```json
{
  "event_id": "event_002",
  "instruction": "Move this to 2pm and add agility drills"
}
```

---

### Delete Event

Delete a calendar event.

**Endpoint**: `DELETE /api/user/{user_id}/calendar/{event_id}`

**Response**:
```json
{
  "success": true,
  "message": "Event deleted successfully"
}
```

---

## Dashboard API

Performance metrics and visualization endpoints.

### Get Coach Dashboard

Get dashboard data for a coach.

**Endpoint**: `GET /api/dashboard/coach/{user_id}`

**Query Parameters**:
- `date_range` (string, optional): Time range ('week', 'month', 'season')

**Response**:
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_sessions": 45,
      "total_players": 12,
      "avg_session_duration": 85
    },
    "recent_sessions": [...],
    "player_performance": [
      {
        "player_id": "player_123",
        "name": "John Doe",
        "avg_speed": 24.5,
        "total_distance": 380.5,
        "session_count": 8
      }
    ],
    "trends": {
      "speed": {"trend": "up", "change_percent": 5.2},
      "distance": {"trend": "stable", "change_percent": 0.5}
    }
  }
}
```

---

### Get Player Dashboard

Get dashboard data for a specific player.

**Endpoint**: `GET /api/dashboard/player/{player_id}`

**Response**:
```json
{
  "success": true,
  "data": {
    "player_info": {
      "id": "player_123",
      "name": "John Doe",
      "position": "midfielder"
    },
    "recent_performance": {
      "max_speed": 28.5,
      "avg_speed": 24.5,
      "total_distance": 8.2,
      "session_count": 8
    },
    "progress": {
      "speed": [
        {"date": "2025-10-17", "value": 24.1},
        {"date": "2025-10-24", "value": 24.5}
      ]
    },
    "recent_feedback": [...]
  }
}
```

---

## Session API

Session management endpoints.

### List Sessions

Get list of sessions with filtering.

**Endpoint**: `GET /api/sessions`

**Query Parameters**:
- `player_id` (string, optional): Filter by player
- `session_type` (string, optional): Filter by type
- `status` (string, optional): Filter by status
- `start_date` (string, optional): Filter by start date
- `end_date` (string, optional): Filter by end date
- `page` (integer, optional): Page number (default: 1)
- `per_page` (integer, optional): Items per page (default: 20)

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": "sess_20251024_001",
      "player_id": "player_123",
      "session_type": "training",
      "title": "Speed Training Session",
      "start_time": "2025-10-24T10:00:00Z",
      "duration_seconds": 5400,
      "status": "completed",
      "kpis": {
        "max_speed": 28.5,
        "total_distance": 8200
      }
    }
  ],
  "pagination": {...}
}
```

---

### Get Session Details

Get detailed information about a specific session.

**Endpoint**: `GET /api/sessions/{session_id}`

**Response**:
```json
{
  "success": true,
  "data": {
    "id": "sess_20251024_001",
    "player_id": "player_123",
    "player_name": "John Doe",
    "session_type": "training",
    "title": "Speed Training Session",
    "description": "Focus on acceleration and top speed",
    "start_time": "2025-10-24T10:00:00Z",
    "end_time": "2025-10-24T11:30:00Z",
    "duration_seconds": 5400,
    "status": "completed",
    "video_path": "/storage/videos/sess_20251024_001.mp4",
    "kpis": {
      "max_speed_kmh": 28.5,
      "avg_speed_kmh": 24.5,
      "total_distance_m": 8200,
      "high_intensity_distance_m": 1500,
      "sprint_count": 8,
      "accelerations": 15,
      "decelerations": 12
    },
    "metadata": {
      "weather": "sunny",
      "temperature": 22,
      "field_type": "grass"
    },
    "feedback_count": 2,
    "created_at": "2025-10-24T11:35:00Z"
  }
}
```

---

### Compare Sessions

Compare multiple sessions.

**Endpoint**: `GET /api/sessions/compare`

**Query Parameters**:
- `session_ids` (string, required): Comma-separated session IDs

**Response**:
```json
{
  "success": true,
  "data": {
    "sessions": [
      {
        "id": "sess_001",
        "date": "2025-10-17",
        "kpis": {...}
      },
      {
        "id": "sess_002",
        "date": "2025-10-24",
        "kpis": {...}
      }
    ],
    "comparison": {
      "speed_improvement": 5.2,
      "distance_improvement": -2.1
    }
  }
}
```

---

### Add Session Notes

Add notes to a session.

**Endpoint**: `POST /api/sessions/{session_id}/notes`

**Request**:
```json
{
  "notes": "Player showed great improvement in acceleration drills"
}
```

---

### Export Session Data

Export session data in various formats.

**Endpoint**: `GET /api/sessions/{session_id}/export`

**Query Parameters**:
- `format` (string, required): Export format ('json', 'csv', 'pdf')

**Response**:
Returns file download with appropriate content-type.

---

## Pairing API

Device pairing endpoints.

### Create Pairing Session

Create a new pairing session and get QR code.

**Endpoint**: `POST /create_session`

**Request**:
```json
{
  "user_id": "user_123",
  "device_type": "mobile"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "session_id": "pair_session_abc123",
    "qr_code": "data:image/png;base64,...",
    "expires_at": "2025-10-24T10:10:00Z"
  }
}
```

---

### Validate Pairing Code

Validate a pairing code (mobile app calls this).

**Endpoint**: `GET /validate`

**Query Parameters**:
- `code` (string, required): Pairing code from QR scan

**Response**:
```json
{
  "success": true,
  "data": {
    "valid": true,
    "session_id": "pair_session_abc123",
    "user_id": "user_123"
  }
}
```

---

### Register Device

Complete device registration.

**Endpoint**: `POST /register_device`

**Request**:
```json
{
  "session_id": "pair_session_abc123",
  "device_info": {
    "device_name": "iPhone 13",
    "device_model": "iPhone13,2",
    "os_version": "iOS 16.0",
    "app_version": "1.0.0"
  }
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "device_id": "device_xyz789",
    "api_key": "api_key_secure_token",
    "expires_at": "2026-10-24T10:00:00Z"
  }
}
```

---

## Local Edge API

Edge device communication endpoints.

### Register Edge Device

Register an edge device.

**Endpoint**: `POST /pair/register`

**Request**:
```json
{
  "device_name": "Edge Device 1",
  "device_type": "edge",
  "capabilities": ["detection", "tracking", "pose"]
}
```

---

### Start Edge Session

Start processing session on edge device.

**Endpoint**: `POST /{session_id}/start`

**Request**:
```json
{
  "config": {
    "fps": 30,
    "resolution": "1920x1080",
    "models": ["yolov8n", "mediapipe"]
  }
}
```

---

### Stop Edge Session

Stop edge session.

**Endpoint**: `POST /{session_id}/stop`

---

### Get Edge Session Status

Get edge session status.

**Endpoint**: `GET /{session_id}/status`

**Response**:
```json
{
  "success": true,
  "data": {
    "session_id": "edge_sess_001",
    "status": "running",
    "frames_processed": 1250,
    "uptime_seconds": 85,
    "metrics": {
      "fps": 29.5,
      "avg_processing_time_ms": 33
    }
  }
}
```

---

## WebSocket Events

Real-time bidirectional communication using Socket.IO.

### Connection Events

#### Connect
```javascript
socket.on('connect', () => {
  console.log('Connected to server');
});
```

#### Disconnect
```javascript
socket.on('disconnect', () => {
  console.log('Disconnected from server');
});
```

### Live Analysis Events

#### Join Session
**Emit**:
```javascript
socket.emit('join_session', {
  session_id: 'sess_live_001'
});
```

**Receive**:
```javascript
socket.on('joined', (data) => {
  console.log('Joined session:', data.session_id);
});
```

#### Metrics Update
**Receive**:
```javascript
socket.on('metrics_update', (data) => {
  console.log('New metrics:', data.metrics);
  // data.metrics = { players: [...], fps: 30, timestamp: '...' }
});
```

### Calendar Events

#### Calendar Update
**Receive**:
```javascript
socket.on('calendar_update', (data) => {
  console.log('Calendar changed:', data.event);
  // Refresh calendar display
});
```

#### Recommendation Ready
**Receive**:
```javascript
socket.on('recommendation_ready', (data) => {
  console.log('AI recommendations:', data.recommendations);
});
```

### Pairing Events

#### Pairing Request
**Emit**:
```javascript
socket.emit('pairing_request', {
  session_id: 'pair_session_abc123',
  device_info: {...}
});
```

#### Pairing Success
**Receive**:
```javascript
socket.on('pairing_success', (data) => {
  console.log('Device paired:', data.device_id);
  console.log('API Key:', data.api_key);
});
```

#### Pairing Failed
**Receive**:
```javascript
socket.on('pairing_failed', (data) => {
  console.error('Pairing failed:', data.error);
});
```

## Rate Limiting

The API implements rate limiting to prevent abuse:

- **Standard endpoints**: 100 requests per minute
- **Upload endpoints**: 10 requests per minute
- **Live streaming**: 60 frames per second per session

**Rate Limit Headers**:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1698134400
```

## Related Documentation

- [System Architecture Overview](overview.md)
- [Backend Architecture](backend.md)
- [Frontend Architecture](frontend.md)
- [Database Schema](database.md)
- [Development Guide](../development/contributing.md)
