# Real-time AI Coaching Feedback API

## Overview

The Real-time AI Coaching Feedback system provides natural language question-answering for coaches during live sessions. It uses RAG (Retrieval-Augmented Generation) to provide evidence-based recommendations with drill suggestions and calendar integration.

## Features

- **Natural Language Questions**: Ask questions in plain English during live sessions
- **Evidence-Based Recommendations**: All advice backed by RAG contexts from vector database
- **Age-Appropriate Safety Filters**: Automatic U13 safety checks and developmental guidance
- **Structured Drill Suggestions**: 2-3 specific drills with focus points and duration
- **Calendar Integration**: Automatic calendar event suggestions for recommended drills
- **Confidence Scoring**: Each response includes a confidence score (0.0-1.0)
- **Response Time**: Target <10 seconds for feedback generation

## Architecture

```
Coach Question → Frontend → Backend API → RAG Pipeline → LLM → Structured Response
                              |              |            |           |
                         live_bp        Vector Search  GPT-4    Drill Suggestions
                                       (Azure Search)         + Evidence Refs
```

## API Endpoint

### POST `/api/live/<session_id>/feedback`

Generate AI coaching feedback for a live session using natural language questions.

#### Request Headers
```
Content-Type: application/json
Authorization: Bearer <api_key>
```

#### Request Body
```json
{
  "player_track_id": 1,                    // Required: player to analyze
  "question": "How can player improve sprint speed?",  // Required: natural language question
  "window_id": "s123-win-0001",           // Optional: specific time window
  "player_context": {                     // Optional: override player info
    "age": 13,
    "position": "winger",
    "dominant_foot": "right",
    "skill_level": "intermediate"
  },
  "session_context": {                    // Optional: override session metrics
    "max_speed": 7.2,
    "avg_speed": 4.1,
    "activity_type": "training",
    "ball_contacts": 15
  }
}
```

#### Response (Success - 200 OK)
```json
{
  "success": true,
  "feedback": {
    "advice": "Focus on improving sprint technique through proper form drills. The player shows good speed potential but would benefit from enhanced knee drive and forward lean during acceleration phases.",
    "drills": [
      {
        "name": "High Knee Drive Drill",
        "description": "Practice exaggerated knee lift during acceleration to improve sprint form and power generation",
        "duration": "3 x 20m",
        "rest": "90 seconds between sets",
        "focus_points": [
          "Drive knees up to hip height",
          "Maintain forward lean from ankles",
          "Quick ground contact time"
        ]
      },
      {
        "name": "A-Skip Progression",
        "description": "Dynamic warm-up drill that reinforces proper sprint mechanics",
        "duration": "2 x 30m",
        "rest": "60 seconds",
        "focus_points": [
          "Rhythmic skipping motion",
          "Active ankle dorsiflexion",
          "Coordinated arm swing"
        ]
      }
    ],
    "evidence_refs": [
      {
        "source": "DOC1 - Professional sprint training methodology",
        "relevance": "Shows that knee drive improvement correlates with 15-20% speed gains in youth athletes"
      },
      {
        "source": "DOC3 - U13 training session data",
        "relevance": "Similar players showed improvements after form-focused sprint drills"
      }
    ],
    "confidence": 0.87,
    "suggested_calendar_action": {
      "event_type": "training",
      "title": "Focused Sprint Technique Training",
      "description": "Practice drills: High Knee Drive Drill, A-Skip Progression",
      "duration_minutes": 30,
      "suggested_slots": [
        "2025-10-14T16:00:00+00:00",
        "2025-10-15T16:00:00+00:00"
      ],
      "drills": ["High Knee Drive Drill", "A-Skip Progression"]
    },
    "developmental_note": "Focus on technique and fun over performance metrics for U13 age group. Emphasize skill development and positive reinforcement."
  },
  "metadata": {
    "feedback_id": "fb_abc123",
    "contexts_count": 5,
    "model_used": "gpt-4o",
    "generated_at": "2025-10-13T10:30:00Z"
  }
}
```

#### Response (Error - 400 Bad Request)
```json
{
  "error": "player_track_id is required"
}
```

#### Response (Error - 401 Unauthorized)
```json
{
  "error": "Invalid or missing authorization"
}
```

## Configuration

### Environment Variables

Add to your `.env` file:

