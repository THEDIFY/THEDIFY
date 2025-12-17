# EDIFY API Documentation

## Overview

The EDIFY API provides programmatic access to the AI-powered education platform. Built with FastAPI, it offers a RESTful interface for chat interactions, user management, learning analytics, and administrative functions.

**Base URL:** `https://api.edify.ai/v1`  
**Authentication:** Bearer token (JWT) or API Key  
**Format:** JSON  
**Rate Limiting:** 100 requests/minute (authenticated), 20 requests/minute (anonymous)

---

## Authentication

### OAuth 2.0 + JWT

EDIFY uses OAuth 2.0 for user authentication and JWT tokens for session management.

#### Login with Google

```http
POST /auth/google/login
Content-Type: application/json

{
  "credential": "google_oauth_token",
  "redirect_uri": "https://your-app.com/callback"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 86400,
  "refresh_token": "refresh_token_here",
  "user": {
    "id": "user_uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "created_at": "2025-01-15T10:30:00Z"
  }
}
```

#### Refresh Token

```http
POST /auth/refresh
Content-Type: application/json
Authorization: Bearer <access_token>

{
  "refresh_token": "refresh_token_here"
}
```

### API Key Authentication

For programmatic access, use API keys:

```http
GET /api/endpoint
X-API-Key: your_api_key_here
```

---

## Endpoints

### Chat & RAG

#### POST /api/chat

Send a question to the AI tutor and receive a personalized response with citations.

**Request:**
```http
POST /api/chat
Content-Type: application/json
Authorization: Bearer <token>

{
  "query": "Explain the concept of gradient descent in machine learning",
  "user_id": "user_uuid",
  "context": {
    "subject": "machine_learning",
    "difficulty_level": "intermediate",
    "learning_goal": "understand_optimization"
  },
  "conversation_id": "optional_conversation_uuid",
  "include_citations": true
}
```

**Response:**
```json
{
  "conversation_id": "conv_uuid",
  "response": {
    "answer": "Gradient descent is an optimization algorithm used to minimize a function by iteratively moving in the direction of steepest descent...",
    "citations": [
      {
        "source": "Introduction to Machine Learning",
        "author": "Andrew Ng",
        "page": 42,
        "relevance_score": 0.95,
        "excerpt": "Gradient descent iteratively adjusts parameters..."
      },
      {
        "source": "Deep Learning Fundamentals",
        "author": "Ian Goodfellow",
        "page": 87,
        "relevance_score": 0.89,
        "excerpt": "The learning rate determines step size..."
      }
    ],
    "confidence": 0.92,
    "related_topics": ["backpropagation", "learning_rate", "optimization"]
  },
  "metadata": {
    "processing_time_ms": 1850,
    "tokens_used": 487,
    "model": "gpt-4",
    "rag_chunks_retrieved": 10,
    "rag_chunks_used": 5
  },
  "timestamp": "2025-12-17T14:30:00Z"
}
```

**Status Codes:**
- `200` - Success
- `400` - Invalid request (missing required fields)
- `401` - Unauthorized (invalid/expired token)
- `429` - Rate limit exceeded
- `500` - Internal server error

---

#### GET /api/conversations/{conversation_id}

Retrieve conversation history.

**Request:**
```http
GET /api/conversations/conv_uuid
Authorization: Bearer <token>
```

**Response:**
```json
{
  "conversation_id": "conv_uuid",
  "user_id": "user_uuid",
  "created_at": "2025-12-17T10:00:00Z",
  "updated_at": "2025-12-17T14:30:00Z",
  "messages": [
    {
      "role": "user",
      "content": "What is machine learning?",
      "timestamp": "2025-12-17T10:00:00Z"
    },
    {
      "role": "assistant",
      "content": "Machine learning is a subset of AI...",
      "citations": [...],
      "timestamp": "2025-12-17T10:00:02Z"
    }
  ],
  "metadata": {
    "message_count": 12,
    "total_tokens": 3456,
    "subjects": ["machine_learning", "AI"],
    "avg_response_time_ms": 1920
  }
}
```

---

#### DELETE /api/conversations/{conversation_id}

Delete a conversation and all associated messages.

**Request:**
```http
DELETE /api/conversations/conv_uuid
Authorization: Bearer <token>
```

**Response:**
```json
{
  "message": "Conversation deleted successfully",
  "conversation_id": "conv_uuid"
}
```

---

### User Management

#### GET /api/users/me

Get current user profile and learning statistics.

**Request:**
```http
GET /api/users/me
Authorization: Bearer <token>
```

**Response:**
```json
{
  "user": {
    "id": "user_uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "avatar_url": "https://storage.edify.ai/avatars/user.jpg",
    "created_at": "2025-01-15T10:30:00Z",
    "subscription": {
      "tier": "premium",
      "status": "active",
      "expires_at": "2026-01-15T10:30:00Z"
    }
  },
  "learning_profile": {
    "subjects": ["machine_learning", "calculus", "python"],
    "skill_level": {
      "machine_learning": "intermediate",
      "calculus": "beginner",
      "python": "advanced"
    },
    "learning_goals": [
      "Master deep learning fundamentals",
      "Build production ML systems"
    ],
    "preferences": {
      "difficulty": "adaptive",
      "language": "en",
      "citation_style": "academic"
    }
  },
  "statistics": {
    "total_conversations": 47,
    "total_questions": 312,
    "total_learning_hours": 28.5,
    "concepts_mastered": 89,
    "average_session_duration_min": 24,
    "retention_rate": 0.78,
    "engagement_score": 0.85
  }
}
```

