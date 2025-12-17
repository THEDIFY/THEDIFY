# RAG Schema Design - Axolotl Football Analysis Platform

## Overview

This document defines the RAG (Retrieval-Augmented Generation) schema design for the Axolotl Football Analysis Platform. The schema supports three distinct document types optimized for vector search and LLM integration, with a focus on football-specific analysis and youth development.

## Architecture Principles

### 1. Document Type Classification
The RAG system is built around three core document types, each optimized for different data sources and use cases:

- **`match_segment`**: Video segments with temporal analysis
- **`training_session`**: Biomechanical data from 3D tracking
- **`knowledge_base`**: Static educational content

### 2. Chunking Strategy

#### Text Content (500-1,000 tokens)
- **Target Size**: 500-1,000 tokens per chunk
- **Overlap**: 150 tokens between adjacent chunks
- **Encoding**: tiktoken for accurate token counting
- **Preservation**: Semantic boundaries respected (sentences, paragraphs)

#### Structured/Numeric Content (3-10 second windows)
Biomechanical and performance data is serialized into human-readable textual summaries:

**Example**:
```
"0:15–0:18 sprint sequence: max_speed=8.9 m/s, left_knee_angle_peak=142°, 
right_knee_angle_peak=138°, stride_length=2.3m, ground_contact_time=180ms, 
acceleration=4.2 m/s², ball_to_feet_distance=0.8m average, technique_score=0.87"
```

This approach ensures:
- Human interpretability for LLM reasoning
- Temporal context preservation
- Rich contextual embeddings
- Efficient retrieval for coaching insights

### 3. Metadata Schema

All document types share a common metadata structure for consistent retrieval:

#### Core Fields
- **`user_id`**: Owner identification
- **`player_id`**: Player being analyzed
- **`session_id`**: Session/match identifier
- **`start_ts`** / **`end_ts`**: Temporal boundaries
- **`doc_type`**: Document type classification
- **`confidence`**: Analysis quality score (0.0-1.0)
- **`embedding_model`**: Model version for compatibility

#### Semantic Tags
Football-specific tags for precise retrieval:
- **Actions**: `pass`, `shot`, `sprint`, `dribble`, `cross`, `tackle`
- **Phases**: `attacking`, `defensive`, `transition`, `set_piece`
- **Locations**: `left_wing`, `right_wing`, `center`, `penalty_area`
- **Tactics**: `pressure`, `counter_attack`, `possession`, `through_ball`

#### Azure Integration
- **`source_blob_url`**: Direct link to source media in Azure Blob Storage
- **`embedding_model`**: Azure OpenAI model version tracking

### 4. Embedding Model Configuration

#### Primary Models (Azure OpenAI)
- **`text-embedding-3-large`**: High precision for critical analysis
- **`text-embedding-3-small`**: Cost-optimized for bulk processing  
- **`text-embedding-ada-002`**: Fallback compatibility

#### Configuration Mapping
```python
EMBEDDING_CONFIG = {
    "production": "text-embedding-3-large",
    "development": "text-embedding-3-small", 
    "batch_processing": "text-embedding-3-small",
    "fallback": "text-embedding-ada-002"
}
```

## Document Type Specifications

### 1. Match Segment Documents

**Purpose**: Analyze video segments from matches (professional or personal games)

**Key Features**:
- Video thumbnails with temporal markers
- Performance metrics aggregation
- Match context (opponent, venue, weather)
- Football-specific event tagging

**Use Cases**:
- "Show me all crosses from the left wing in the last match"
- "Find defensive actions when playing away from home"
- "Analyze sprint patterns during counter-attacks"

**Example Structure**:
```json
{
  "id": "match_seg_20240315_1245_sprint",
  "content": {
    "text": "At 0:23:45, player performs explosive sprint down left wing, reaching 8.7 m/s maximum speed. Cuts inside at penalty area edge, maintaining ball control while defender closes distance...",
    "metrics_summary": {
      "max_speed_ms": 8.7,
      "distance_covered_m": 35.2,
      "touches": 4,
      "crosses_attempted": 1
    },
    "thumbnails": [
      {
        "timestamp": 1425.0,
        "blob_url": "https://storage/thumb_1425.jpg",
        "description": "Initial sprint down left touchline"
      }
    ]
  },
  "tags": ["sprint", "left_wing", "attacking", "cross"]
}
```

