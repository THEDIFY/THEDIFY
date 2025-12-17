# 🔌 MenTora API Documentation

**Version:** v1.0.0  
**Base URL:** `https://api.mentora.app/api/v1` (Production) | `http://localhost:8000/api/v1` (Development)  
**Protocol:** REST over HTTPS  
**Authentication:** JWT Bearer Token

---

## 📋 Table of Contents

- [Overview](#overview)
- [Authentication](#authentication)
- [API Endpoints](#api-endpoints)
  - [Authentication](#authentication-endpoints)
  - [Courses](#courses-endpoints)
  - [Learning Paths](#learning-paths-endpoints)
  - [Progress Tracking](#progress-tracking-endpoints)
  - [Admin](#admin-endpoints)
- [Data Models](#data-models)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)
- [Webhooks](#webhooks)

---

## Overview

The MenTora API is a RESTful API built with FastAPI that provides programmatic access to all platform features. It supports:

- **User Authentication:** JWT tokens and OAuth (Google)
- **Course Management:** Browse, search, and enroll in courses
- **Learning Progress:** Track completion, quizzes, and exercises
- **Admin Functions:** Create courses using DSL, manage content
- **Payment Integration:** Stripe webhooks for subscription management

### API Characteristics

- **Async/Await:** All endpoints are asynchronous for high performance
- **Type Safety:** Pydantic models for request/response validation
- **Auto Documentation:** Swagger UI at `/docs` and ReDoc at `/redoc`
- **CORS Enabled:** Configured origins for web access
- **Rate Limited:** Protection against abuse

---

## Authentication

### Authentication Methods

MenTora supports two authentication methods:

1. **JWT Token Authentication** (Primary)
2. **Google OAuth 2.0** (Social login)

### Getting a JWT Token

#### POST /api/v1/auth/login

**Description:** Authenticate with email and password to receive a JWT token.

**Request:**
```bash
curl -X POST "https://api.mentora.app/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepassword"
  }'
```

**Request Body:**
```json
{
  "email": "string (email format, required)",
  "password": "string (min 8 chars, required)"
}
```

**Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": {
    "id": "user_12345",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "student"
  }
}
```

**Status Codes:**
- `200` - Success
- `400` - Invalid credentials
- `422` - Validation error (invalid email format, etc.)
- `429` - Too many requests

### Using the JWT Token

Include the token in the `Authorization` header for all authenticated requests:

```bash
curl -X GET "https://api.mentora.app/api/v1/auth/me" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Token Expiration

- **Default Expiration:** 1 hour (3600 seconds)
- **Refresh:** Use the refresh token endpoint (if implemented)
- **Re-authentication:** Required after expiration

---

## API Endpoints

### Authentication Endpoints

#### POST /api/v1/auth/register

**Description:** Create a new user account.

**Request:**
```json
{
  "email": "newuser@example.com",
  "password": "SecureP@ssw0rd",
  "name": "Jane Smith",
  "agree_to_terms": true
}
```

**Response (201 Created):**
```json
{
  "id": "user_67890",
  "email": "newuser@example.com",
  "name": "Jane Smith",
  "created_at": "2024-12-17T10:30:00Z"
}
```

**Validation Rules:**
- Email must be valid and unique
- Password: min 8 characters, must include uppercase, lowercase, number
- Name: 2-100 characters
- Terms agreement required

---

#### GET /api/v1/auth/me

**Description:** Get the currently authenticated user's profile.

**Request:**
```bash
curl -X GET "https://api.mentora.app/api/v1/auth/me" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response (200 OK):**
```json
{
  "id": "user_12345",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "student",
  "enrollment_count": 5,
  "completed_courses": 2,
  "current_streak": 7,
  "created_at": "2024-01-15T08:00:00Z"
}
```

---

#### POST /api/v1/auth/google

**Description:** Authenticate using Google OAuth token.

**Request:**
```json
{
  "token": "google_oauth_token_here"
}
```

**Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "user_12345",
    "email": "user@gmail.com",
    "name": "John Doe"
  }
}
```

---

### Courses Endpoints

#### GET /api/v1/courses/search

**Description:** Search and filter courses with pagination.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `category` | string | No | Filter by category (e.g., "AI", "Machine Learning") |
| `difficulty` | string | No | Filter by difficulty: "Beginner", "Intermediate", "Advanced" |
| `search_query` | string | No | Full-text search in title and description (min 2 chars) |
| `tag` | string | No | Filter by tag (e.g., "python", "computer-vision") |
| `limit` | integer | No | Results per page (default: 20, max: 100) |
| `cursor` | string | No | Continuation token for next page |

**Request:**
```bash
curl -X GET "https://api.mentora.app/api/v1/courses/search?category=AI&difficulty=Beginner&limit=20" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response (200 OK):**
```json
{
  "courses": [
    {
      "id": "course_001",
      "title": "Introduction to Machine Learning",
      "description": "Learn the fundamentals of ML with hands-on projects",
      "category": "AI",
      "difficulty": "Beginner",
      "estimated_hours": 15,
      "enrollment_count": 1243,
      "rating": 4.7,
      "thumbnail_url": "https://cdn.mentora.app/courses/ml-intro.jpg",
      "tags": ["python", "machine-learning", "beginner"],
      "instructor": {
        "id": "instructor_01",
        "name": "Dr. Sarah Chen"
      },
      "modules_count": 8,
      "lessons_count": 45
    }
  ],
  "next_cursor": "eyJpZCI6ImNvdXJzZV8wMjAifQ==",
  "has_more": true,
  "total_count": 156
}
```

---

#### GET /api/v1/courses/{course_id}

**Description:** Get detailed information about a specific course.

**Path Parameters:**
- `course_id` (string, required): The unique course identifier

**Request:**
```bash
curl -X GET "https://api.mentora.app/api/v1/courses/course_001" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response (200 OK):**
```json
{
  "id": "course_001",
  "title": "Introduction to Machine Learning",
  "description": "Comprehensive ML course with theory and practice...",
  "category": "AI",
  "difficulty": "Beginner",
  "estimated_hours": 15,
  "enrollment_count": 1243,
  "rating": 4.7,
  "thumbnail_url": "https://cdn.mentora.app/courses/ml-intro.jpg",
  "tags": ["python", "machine-learning", "beginner"],
  "modules": [
    {
      "id": "module_001",
      "title": "Introduction to ML",
      "description": "Understand what machine learning is",
      "order": 1,
      "estimated_hours": 2,
      "lessons": [
        {
          "id": "lesson_001",
          "title": "What is Machine Learning?",
          "type": "video",
          "duration_minutes": 15,
          "order": 1
        }
      ]
    }
  ],
  "prerequisites": [],
  "learning_outcomes": [
    "Understand ML fundamentals",
    "Build your first ML model",
    "Evaluate model performance"
  ],
  "created_at": "2024-01-15T00:00:00Z",
  "updated_at": "2024-12-01T10:00:00Z"
}
```

---

#### GET /api/v1/courses/categories

**Description:** Get all available course categories with counts.

**Response (200 OK):**
```json
{
  "categories": [
    {
      "name": "AI",
      "display_name": "Artificial Intelligence",
      "course_count": 45,
      "icon": "🤖"
    },
    {
      "name": "Machine Learning",
      "display_name": "Machine Learning",
      "course_count": 38,
      "icon": "📊"
    },
    {
      "name": "Deep Learning",
      "display_name": "Deep Learning",
      "course_count": 22,
      "icon": "🧠"
    }
  ]
}
```

---

#### GET /api/v1/courses/recommendations

**Description:** Get personalized course recommendations based on user's enrolled courses.

**Query Parameters:**
- `limit` (integer, optional): Number of recommendations (default: 10)

**Response (200 OK):**
```json
{
  "recommendations": [
    {
      "id": "course_025",
      "title": "Advanced Neural Networks",
      "reason": "Based on your progress in 'Introduction to Machine Learning'",
      "match_score": 0.92
    }
  ],
  "based_on": [
    "course_001",
    "course_003"
  ]
}
```

---

### Learning Paths Endpoints

#### GET /api/v1/learning-paths/{path_id}

**Description:** Get a learning path with visual node positions.

**Path Parameters:**
- `path_id` (string, required): Learning path ID or slug

**Request:**
```bash
curl -X GET "https://api.mentora.app/api/v1/learning-paths/ml-fundamentals" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response (200 OK):**
```json
{
  "id": "path_001",
  "course_id": "course_001",
  "slug": "ml-fundamentals",
  "title": "Machine Learning Fundamentals",
  "description": "Complete learning path for ML basics",
  "total_lessons": 45,
  "estimated_weeks": 6,
  "modules": [
    {
      "id": "module_001",
      "title": "Introduction",
      "lessons": [
        {
          "id": "lesson_001",
          "title": "What is ML?",
          "order": 1
        }
      ]
    }
  ],
  "path_nodes": [
    {
      "module_id": "module_001",
      "lesson_id": "lesson_001",
      "x_position": 0.5,
      "y_position": 0.1,
      "dependencies": []
    }
  ]
}
```

---

#### POST /api/v1/learning-paths/enroll

**Description:** Enroll the authenticated user in a course/learning path.

**Request:**
```json
{
  "course_id": "course_001"
}
```

**Response (201 Created):**
```json
{
  "enrollment_id": "enroll_12345",
  "course_id": "course_001",
  "user_id": "user_12345",
  "enrolled_at": "2024-12-17T10:30:00Z",
  "progress": 0
}
```

---

#### POST /api/v1/learning-paths/{path_id}/progress

**Description:** Update progress for a lesson in a learning path.

**Path Parameters:**
- `path_id` (string, required): Learning path ID

**Request:**
```json
{
  "lesson_id": "lesson_001",
  "completed": true,
  "time_spent_seconds": 900,
  "quiz_score": 85
}
```

**Response (200 OK):**
```json
{
  "lesson_id": "lesson_001",
  "completed": true,
  "completed_at": "2024-12-17T11:00:00Z",
  "quiz_score": 85,
  "overall_progress": 15
}
```

---

### Progress Tracking Endpoints

#### GET /api/v1/progress/{course_id}

**Description:** Get user's progress for a specific course.

**Response (200 OK):**
```json
{
  "course_id": "course_001",
  "user_id": "user_12345",
  "overall_progress": 45,
  "completed_lessons": 20,
  "total_lessons": 45,
  "recent_lessons": [
    {
      "lesson_id": "lesson_020",
      "title": "Supervised Learning",
      "completed_at": "2024-12-17T10:00:00Z"
    }
  ],
  "lesson_progress": {
    "lesson_001": {
      "completed": true,
      "quiz_score": 90,
      "time_spent_seconds": 1200
    }
  },
  "last_active": "2024-12-17T10:30:00Z",
  "estimated_completion_date": "2025-01-30T00:00:00Z"
}
```

---

#### GET /api/v1/progress/{course_id}/continue

**Description:** Get the next lesson to continue learning.

**Response (200 OK):**
```json
{
  "next_lesson": {
    "id": "lesson_021",
    "title": "Decision Trees",
    "module_id": "module_003",
    "module_title": "Classification Algorithms",
    "order": 21
  },
  "progress": 44.4
}
```

---

#### GET /api/v1/dashboard/stats

**Description:** Get dashboard statistics for the authenticated user.

**Response (200 OK):**
```json
{
  "enrolled_courses": [
    {
      "course_id": "course_001",
      "title": "Introduction to ML",
      "progress": 45,
      "last_accessed": "2024-12-17T10:00:00Z"
    }
  ],
  "recent_activity": [
    {
      "lesson_id": "lesson_020",
      "lesson_title": "Supervised Learning",
      "course_title": "Introduction to ML",
      "completed_at": "2024-12-17T09:30:00Z"
    }
  ],
  "achievements": {
    "total_points": 450,
    "badges": ["first-course", "week-streak-7"],
    "courses_completed": 2
  },
  "weekly_progress": {
    "lessons_completed": 5,
    "time_spent_minutes": 180,
    "current_streak": 7
  }
}
```

---

### Admin Endpoints

**Note:** All admin endpoints require `role: admin` in the JWT token.

#### POST /api/v1/admin/learning-paths

**Description:** Create a new course from DSL (Domain-Specific Language).

**Request:**
```json
{
  "title": "Introduction to Neural Networks",
  "description": "Learn the basics of neural networks",
  "category": "Deep Learning",
  "difficulty": "Intermediate",
  "dsl_content": "# Module 1: Basics\n\n## Lesson 1: Introduction\n\n[video:https://youtube.com/watch?v=abc123]\n\nNeural networks are...\n\n[quiz]\nQ: What is a neuron?\nA: A computational unit [correct]\nB: A database\n[/quiz]"
}
```

**Response (201 Created):**
```json
{
  "id": "course_100",
  "title": "Introduction to Neural Networks",
  "modules_count": 1,
  "lessons_count": 1,
  "created_at": "2024-12-17T11:00:00Z"
}
```

---

#### POST /api/v1/admin/learning-paths/validate

**Description:** Validate DSL syntax without creating a course.

**Request:**
```json
{
  "dsl_content": "# Module 1\n## Lesson 1\nContent here"
}
```

**Response (200 OK - Valid):**
```json
{
  "valid": true,
  "modules": 1,
  "lessons": 1
}
```

**Response (400 Bad Request - Invalid):**
```json
{
  "valid": false,
  "errors": [
    {
      "line": 5,
      "message": "Invalid quiz syntax: missing [/quiz] closing tag"
    }
  ]
}
```

---

#### POST /api/v1/admin/learning-paths/preview

**Description:** Generate HTML preview of DSL content.

**Request:**
```json
{
  "dsl_content": "# Module 1\n## Lesson 1\nContent"
}
```

**Response (200 OK):**
```json
{
  "html": "<div class='module'><h1>Module 1</h1>...</div>",
  "css": ".module { ... }"
}
```

---

## Data Models

### User Model

```typescript
interface User {
  id: string;
  email: string;
  name: string;
  role: "student" | "instructor" | "admin";
  enrollment_count: number;
  completed_courses: number;
  current_streak: number;
  created_at: string; // ISO 8601
}
```

### Course Model

```typescript
interface Course {
  id: string;
  title: string;
  description: string;
  category: string;
  difficulty: "Beginner" | "Intermediate" | "Advanced";
  estimated_hours: number;
  enrollment_count: number;
  rating: number; // 0-5
  thumbnail_url: string;
  tags: string[];
  modules: Module[];
  created_at: string;
  updated_at: string;
}
```

### Module Model

```typescript
interface Module {
  id: string;
  title: string;
  description: string;
  order: number;
  estimated_hours: number;
  lessons: Lesson[];
}
```

### Lesson Model

```typescript
interface Lesson {
  id: string;
  title: string;
  type: "video" | "text" | "quiz" | "exercise";
  duration_minutes: number;
  order: number;
  content: ContentItem[];
}
```

### ContentItem Types

```typescript
type ContentItem = VideoContent | TextContent | QuizContent | ExerciseContent;

interface VideoContent {
  type: "video";
  url: string; // YouTube or Vimeo URL
  thumbnail?: string;
  duration_seconds: number;
}

interface TextContent {
  type: "text";
  markdown: string;
}

interface QuizContent {
  type: "quiz";
  questions: QuizQuestion[];
  passing_score: number; // 0-100
}

interface QuizQuestion {
  id: string;
  question: string;
  options: string[];
  correct_index: number;
  explanation?: string;
}

interface ExerciseContent {
  type: "exercise";
  language: "python" | "javascript";
  starter_code: string;
  expected_output: string;
  instructions: string;
  hints: string[];
}
```

---

## Error Handling

### Standard Error Response

All errors follow this format:

```json
{
  "detail": "Error message here",
  "error_code": "VALIDATION_ERROR",
  "timestamp": "2024-12-17T11:00:00Z",
  "path": "/api/v1/courses/search"
}
```

### HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| `200` | OK | Request succeeded |
| `201` | Created | Resource created successfully |
| `400` | Bad Request | Invalid request data |
| `401` | Unauthorized | Missing or invalid authentication |
| `403` | Forbidden | Insufficient permissions |
| `404` | Not Found | Resource not found |
| `422` | Unprocessable Entity | Validation error |
| `429` | Too Many Requests | Rate limit exceeded |
| `500` | Internal Server Error | Server error |
| `503` | Service Unavailable | Service temporarily down |

### Error Codes

| Code | Description |
|------|-------------|
| `VALIDATION_ERROR` | Request validation failed |
| `AUTH_FAILED` | Authentication failed |
| `PERMISSION_DENIED` | User lacks required permissions |
| `RESOURCE_NOT_FOUND` | Requested resource doesn't exist |
| `RATE_LIMIT_EXCEEDED` | Too many requests |
| `DUPLICATE_RESOURCE` | Resource already exists |
| `EXTERNAL_SERVICE_ERROR` | Third-party service error (Stripe, etc.) |

---

## Rate Limiting

**Default Limits:**
- **Authenticated Users:** 100 requests per minute
- **Anonymous Users:** 20 requests per minute
- **Admin Endpoints:** 50 requests per minute

**Rate Limit Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1702819200
```

**429 Response:**
```json
{
  "detail": "Rate limit exceeded. Try again in 45 seconds.",
  "error_code": "RATE_LIMIT_EXCEEDED",
  "retry_after": 45
}
```

---

## Webhooks

### Stripe Webhooks

**Endpoint:** `POST /api/v1/webhooks/stripe`

**Events Handled:**
- `checkout.session.completed` - Payment successful, activate subscription
- `customer.subscription.updated` - Subscription changed
- `customer.subscription.deleted` - Subscription cancelled
- `invoice.payment_failed` - Payment failed

**Signature Verification:**
All webhooks are verified using Stripe webhook signature in the `Stripe-Signature` header.

---

## Interactive Documentation

- **Swagger UI:** http://localhost:8000/docs (when running locally)
- **ReDoc:** http://localhost:8000/redoc (when running locally)

Both provide:
- Interactive API testing
- Request/response examples
- Schema definitions
- Authentication testing

---

## Support

For API issues or questions:
- **Email:** rasanti2008@gmail.com
- **GitHub Issues:** https://github.com/THEDIFY/THEDIFY/issues
- **Documentation:** See `/documentation` folder

---

**Last Updated:** December 17, 2024  
**API Version:** v1.0.0  
**Changelog:** See [CHANGELOG.md](CHANGELOG.md)
