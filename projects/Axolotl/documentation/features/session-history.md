# Session Physical Data Indexer

This document describes the Session Physical Data Indexer implementation for the Axolotl Football Analysis Platform.

## Overview

The Session Indexer (Phase 5.4.5) implements the complete pipeline for indexing physical data from training and match sessions into the vector database for RAG (Retrieval-Augmented Generation) functionality.

## Features

### Core Functionality
- **Raw Data Storage**: Uploads kinematics data to Azure Blob Storage
- **Vector Indexing**: Creates searchable vector documents for Azure Cognitive Search
- **Time Windowing**: Automatically chunks sessions into 5-15 second segments
- **Human-Readable Summaries**: Generates natural language descriptions of biomechanical data
- **Structured Metadata**: Extracts numeric metrics for precise filtering

### Data Processing
- **Kinematics Analysis**: Processes joint angles, velocities, accelerations
- **Performance Metrics**: Computes speed, acceleration, ball interaction data
- **Activity Classification**: Automatically labels segments (sprint, jog, ball_work, etc.)
- **Confidence Scoring**: Assesses data quality and completeness
- **Joint Peak Detection**: Identifies maximum joint angles and their timestamps

### Search Integration
- **Vector Embeddings**: Uses Azure OpenAI text-embedding-3-large
- **Metadata Filtering**: Supports precise queries by speed, user_id, session_type
- **Blob URL References**: Links to raw data for detailed analysis
- **Temporal Indexing**: Supports time-based queries and retrieval

## Usage

### Command Line Interface

```bash
# Basic indexing
python ingest/session_indexer.py \
    --session_id "training_20240315" \
    --user_id "u123" \
    --session_path "biomech/training_20240315"

# With player ID and session type
python ingest/session_indexer.py \
    --session_id "match_20240315" \
    --user_id "u123" \
    --session_path "biomech/match_20240315" \
    --player_id "p456" \
    --session_type "match"

# Run acceptance tests
python ingest/session_indexer.py \
    --session_id "test_session" \
    --user_id "test_user" \
    --session_path "biomech/example_session" \
    --test
```

### Python API

```python
from ingest.session_indexer import SessionIndexer, SessionIndexerConfig

# Configure for Azure services
config = SessionIndexerConfig(
    azure_storage_connection_string="your_connection_string",
    azure_search_endpoint="https://your-service.search.windows.net",
    azure_search_key="your_search_key",
    azure_openai_endpoint="https://your-openai.openai.azure.com/",
    azure_openai_key="your_openai_key"
)

# Create indexer
indexer = SessionIndexer(config)

# Index a session
results = indexer.index_session(
    session_id="training_001",
    user_id="user_123",
    session_data_path="biomech/training_001"
)

print(f"Indexed {results['documents_created']} documents")
```

## Data Flow

### 1. Input Data
- **kinematics.csv**: Frame-by-frame biomechanical data
- **summary.json**: Session-level summary statistics

### 2. Processing Pipeline
1. **Load Data**: Parse CSV and JSON files
2. **Create Windows**: Generate 5-15 second time segments
3. **Compute Metrics**: Calculate speed, acceleration, joint peaks
4. **Generate Text**: Create human-readable summaries
5. **Create Embeddings**: Generate vector representations
6. **Upload Raw Data**: Store complete dataset in Blob Storage
7. **Index Documents**: Upload vector documents to search index

### 3. Output Documents
Each window generates a vector document with this structure:

```json
{
  "id": "session-123-chunk-0001",
  "user_id": "u123",
  "player_id": "p456", 
  "session_id": "training_20240315",
  "doc_type": "training_session_chunk",
  "start_ts": "00:01:12.345",
  "end_ts": "00:01:22.345",
  "text": "0:01–0:11 sprint: peak_speed=8.9 m/s; avg_accel=2.1 m/s²; left_knee_max=135deg@0:01:04...",
  "vector": [0.1, 0.2, ...],
  "metadata": {
    "max_speed": 8.9,
    "avg_speed": 7.1, 
    "avg_accel": 2.1,
    "joint_peaks": {"left_knee": 135, "right_knee": 128},
    "confidence": 0.92,
    "session_type": "training"
  },
  "source_blob_url": "https://storage.blob.core.windows.net/.../kinematics.json",
  "created_at": "2024-03-15T10:11:12Z"
}
```

## Configuration

### Environment Variables
```bash
# Azure Storage
AZURE_STORAGE_CONNECTION_STRING="your_connection_string"

# Azure Cognitive Search  
AZURE_SEARCH_ENDPOINT="https://your-service.search.windows.net"
AZURE_SEARCH_KEY="your_search_key"
AZURE_SEARCH_INDEX="edify-index"

# Azure OpenAI
AZURE_OPENAI_ENDPOINT="https://your-openai.openai.azure.com/"
AZURE_OPENAI_API_KEY="your_openai_key"
AZURE_OPENAI_DEPLOYMENT_NAME="text-embedding-3-large"
```

### Processing Parameters
- **chunk_window_seconds**: Time window size (default: 10.0)
- **overlap_seconds**: Window overlap (default: 2.0)  
- **min_chunk_duration**: Minimum window size (default: 5.0)
- **max_chunk_duration**: Maximum window size (default: 15.0)
- **embedding_batch_size**: Batch size for embeddings (default: 50)
- **timeout_seconds**: Processing timeout (default: 300)

## Testing

### Unit Tests
```bash
python test/test_session_indexer_simple.py
```

### Integration Tests
```bash
# Test with example data
python ingest/session_indexer.py \
    --session_id example_session \
    --user_id test_user \
    --session_path biomech/example_session \
    --test
```

### Acceptance Criteria

The implementation satisfies all specified acceptance criteria:

1. ✅ **Blob Upload**: Uploads kinematics.json to Azure Blob Storage
2. ✅ **Document Creation**: Creates vector documents with proper structure
3. ✅ **Search Indexing**: Uploads documents to Azure Cognitive Search
4. ✅ **Query Support**: Supports filtering by user_id, max_speed, etc.
5. ✅ **Metadata Validation**: Ensures numeric metadata matches raw JSON
6. ✅ **Performance**: Processes 1-hour session in under 5 minutes

## Football-Specific Features

### Activity Classification
- **Sprint**: max_speed > 7.0 m/s
- **Run**: max_speed > 4.0 m/s  
- **Jog**: max_speed > 1.5 m/s
- **Ball Work**: any ball contacts detected
- **Static Drill**: low movement activities

### Joint Analysis
- **Peak Detection**: Identifies maximum joint angles
- **Timestamp Tracking**: Records when peaks occur
- **Risk Assessment**: Flags potentially dangerous angles
- **Left Winger Focus**: Emphasizes relevant biomechanics

### Ball Interaction
- **Contact Detection**: Distance threshold < 30cm
- **Speed Tracking**: Ball velocity during interactions
- **Control Quality**: Assesses ball handling skills

## Error Handling

- **Graceful Degradation**: Works without Azure services (mock mode)
- **Data Validation**: Handles missing or invalid data points
- **Retry Logic**: Automatic retry for transient failures
- **Comprehensive Logging**: Detailed error reporting and debugging

## Performance Considerations

- **Batch Processing**: Groups operations for efficiency
- **Memory Management**: Streams large datasets
- **Parallel Processing**: Can be extended for concurrent sessions
- **Caching**: Supports embedding caching for development

## Future Enhancements

- **Event-Based Chunking**: Use detected football events for boundaries
- **Multi-Player Support**: Index multiple players in same session
- **Real-Time Processing**: Stream processing for live sessions
- **Advanced Analytics**: ML-based activity recognition
- **Custom Embeddings**: Football-specific embedding models