```bash
# Azure OpenAI Configuration
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_KEY=your_key_here
AZURE_OPENAI_DEPLOYMENT=gpt-4o
AZURE_OPENAI_API_VERSION=2024-02-15-preview

# Azure Cognitive Search (for RAG)
AZURE_SEARCH_ENDPOINT=https://your-search.search.windows.net
AZURE_SEARCH_KEY=your_search_key_here
AZURE_SEARCH_INDEX=axolotl-sessions

# Embedding Configuration
EMBEDDING_MODEL=text-embedding-3-large
EMBEDDING_DIMENSION=3072

# Feedback Configuration
FEEDBACK_RESPONSE_TIMEOUT=10  # seconds
FEEDBACK_MAX_CONTEXTS=5
FEEDBACK_MIN_SIMILARITY=0.7
```

### Model Configuration

**MODEL**: 
- Azure OpenAI GPT-4 (or GPT-4o) for advice generation
- text-embedding-3-large for query and document embeddings
- Azure Cognitive Search for vector similarity search

**DATA**:
- Vector database with indexed sessions (match_segment, training_session types)
- Professional football coaching content (knowledge_base type)
- Youth development pedagogy documents
- U13-specific training protocols

**TRAINING/BUILD RECIPE**:
```bash
# Index existing sessions
python ingest/session_indexer.py --session_path biomech/sessions --batch-mode

# Index knowledge base
python ingest/knowledge_ingest.py --source docs/coaching_guides/

# Validate retrieval
python scripts/validate_rag_retrieval.py --test-queries tests/fixtures/sample_questions.json
```

**EVAL & ACCEPTANCE**:
- Retrieval precision@5 ≥ 0.80 (relevant contexts)
- Response time p95 < 10 seconds
- Coach satisfaction ≥ 4.0/5 for advice relevance
- Drill acceptance rate ≥ 70%
- Zero inappropriate recommendations (U13 safety check)

## Frontend Integration

### Using the FeedbackPanel Component

```typescript
import FeedbackPanel from '@/components/FeedbackPanel'

function LiveAnalysis() {
  return (
    <div className="live-analysis">
      {/* Other live analysis components */}
      
      <FeedbackPanel />
    </div>
  )
}
```

### Quick Question Examples

The FeedbackPanel provides quick question buttons for common queries:
- "How can this player improve sprint speed?"
- "What drills would help ball control?"
- "How to improve shooting technique?"
- "Ways to develop better positioning?"

### Custom Questions

Coaches can also type their own natural language questions:
- "What is the best way to develop this player's weak foot?"
- "How can we improve their decision making in the final third?"
- "What exercises would help with ball retention under pressure?"

## Response Structure

### Advice
- **Type**: String
- **Length**: 2-3 sentences
- **Content**: Clear, actionable coaching advice based on RAG evidence
- **Focus**: Age-appropriate, technique-focused recommendations

### Drills
- **Type**: Array of drill objects
- **Count**: 2-3 drills per response
- **Structure**: Each drill includes:
  - `name`: Short descriptive title
  - `description`: Detailed explanation of the drill
  - `duration`: Training duration (e.g., "3 x 20m")
  - `rest`: Rest period between sets
  - `focus_points`: Array of 2-4 key coaching cues

### Evidence References
- **Type**: Array of reference objects
- **Purpose**: Traceability to RAG contexts
- **Structure**: Each reference includes:
  - `source`: Document identifier or title
  - `relevance`: Why this evidence supports the advice

### Confidence Score
- **Type**: Float (0.0-1.0)
- **Interpretation**:
  - 0.8-1.0: High confidence, strong evidence
  - 0.6-0.8: Moderate confidence, good evidence
  - 0.4-0.6: Lower confidence, limited evidence
  - <0.4: Low confidence, may need review

### Suggested Calendar Action
- **Type**: Object or null
- **Purpose**: Automatically suggest training sessions
- **Structure**:
  - `event_type`: "training"
  - `title`: Event title
  - `description`: Event description with drill list
  - `duration_minutes`: Estimated duration
  - `suggested_slots`: Array of ISO 8601 timestamps
  - `drills`: Array of drill names

## Safety Features

### U13 Age Group Protections

The system automatically applies safety filters for youth players:

1. **Keyword Filtering**: Blocks inappropriate terms like:
   - "aggressive", "extreme", "maximum intensity"
   - "exhaustion", "maximum effort", "all-out"
   - "until failure", "maximum load"

2. **Confidence Adjustment**: Reduces confidence scores when unsafe keywords detected