---

#### PATCH /api/users/me

Update user profile and learning preferences.

**Request:**
```http
PATCH /api/users/me
Content-Type: application/json
Authorization: Bearer <token>

{
  "name": "John Smith",
  "learning_profile": {
    "learning_goals": [
      "Master reinforcement learning",
      "Understand transformer architectures"
    ],
    "preferences": {
      "difficulty": "intermediate",
      "language": "en"
    }
  }
}
```

**Response:**
```json
{
  "message": "Profile updated successfully",
  "user": {
    "id": "user_uuid",
    "name": "John Smith",
    ...
  }
}
```

---

### Analytics & Progress

#### GET /api/analytics/progress

Get detailed learning progress analytics.

**Request:**
```http
GET /api/analytics/progress?timeframe=30d&subjects=machine_learning,python
Authorization: Bearer <token>
```

**Parameters:**
- `timeframe` (optional): `7d`, `30d`, `90d`, `1y`, `all` (default: `30d`)
- `subjects` (optional): Comma-separated list of subjects
- `include_predictions` (optional): `true`/`false` (default: `false`)

**Response:**
```json
{
  "timeframe": "30d",
  "overall_progress": {
    "concepts_learned": 34,
    "practice_sessions": 42,
    "total_hours": 18.5,
    "retention_rate": 0.82,
    "mastery_level": "intermediate",
    "progress_percentage": 68
  },
  "by_subject": {
    "machine_learning": {
      "concepts_learned": 22,
      "mastery_level": "intermediate",
      "time_spent_hours": 12.3,
      "recent_topics": ["gradient_descent", "backpropagation", "CNNs"],
      "recommended_next": ["RNNs", "attention_mechanisms"]
    },
    "python": {
      "concepts_learned": 12,
      "mastery_level": "advanced",
      "time_spent_hours": 6.2,
      "recent_topics": ["decorators", "metaclasses", "async_io"]
    }
  },
  "learning_velocity": {
    "concepts_per_week": 8.5,
    "trend": "improving",
    "acceleration": 1.15
  },
  "predictions": {
    "estimated_time_to_goal": "6 weeks",
    "confidence": 0.87,
    "bottlenecks": ["calculus_prerequisites"],
    "recommendations": [
      "Focus on linear algebra fundamentals",
      "Practice more coding exercises"
    ]
  }
}
```

---

#### GET /api/analytics/performance

Get performance metrics over time.

**Request:**
```http
GET /api/analytics/performance?metric=retention&granularity=weekly
Authorization: Bearer <token>
```

**Parameters:**
- `metric`: `retention`, `engagement`, `accuracy`, `speed`
- `granularity`: `daily`, `weekly`, `monthly`

**Response:**
```json
{
  "metric": "retention",
  "granularity": "weekly",
  "data_points": [
    {
      "period": "2025-W47",
      "value": 0.75,
      "sample_size": 45
    },
    {
      "period": "2025-W48",
      "value": 0.78,
      "sample_size": 52
    },
    {
      "period": "2025-W49",
      "value": 0.82,
      "sample_size": 58
    }
  ],
  "statistics": {
    "mean": 0.78,
    "median": 0.78,
    "std_dev": 0.035,
    "trend": "improving",
    "percentile_rank": 73
  }
}
```

---

### Content Management

#### POST /api/content/upload

Upload educational content for personalized learning (educators/institutions only).

**Request:**
```http
POST /api/content/upload
Content-Type: multipart/form-data
Authorization: Bearer <token>

file: [PDF/DOCX/TXT file]
metadata: {
  "title": "Advanced Calculus Notes",
  "subject": "calculus",
  "author": "Dr. Jane Smith",
  "difficulty": "advanced",
  "tags": ["integrals", "differential_equations"]
}
```

**Response:**
```json
{
  "document_id": "doc_uuid",
  "title": "Advanced Calculus Notes",
  "status": "processing",
  "estimated_completion": "2025-12-17T15:00:00Z",
  "message": "Document uploaded successfully. Processing will complete in ~5 minutes."
}
```

---

#### GET /api/content/status/{document_id}

Check processing status of uploaded content.

**Request:**
```http
GET /api/content/status/doc_uuid
Authorization: Bearer <token>
```

**Response:**
```json
{
  "document_id": "doc_uuid",
  "status": "completed",
  "chunks_created": 247,
  "embeddings_generated": 247,
  "indexed_at": "2025-12-17T14:58:30Z",
  "available_for_search": true
}
```

**Status Values:**
- `uploading` - File upload in progress
- `processing` - Chunking and embedding generation
- `indexing` - Adding to search index
- `completed` - Ready for retrieval
- `failed` - Processing error occurred

---

