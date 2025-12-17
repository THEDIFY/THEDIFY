# Calendar & Training Planning Implementation

## Overview
The Calendar & Training Planning feature provides an AI-powered calendar system with manual and automated scheduling capabilities. It integrates with the feedback system to convert drill recommendations into scheduled training sessions.

## Architecture

```
Calendar UI → Calendar API → Calendar Service → LLM Proposals → Rules Engine → Database
                                    |                                         |
                              Azure OpenAI                              calendar_events
```

## Features Implemented

### 1. Calendar UI (`app/frontend/src/pages/Calendar.tsx`)

A full-featured calendar interface using FullCalendar library with:

- **Monthly, Weekly, and Daily Views**: Users can switch between different calendar views
- **Interactive Event Creation**: Click on any date to create a new training event
- **Event Display**: All scheduled training sessions displayed with their details
- **AI Recommendations**: Request AI-powered training session proposals
- **Responsive Design**: Mobile-friendly calendar view with Tailwind CSS styling

#### Key Components:

**EventModal**
- Manual event creation with form inputs:
  - Title, Day, Start Time, Duration
  - KPIs to track (comma-separated)
  - Drills to perform (comma-separated)
- Validation and error handling
- Integration with calendar commit endpoint

**AIProposalModal**
- Request AI-generated training recommendations
- Input training goal and time slot preferences
- Display multiple proposals with:
  - Confidence scores
  - Drill recommendations
  - KPIs to track
  - Rationale for each proposal
- Select and commit proposals to calendar

### 2. Backend API Endpoints

All endpoints in `app/backend/blueprints/calendar_bp.py`:

#### `GET /api/user/{user_id}`
Get user profile with calendar events.

**Response:**
```json
{
  "success": true,
  "user": {
    "user_id": "user_123",
    "name": "User Name",
    "age": 16,
    "calendar": [
      {
        "id": "event_123",
        "title": "Technical Skills Training",
        "day": "Monday",
        "start": "16:00",
        "duration_min": 60,
        "kpis": ["ball_control", "passing"],
        "drills": ["Cone weaving", "Wall passing"]
      }
    ]
  }
}
```

#### `POST /api/user/{user_id}/calendar/propose`
Generate AI-powered training schedule proposals.

**Request:**
```json
{
  "slot": {
    "day": "Monday",
    "start": "16:00",
    "duration_min": 60
  },
  "goal": "Improve defensive positioning",
  "constraints": {
    "max_intensity": "medium"
  }
}
```

**Response:**
```json
{
  "success": true,
  "proposals": [
    {
      "id": "proposal_1",
      "title": "Defensive Skills Focus",
      "day": "Monday",
      "start": "16:00",
      "duration_min": 60,
      "kpis": ["defensive_positioning", "tackling"],
      "drills": ["1v1 defensive scenarios", "Marking exercises"],
      "rationale": "Focus on defensive skills based on recent performance",
      "confidence": 0.85
    }
  ],
  "count": 2,
  "generated_at": "2024-10-22T00:00:00"
}
```

#### `POST /api/user/{user_id}/calendar/commit`
Validate and commit a calendar event.

**Request:**
```json
{
  "calendar_event": {
    "title": "Technical Skills Session",
    "day": "Monday",
    "start": "16:00",
    "duration_min": 60,
    "kpis": ["ball_control", "passing"],
    "drills": ["Cone weaving", "Wall passing"]
  },
  "commit": true
}
```

**Response:**
```json
{
  "success": true,
  "event": { /* event data */ },
  "event_id": "event_123",
  "committed_at": "2024-10-22T00:00:00",
  "adjustments": []  // Any rules engine adjustments
}
```

#### `POST /api/user/{user_id}/calendar/llm_modify`
Use LLM to modify calendar based on natural language instructions.

**Request:**
```json
{
  "instruction": "Move Monday's session to Tuesday and focus on defense",
  "commit": true
}
```

#### `DELETE /api/user/{user_id}/calendar/{event_id}`
Delete a calendar event.

**Response:**
```json
{
  "success": true,
  "event_id": "event_123",
  "deleted_at": "2024-10-22T00:00:00"
}
```

### 3. Calendar Service (`app/backend/services/calendar_service.py`)

Core business logic for calendar operations:

**Methods:**
- `get_user_profile(user_id)`: Retrieve user profile with calendar
- `retrieve_session_history(user_id, weeks)`: Get training history for context
- `generate_proposals(user_id, slot, goal, constraints)`: Generate AI proposals
- `save_calendar_event(user_id, event)`: Persist calendar event
- `delete_calendar_event(user_id, event_id)`: Remove calendar event

**LLM Integration:**
- Builds context-aware prompts using user history
- Calls Azure OpenAI API for intelligent proposals
- Falls back to mock proposals if LLM unavailable

### 4. Rules Engine (`app/backend/services/rules_engine.py`)

Validates training proposals against safety rules:

**Validation Rules:**
- **Age-appropriate limits**: Different max durations for different age groups
  - Under 14: 60min max per session, 180min/week max
  - Under 16: 75min max per session, 210min/week max
  - Under 18: 90min max per session, 240min/week max
  - Adult: 120min max per session, 300min/week max
- **Weekly volume limits**: Prevents overtraining
- **Recovery time**: Ensures rest between high-intensity sessions
- **Session intensity**: Checks for dangerous combinations of high-intensity drills

**Methods:**
- `validate_proposals(user, proposals)`: Validate and adjust proposals
- `_validate_single_proposal(age, existing_events, proposal)`: Single proposal validation
- `_apply_adjustments(proposal, violations)`: Auto-fix violations where possible