### 2. Training Session Documents

**Purpose**: Process biomechanical data from 3-camera training system

**Key Features**:
- Joint angle analysis with clinical precision
- Performance metrics (speed, acceleration, forces)
- Ball interaction tracking
- Left-winger specific technique analysis

**Use Cases**:
- "Show me knee angle patterns during cutting movements"
- "Find training sessions with high sprint intensity"
- "Analyze ball control quality in 1v1 situations"

**Biomechanical Data Processing**:
Raw 3D coordinate data → Joint calculations → Human-readable summaries → Vector embeddings

**Example Structure**:
```json
{
  "id": "training_sess_20240315_0915_cut",
  "content": {
    "digest_text": "3-second cutting sequence showing excellent technique: left knee angle peaked at 142° during plant phase, generating 4.2 m/s² lateral acceleration. Ball control maintained throughout with 0.8m average distance...",
    "biomech_summary": {
      "time_window": {"start_sec": 15.0, "end_sec": 18.0, "duration_sec": 3.0},
      "joint_analysis": {
        "left_knee_angle_peak": 142.0,
        "right_knee_angle_peak": 138.0,
        "trunk_lean_angle": 12.5
      },
      "performance_metrics": {
        "max_speed_ms": 8.9,
        "acceleration_max_ms2": 4.2,
        "stride_length_m": 2.3
      }
    }
  },
  "tags": ["cutting", "technique", "ball_work", "agility"]
}
```

### 3. Knowledge Base Documents

**Purpose**: Store static educational content for coaching insights

**Key Features**:
- Multi-language support
- La Masia methodology alignment
- Position-specific content (left-winger focus)
- Credibility scoring for source reliability

**Use Cases**:
- "Find La Masia training drills for left wingers"
- "Show me tactical guides for possession football"
- "What injury prevention exercises are recommended?"

**Content Categories**:
- Coaching articles and tactical guides
- Training drills and fitness programs
- Rules and regulations
- External research and analysis

**Example Structure**:
```json
{
  "id": "kb_lamasia_cutting_drill_advanced",
  "content": {
    "text": "The 'Corte Messi' drill develops the signature cutting movement used by elite left-wingers. Set up cones in L-shape pattern, 2m apart. Player approaches at moderate pace, plants outside foot...",
    "content_type": "training_drill",
    "title": "La Masia Advanced Cutting Drill for Left Wingers",
    "difficulty_level": "advanced",
    "position_specific": ["left_winger"],
    "la_masia_relevance": {
      "technical_focus": true,
      "tactical_intelligence": true,
      "youth_development": true
    }
  },
  "tags": ["technique", "cutting", "la_masia", "left_winger", "youth_development"]
}
```

## Technical Implementation

### Vector Store Architecture

```python
# Azure Cognitive Search Index Configuration
{
  "name": "axolotl-rag-index",
  "fields": [
    {"name": "id", "type": "Edm.String", "key": True},
    {"name": "content_vector", "type": "Collection(Edm.Single)", "dimensions": 1536},
    {"name": "content_text", "type": "Edm.String", "searchable": True},
    {"name": "doc_type", "type": "Edm.String", "filterable": True},
    {"name": "user_id", "type": "Edm.String", "filterable": True},
    {"name": "player_id", "type": "Edm.String", "filterable": True},
    {"name": "tags", "type": "Collection(Edm.String)", "filterable": True},
    {"name": "confidence", "type": "Edm.Double", "filterable": True},
    {"name": "timestamp_start", "type": "Edm.Double", "sortable": True},
    {"name": "timestamp_end", "type": "Edm.Double", "sortable": True}
  ],
  "vectorSearch": {
    "algorithms": [{"name": "hnsw", "kind": "hnsw"}],
    "profiles": [{"name": "profile", "algorithm": "hnsw"}]
  }
}
```

### Chunking Implementation