### Administrative (Educators/Institutions)

#### GET /api/admin/class/{class_id}/analytics

Get class-wide analytics (educators only).

**Request:**
```http
GET /api/admin/class/class_uuid/analytics
Authorization: Bearer <token>
```

**Response:**
```json
{
  "class_id": "class_uuid",
  "name": "Introduction to Machine Learning",
  "enrollment": 45,
  "analytics": {
    "average_progress": 0.72,
    "average_retention": 0.79,
    "engagement_rate": 0.84,
    "completion_rate": 0.68,
    "struggling_students": 7,
    "excelling_students": 12
  },
  "popular_topics": [
    {"topic": "gradient_descent", "queries": 127},
    {"topic": "neural_networks", "queries": 98},
    {"topic": "overfitting", "queries": 76}
  ],
  "common_difficulties": [
    "Calculus prerequisites",
    "Understanding backpropagation",
    "Hyperparameter tuning"
  ],
  "recommendations": [
    "Additional linear algebra review sessions recommended",
    "Consider interactive coding exercises for backpropagation"
  ]
}
```

---

## Error Responses

All errors follow a consistent format:

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Missing required field: query",
    "details": {
      "field": "query",
      "requirement": "string, non-empty"
    }
  },
  "request_id": "req_uuid",
  "timestamp": "2025-12-17T14:30:00Z"
}
```

### Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `INVALID_REQUEST` | 400 | Malformed request or missing required fields |
| `UNAUTHORIZED` | 401 | Invalid or expired authentication token |
| `FORBIDDEN` | 403 | Insufficient permissions for requested resource |
| `NOT_FOUND` | 404 | Requested resource does not exist |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests in time window |
| `INTERNAL_ERROR` | 500 | Server-side processing error |
| `SERVICE_UNAVAILABLE` | 503 | Temporary service outage |

---

## Rate Limiting

**Limits:**
- Authenticated users: 100 requests/minute
- Anonymous users: 20 requests/minute
- Educators/Admins: 500 requests/minute

**Headers:**
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1702825800
```

When rate limit is exceeded:
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again in 42 seconds.",
    "retry_after": 42
  }
}
```

---

## Webhooks

EDIFY supports webhooks for real-time event notifications (Enterprise tier).

### Supported Events

- `conversation.created` - New conversation started
- `conversation.completed` - Conversation marked as complete
- `learning.milestone` - Student reached learning milestone
- `content.processed` - Uploaded content processing complete
- `subscription.updated` - User subscription status changed

### Webhook Payload Example

```json
{
  "event": "learning.milestone",
  "timestamp": "2025-12-17T14:30:00Z",
  "data": {
    "user_id": "user_uuid",
    "milestone": "completed_course",
    "course": "Introduction to Machine Learning",
    "achievement_date": "2025-12-17T14:30:00Z"
  }
}
```

---

## SDKs & Libraries

Official SDKs available:

- **Python:** `pip install edify-sdk`
- **JavaScript/TypeScript:** `npm install @edify/sdk`
- **Go:** Coming soon
- **Java:** Coming soon

### Python SDK Example

```python
from edify import EdifyClient

client = EdifyClient(api_key="your_api_key")

# Send a question
response = client.chat.send(
    query="Explain gradient descent",
    user_id="user_uuid",
    include_citations=True
)

print(response.answer)
for citation in response.citations:
    print(f"- {citation.source} (p. {citation.page})")
```

### JavaScript SDK Example

```javascript
import { EdifyClient } from '@edify/sdk';

const client = new EdifyClient({ apiKey: 'your_api_key' });

// Send a question
const response = await client.chat.send({
  query: 'Explain gradient descent',
  userId: 'user_uuid',
  includeCitations: true
});

console.log(response.answer);
response.citations.forEach(citation => {
  console.log(`- ${citation.source} (p. ${citation.page})`);
});
```

---

## OpenAPI Specification

Full OpenAPI 3.0 specification available at:
- **URL:** `https://api.edify.ai/v1/openapi.json`
- **Interactive Docs:** `https://api.edify.ai/v1/docs`
- **ReDoc:** `https://api.edify.ai/v1/redoc`

---

## Best Practices

### Efficient API Usage

1. **Batch Requests:** Group multiple questions in a single conversation
2. **Caching:** Cache responses for frequently asked questions
3. **Pagination:** Use pagination for large result sets
4. **Compression:** Enable gzip compression for responses
5. **Retry Logic:** Implement exponential backoff for retries

### Security

1. **Never expose API keys** in client-side code
2. **Use HTTPS** for all API calls
3. **Rotate API keys** regularly (every 90 days)
4. **Validate input** on both client and server side
5. **Monitor usage** for unusual patterns

### Performance

1. **Minimize payload size** by excluding unnecessary fields
2. **Use appropriate timeouts** (recommended: 30 seconds)
3. **Implement circuit breakers** for production systems
4. **Monitor latency** and set up alerts

---

## Support

**API Issues:** api-support@edify.ai  
**Documentation:** https://docs.edify.ai  
**Status Page:** https://status.edify.ai

---

*API Version: v1.2.0 | Last Updated: December 17, 2025*