3. **Developmental Notes**: Adds age-appropriate guidance:
   - "Focus on technique and fun over performance metrics"
   - "Emphasize skill development and positive reinforcement"

4. **Medical Disclaimer**: No medical advice or injury treatment recommendations

## Testing

### Unit Tests

Run coaching feedback unit tests:
```bash
cd /home/runner/work/axolotl/axolotl
python -m pytest tests/test_feedback_engine.py::TestCoachingQuestionFeedback -v
```

Expected: 4 tests passing
- `test_generate_coaching_feedback_structure`
- `test_safety_filters_applied`
- `test_calendar_event_suggestion`
- `test_parse_duration_helper`

### Integration Tests

Run live feedback endpoint tests:
```bash
python -m pytest tests/test_live_feedback_endpoint.py -v
```

Expected: 9 tests passing (requires full backend environment)

### Manual Testing

```bash
# Test the endpoint with curl
curl -X POST http://localhost:5000/api/live/test_session/feedback \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token" \
  -d '{
    "player_track_id": 1,
    "question": "How can this player improve sprint speed?"
  }'
```

## Performance Considerations

### Response Time Optimization

1. **Context Caching**: Frequently used contexts are cached in memory
2. **Parallel RAG Queries**: Multiple context retrievals run concurrently
3. **LLM Parameters**: Temperature 0.7, max_tokens 1500 balances quality and speed
4. **Top-K Limit**: Retrieves only 5 most relevant contexts to minimize processing

### Cost Management

1. **GPT-4 Usage**: Each request costs ~$0.03-0.05 depending on context size
2. **Embedding Costs**: text-embedding-3-large costs ~$0.0001 per query
3. **Search Costs**: Azure Cognitive Search charges based on queries/second

**Recommendation**: Monitor usage and implement rate limiting for production

## Troubleshooting

### "Feedback engine not available"

**Cause**: OpenAI client not properly initialized

**Solution**: Check environment variables:
```bash
echo $AZURE_OPENAI_ENDPOINT
echo $AZURE_OPENAI_KEY
```

### "Low confidence scores (<0.5)"

**Cause**: Insufficient or irrelevant RAG contexts

**Solutions**:
1. Index more training sessions and knowledge base documents
2. Improve query formulation
3. Lower `FEEDBACK_MIN_SIMILARITY` threshold

### "Response too slow (>10 seconds)"

**Causes**:
1. Large context window
2. Network latency to Azure
3. High LLM load

**Solutions**:
1. Reduce `FEEDBACK_MAX_CONTEXTS` to 3
2. Use closer Azure region
3. Implement request queuing

## Examples

### Example 1: Sprint Speed Improvement

**Question**: "How can this player improve sprint speed?"

**Context**: U13 winger, max_speed: 7.2 m/s

**Response Highlights**:
- Advice focuses on technique over raw power
- Drills include form-focused exercises (knee drive, A-skips)
- Evidence from youth training data and professional methodology
- 30-minute calendar suggestion with two drill slots

### Example 2: Ball Control

**Question**: "What drills would help ball control?"

**Context**: U13 midfielder, ball_contacts: 15

**Response Highlights**:
- Advice emphasizes close control and first touch
- Drills include cone weaving and wall passing
- Evidence from La Masia methodology
- Focus points on head up awareness and body positioning

### Example 3: Positioning

**Question**: "Ways to develop better positioning?"

**Context**: U13 defender, position: center_back

**Response Highlights**:
- Advice covers tactical awareness and spatial understanding
- Drills include shadow defending and small-sided games
- Evidence from match analysis data
- Emphasis on reading game situations

## Related Documentation

- [RAG Schema Design](./rag_schema.md) - Vector database structure
- [LLM Implementation](../README_LLM_IMPLEMENTATION.md) - Feedback engine details
- [Prompt Templates](../src/axolotl/llm/templates/) - Template specifications
- [User Stories](./user_stories/US02_instruction.md) - Original requirements

## Support

For issues or questions:
1. Check logs: `./logs/axolotl.log`
2. Review configuration: Environment variables properly set
3. Test components: Run unit tests to verify functionality
4. Contact: File an issue on GitHub

## Future Enhancements

- [ ] Multi-language support (Spanish, French, German)
- [ ] Video clip references in evidence
- [ ] Progressive drill difficulty scaling based on player improvement
- [ ] Team-level feedback (multiple players simultaneously)
- [ ] Voice input for questions during live sessions
- [ ] Real-time feedback streaming (progressive response)