```python
def chunk_text_content(text: str, max_tokens: int = 1000, overlap_tokens: int = 150) -> List[str]:
    """
    Chunk text content for optimal embedding while preserving semantic boundaries.
    """
    import tiktoken
    
    encoder = tiktoken.get_encoding("cl100k_base")  # GPT-4 tokenizer
    tokens = encoder.encode(text)
    chunks = []
    
    start = 0
    while start < len(tokens):
        end = min(start + max_tokens, len(tokens))
        
        # Find sentence boundary near the end
        chunk_tokens = tokens[start:end]
        chunk_text = encoder.decode(chunk_tokens)
        
        # Adjust to sentence boundary
        if end < len(tokens):
            last_period = chunk_text.rfind('.')
            if last_period > len(chunk_text) * 0.8:  # Keep if > 80% of chunk
                chunk_text = chunk_text[:last_period + 1]
        
        chunks.append(chunk_text)
        
        # Calculate next start with overlap
        if end >= len(tokens):
            break
        start = end - overlap_tokens
    
    return chunks

def serialize_biomech_window(biomech_data: dict) -> str:
    """
    Convert structured biomechanical data to human-readable text for embedding.
    """
    window = biomech_data["time_window"]
    joints = biomech_data["joint_analysis"]
    metrics = biomech_data["performance_metrics"]
    
    text = f"{window['start_sec']:.1f}–{window['end_sec']:.1f}s: "
    
    # Add movement type
    if metrics.get("max_speed_ms", 0) > 6:
        text += "sprint, "
    elif metrics.get("max_speed_ms", 0) > 3:
        text += "run, "
    else:
        text += "walk/jog, "
    
    # Add performance metrics
    text += f"max_speed={metrics.get('max_speed_ms', 0):.1f} m/s, "
    text += f"acceleration={metrics.get('acceleration_max_ms2', 0):.1f} m/s², "
    
    # Add joint information
    if joints.get("left_knee_angle_peak"):
        text += f"left_knee_angle_peak={joints['left_knee_angle_peak']:.0f}°, "
    if joints.get("right_knee_angle_peak"):
        text += f"right_knee_angle_peak={joints['right_knee_angle_peak']:.0f}°, "
    
    # Add ball interaction if present
    if "ball_interaction" in biomech_data:
        ball = biomech_data["ball_interaction"] 
        if ball.get("touches_count", 0) > 0:
            text += f"ball_touches={ball['touches_count']}, "
            text += f"avg_ball_distance={ball.get('ball_to_feet_distance_avg_m', 0):.1f}m, "
    
    return text.rstrip(", ")
```

### Search & Retrieval

```python
async def search_rag_documents(
    query: str,
    doc_type: Optional[str] = None,
    user_id: Optional[str] = None,
    player_id: Optional[str] = None,
    tags: Optional[List[str]] = None,
    confidence_threshold: float = 0.7,
    limit: int = 10
) -> List[dict]:
    """
    Search RAG documents using hybrid vector + keyword search.
    """
    # Generate query embedding
    embedding = await generate_embedding(query)
    
    # Build filter conditions
    filters = []
    if doc_type:
        filters.append(f"doc_type eq '{doc_type}'")
    if user_id:
        filters.append(f"user_id eq '{user_id}'")
    if player_id:
        filters.append(f"player_id eq '{player_id}'")
    if tags:
        tag_filter = " or ".join([f"tags/any(t: t eq '{tag}')" for tag in tags])
        filters.append(f"({tag_filter})")
    if confidence_threshold:
        filters.append(f"confidence ge {confidence_threshold}")
    
    filter_str = " and ".join(filters) if filters else None
    
    # Execute hybrid search
    results = await search_client.search(
        search_text=query,
        vector_queries=[{
            "vector": embedding,
            "k_nearest_neighbors": limit * 2,  # Over-fetch for filtering
            "fields": "content_vector"
        }],
        filter=filter_str,
        top=limit,
        select=["id", "content_text", "doc_type", "tags", "confidence", "timestamp_start"]
    )
    
    return [doc async for doc in results]
```

## Query Patterns & Use Cases