### 5. WebSocket Calendar Service (`app/backend/services/ws_calendar.py`)

Real-time updates for calendar changes:

**Features:**
- User-specific WebSocket connections
- Broadcast events: `event_created`, `event_updated`, `event_deleted`, `proposals_generated`
- Connection lifecycle management
- Stale connection cleanup

## Dependencies Added

### Frontend (`app/frontend/package.json`)
```json
{
  "@fullcalendar/daygrid": "^6.1.10",
  "@fullcalendar/interaction": "^6.1.10",
  "@fullcalendar/react": "^6.1.10",
  "@fullcalendar/timegrid": "^6.1.10"
}
```

**Note**: FullCalendar v6 includes CSS styles bundled in the JavaScript, so no separate CSS imports are needed.

### Backend
All backend dependencies already included in `requirements.txt`:
- `flask>=3.0.0`
- `openai>=1.0.0` (Azure OpenAI SDK)
- `azure-identity>=1.12.0`

## Configuration

Calendar-specific settings in `app/backend/config.py`:

```python
MAX_WEEKLY_MINUTES = int(os.getenv('MAX_WEEKLY_MINUTES', '240'))
MIN_RECOVERY_DAYS = int(os.getenv('MIN_RECOVERY_DAYS', '1'))
CALENDAR_WS_SECRET = os.getenv('CALENDAR_WS_SECRET', 'calendar-ws-secret')
```

## Testing

Comprehensive test suite in `tests/test_calendar_flow.py`:

**Test Coverage:**
1. User profile retrieval with calendar data
2. AI proposal generation
3. Event commitment and persistence
4. LLM-based calendar modifications
5. Rules engine validation
6. WebSocket connection management
7. Health check endpoint

**Run tests:**
```bash
python tests/test_calendar_flow.py
```

## Usage Examples

### 1. Create Manual Training Event

```typescript
// Frontend - Calendar.tsx
const handleSave = async () => {
  const response = await fetch(`/api/user/${userId}/calendar/commit`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      calendar_event: {
        title: "Speed Training",
        day: "Wednesday",
        start: "17:00",
        duration_min: 45,
        kpis: ["sprint_speed", "acceleration"],
        drills: ["Sprint intervals", "Resistance sprints"]
      },
      commit: true
    })
  });
};
```

### 2. Request AI Recommendations

```typescript
// Frontend - Calendar.tsx
const generateProposals = async () => {
  const response = await fetch(`/api/user/${userId}/calendar/propose`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      slot: {
        day: "Friday",
        start: "16:00",
        duration_min: 60
      },
      goal: "Improve technical ball control",
      constraints: {
        max_intensity: "medium"
      }
    })
  });
};
```

### 3. Delete Event

```typescript
// Frontend - Calendar.tsx
const deleteEvent = async (eventId: string) => {
  const response = await fetch(`/api/user/${userId}/calendar/${eventId}`, {
    method: 'DELETE',
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
};
```

## UI Screenshots

The Calendar page includes:
- Full calendar view with month/week/day switching
- "Add Event" button for manual event creation
- "AI Recommendations" button for automated proposals
- Interactive date selection
- Event display with color coding
- Modal forms for event creation and AI proposals

## Integration Points

### With Feedback System
- Drill recommendations can be converted to calendar events
- KPIs from feedback flow into calendar proposals
- Training history informs AI recommendations

### With Session Analysis
- Calendar events link to actual training sessions
- Performance data feeds back into future proposals
- Training load monitoring for periodization

### With RAG System
- Session history retrieved via SessionIndexer
- Historical performance informs AI recommendations
- Context-aware proposal generation

## Security & Validation

- **Authentication**: All endpoints require Bearer token
- **Input Validation**: JSON schema validation on all inputs
- **Rules Engine**: Automatic safety validation on all events
- **Age-Appropriate**: Training loads adjusted for player age
- **Overtraining Prevention**: Weekly volume limits enforced

## Performance Considerations

- **In-Memory Storage**: Current implementation uses in-memory storage for demo
- **Production**: Should migrate to MongoDB/PostgreSQL for persistence
- **WebSocket Scaling**: Consider Redis pub/sub for multi-server deployments
- **LLM Caching**: Cache common proposals to reduce API costs

## Future Enhancements

- [ ] External calendar sync (Google Calendar, iCal)
- [ ] Recurring events support
- [ ] Team calendar view (coach seeing all players)
- [ ] Training template library
- [ ] Automated periodization planning
- [ ] Integration with wearable device data
- [ ] Calendar analytics dashboard
- [ ] Mobile app native calendar integration

## MODEL, DATA, TRAINING & EVALUATION

**MODEL**: Azure OpenAI GPT-4 via calendar_service for intelligent training proposals

**DATA**: 
- User profiles with age, position, training history
- Calendar events with KPIs, drills, duration
- Training session history from last 12 weeks
- Performance metrics and skill assessments

**TRAINING/BUILD RECIPE**: 
- Frontend: `npm install && npm run build`
- Backend: Install from `requirements.txt`
- No model training required (uses pre-trained GPT-4)

**EVAL & ACCEPTANCE**: 
- ✅ All calendar CRUD operations functional
- ✅ AI proposals relevant to recent performance
- ✅ Rules engine prevents overtraining
- ✅ WebSocket real-time updates working
- ✅ Frontend calendar displays events correctly
- ✅ Mobile-friendly responsive design
- ✅ Validation prevents age-inappropriate training