### Match Analysis Queries
```python
# Find specific actions in recent matches
await search_rag_documents(
    query="crosses from left wing with high success rate",
    doc_type="match_segment",
    tags=["cross", "left_wing"],
    player_id="player_123"
)

# Analyze defensive transitions
await search_rag_documents(
    query="quick transition from defense to attack",
    doc_type="match_segment", 
    tags=["transition", "counter_attack"]
)
```

### Training Analysis Queries
```python
# Biomechanical pattern analysis
await search_rag_documents(
    query="knee angle patterns during cutting movements high speed",
    doc_type="training_session",
    tags=["cutting", "agility"]
)

# Performance progression tracking
await search_rag_documents(
    query="sprint speed improvement over time maximum velocity",
    doc_type="training_session",
    tags=["sprint", "peak_performance"]
)
```

### Knowledge Base Queries
```python
# La Masia methodology 
await search_rag_documents(
    query="Barcelona youth development technical skills left winger",
    doc_type="knowledge_base",
    tags=["la_masia", "left_winger", "technique"]
)

# Injury prevention guidance
await search_rag_documents(
    query="knee injury prevention exercises youth football",
    doc_type="knowledge_base",
    tags=["injury_prevention", "youth_development"]
)
```

## Integration with LLM Pipeline

### Prompt Engineering
The RAG system provides context to GPT-4 for football-specific coaching insights:

```python
SYSTEM_PROMPT = """
You are an expert football coach specializing in youth development and La Masia methodology. 
You help a 12-year-old right-footed left winger develop towards professional level.

Use the provided context documents to give specific, actionable coaching advice.
Focus on:
- Technical skill development
- Tactical understanding  
- Physical development appropriate for age
- Mental preparation for elite football
- Injury prevention and long-term health

Always reference specific data points and measurements when available.
"""

def generate_coaching_insight(query: str, context_docs: List[dict]) -> str:
    context = "\n\n".join([
        f"Document {i+1} ({doc['doc_type']}):\n{doc['content_text']}"
        for i, doc in enumerate(context_docs)
    ])
    
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": f"Context:\n{context}\n\nQuestion: {query}"}
    ]
    
    return openai_client.chat.completions.create(
        model="gpt-4-turbo",
        messages=messages,
        temperature=0.7,
        max_tokens=800
    )
```

### Response Enhancement
Responses include:
- Specific data references from context
- Actionable recommendations
- Progressive difficulty scaling
- Risk assessments for injury prevention
- Benchmarking against professional standards

## Deployment & Scaling

### Azure Infrastructure
- **Blob Storage**: Source video/document storage
- **Cognitive Search**: Vector search with hybrid capabilities
- **OpenAI**: Embedding generation and LLM inference
- **Functions**: Serverless document processing pipeline

### Performance Optimization
- **Caching**: Frequent query results cached in Redis
- **Batch Processing**: Bulk embedding generation for new content
- **Index Partitioning**: Separate indices for different doc types if needed
- **Async Pipeline**: Non-blocking document ingestion and processing

### Monitoring & Quality
- **Retrieval Metrics**: Track search relevance and coverage
- **Embedding Quality**: Monitor semantic similarity scores
- **User Feedback**: Track coaching insight effectiveness
- **Data Freshness**: Ensure timely updates for training data

## Future Extensions

### Multimodal Enhancement
- **Image Embeddings**: CLIP-based embeddings for tactical diagrams
- **Video Embeddings**: Direct video content embeddings for match analysis
- **Audio Processing**: Coach instructions and feedback integration

### Advanced Analytics
- **Temporal Patterns**: Long-term development trend analysis
- **Comparative Analysis**: Player-to-player benchmarking
- **Predictive Modeling**: Injury risk and performance forecasting

### Personalization
- **Learning Adaptation**: Schema evolution based on user interaction
- **Cultural Localization**: Multi-language support for global coaching
- **Custom Metrics**: User-defined performance indicators

---

This RAG schema provides a robust foundation for the Axolotl Football Analysis Platform, enabling sophisticated AI-powered coaching insights while maintaining focus on youth development and professional preparation.