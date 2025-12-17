# Coding Standards

This document defines coding standards and best practices for the Axolotl project.

## Table of Contents
- [General Principles](#general-principles)
- [Python Standards](#python-standards)
- [TypeScript/React Standards](#typescript-react-standards)
- [API Design](#api-design)
- [Database Design](#database-design)
- [Security Standards](#security-standards)
- [Performance Guidelines](#performance-guidelines)
- [Error Handling](#error-handling)

## General Principles

### Core Values

**1. Readability over Cleverness**
- Code is read more often than written
- Prefer clear, explicit code over clever one-liners
- Use meaningful names that reveal intent

**2. Consistency**
- Follow established patterns in the codebase
- Use consistent naming conventions
- Match the style of existing code

**3. Simplicity**
- Keep it simple and straightforward
- Avoid premature optimization
- Don't repeat yourself (DRY)
- YAGNI (You Aren't Gonna Need It)

**4. Documentation**
- Document the "why", not just the "what"
- Keep documentation close to code
- Update docs when code changes

**5. Testing**
- Write tests for new code
- Test edge cases and error conditions
- Make tests readable and maintainable

## Python Standards

### Style Guide

Follow [PEP 8](https://pep8.org/) with these clarifications:

**Line Length**: 100 characters (not 79)
**Indentation**: 4 spaces
**Quotes**: Double quotes `"` for strings, single `'` for dict keys

### Naming Conventions

```python
# Classes: PascalCase
class SessionProcessor:
    pass

# Functions/methods: snake_case
def calculate_kpis(session_data):
    pass

# Variables: snake_case
max_speed_kmh = 28.5
player_id = "player_123"

# Constants: UPPER_SNAKE_CASE
MAX_UPLOAD_SIZE_MB = 500
DEFAULT_FPS = 30

# Private: _leading_underscore
def _internal_helper():
    pass

class MyClass:
    def __init__(self):
        self._private_var = 0
```

### Type Hints

**Always use type hints** for function signatures:

```python
from typing import List, Dict, Optional, Tuple, Union

def process_detections(
    detections: List[Dict[str, float]],
    confidence_threshold: float = 0.5,
    return_metadata: bool = False
) -> Union[List[Dict], Tuple[List[Dict], Dict]]:
    """
    Process detection results with filtering.
    
    Args:
        detections: List of detection dictionaries
        confidence_threshold: Minimum confidence (0.0-1.0)
        return_metadata: Whether to return processing metadata
    
    Returns:
        Filtered detections, optionally with metadata tuple
    """
    filtered = [d for d in detections if d['confidence'] >= confidence_threshold]
    
    if return_metadata:
        metadata = {'count': len(filtered), 'threshold': confidence_threshold}
        return filtered, metadata
    
    return filtered
```

### Docstrings

Use Google-style docstrings:

```python
def calculate_speed_metrics(
    trajectory: np.ndarray,
    fps: int,
    pixel_to_meter: float
) -> Dict[str, float]:
    """
    Calculate speed metrics from player trajectory.
    
    Computes max speed, average speed, and speed distribution
    from a trajectory array.
    
    Args:
        trajectory: 2D array of (x, y) positions, shape (N, 2)
        fps: Frames per second of video
        pixel_to_meter: Conversion factor from pixels to meters
    
    Returns:
        Dictionary containing:
            - max_speed: Maximum speed in km/h
            - avg_speed: Average speed in km/h
            - speed_std: Standard deviation of speed
    
    Raises:
        ValueError: If trajectory has fewer than 2 points
        TypeError: If trajectory is not a numpy array
    
    Example:
        >>> trajectory = np.array([[0, 0], [10, 0], [20, 0]])
        >>> metrics = calculate_speed_metrics(trajectory, 30, 0.1)
        >>> print(metrics['max_speed'])
        10.8
    """
    if not isinstance(trajectory, np.ndarray):
        raise TypeError("Trajectory must be numpy array")
    
    if len(trajectory) < 2:
        raise ValueError("Trajectory must have at least 2 points")
    
    # Calculate speeds
    distances = np.linalg.norm(np.diff(trajectory, axis=0), axis=1)
    distances_m = distances * pixel_to_meter
    speeds_mps = distances_m * fps
    speeds_kmh = speeds_mps * 3.6
    
    return {
        'max_speed': float(np.max(speeds_kmh)),
        'avg_speed': float(np.mean(speeds_kmh)),
        'speed_std': float(np.std(speeds_kmh))
    }
```

### Error Handling

```python
# ✅ GOOD: Specific exceptions with context
def load_model(model_path: str) -> torch.nn.Module:
    """Load PyTorch model from file."""
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Model not found: {model_path}")
    
    try:
        model = torch.load(model_path)
    except RuntimeError as e:
        raise ValueError(f"Failed to load model from {model_path}: {e}")
    
    if not isinstance(model, torch.nn.Module):
        raise TypeError(f"Loaded object is not a PyTorch model: {type(model)}")
    
    return model


# ❌ BAD: Bare except, no context
def load_model(model_path):
    try:
        return torch.load(model_path)
    except:
        return None
```

### Code Organization

```python
# ✅ GOOD: Organized with clear sections
"""
Video processing module for football analysis.

This module handles video upload, validation, and preprocessing
for the analysis pipeline.
"""

# Standard library imports
import os
import logging
from pathlib import Path
from typing import List, Optional

# Third-party imports
import cv2
import numpy as np
from flask import Blueprint, request, jsonify

# Local imports
from app.backend.services.kpi_calculator import calculate_kpis
from src.axolotl.detection import YOLODetector

# Configure logging
logger = logging.getLogger(__name__)

# Constants
MAX_VIDEO_SIZE_MB = 500
SUPPORTED_FORMATS = ['.mp4', '.avi', '.mov', '.mkv']

# Blueprint definition
video_bp = Blueprint('video', __name__)

# Route handlers
@video_bp.route('/upload', methods=['POST'])
def upload_video():
    """Handle video upload endpoint."""
    # Implementation
```

## TypeScript/React Standards

### Naming Conventions

```typescript
// Interfaces/Types: PascalCase
interface PlayerData {
  id: string
  name: string
  position: string
}

type SpeedUnit = 'kmh' | 'mph'

// Components: PascalCase
export const DashboardCard: React.FC<DashboardCardProps> = () => {
  // ...
}

// Functions: camelCase
function calculateAverage(values: number[]): number {
  return values.reduce((a, b) => a + b, 0) / values.length
}

// Variables: camelCase
const maxSpeed = 28.5
const playerList = ['player1', 'player2']

// Constants: UPPER_SNAKE_CASE
const MAX_RETRY_ATTEMPTS = 3
const DEFAULT_TIMEOUT_MS = 5000

// Hooks: camelCase with 'use' prefix
function useWebSocket(url: string) {
  // ...
}

// Event handlers: handle prefix
const handleClick = () => {
  // ...
}

const handleSubmit = (event: FormEvent) => {
  // ...
}
```

### Component Structure

```typescript
// ✅ GOOD: Well-structured component
import { useState, useEffect, useCallback, useMemo } from 'react'
import { motion } from 'framer-motion'
import { TrendingUp, TrendingDown } from 'lucide-react'

/**
 * Performance metrics card component
 * 
 * Displays a single performance metric with trend indicator
 * and optional comparison to previous value.
 */

interface MetricsCardProps {
  /** Metric title */
  title: string
  /** Current metric value */
  value: number | string
  /** Previous value for comparison */
  previousValue?: number
  /** Value unit (e.g., 'km/h', 'm') */
  unit?: string
  /** Trend direction */
  trend?: 'up' | 'down' | 'neutral'
  /** Icon component */
  icon?: React.ReactNode
  /** Additional CSS classes */
  className?: string
  /** Click handler */
  onClick?: () => void
}

export const MetricsCard: React.FC<MetricsCardProps> = ({
  title,
  value,
  previousValue,
  unit,
  trend,
  icon,
  className = '',
  onClick
}) => {
  // Compute percentage change
  const percentageChange = useMemo(() => {
    if (!previousValue || typeof value !== 'number') return null
    
    const change = ((value - previousValue) / previousValue) * 100
    return change.toFixed(1)
  }, [value, previousValue])
  
  // Determine trend if not provided
  const computedTrend = useMemo(() => {
    if (trend) return trend
    if (!percentageChange) return 'neutral'
    
    const change = parseFloat(percentageChange)
    if (Math.abs(change) < 1) return 'neutral'
    return change > 0 ? 'up' : 'down'
  }, [trend, percentageChange])
  
  // Get trend color
  const getTrendColor = useCallback((trendValue: string) => {
    switch (trendValue) {
      case 'up': return 'text-green-600'
      case 'down': return 'text-red-600'
      default: return 'text-gray-600'
    }
  }, [])
  
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className={`bg-white rounded-lg shadow-md p-6 cursor-pointer hover:shadow-lg transition-shadow ${className}`}
      onClick={onClick}
      role={onClick ? 'button' : undefined}
      tabIndex={onClick ? 0 : undefined}
    >
      <div className="flex justify-between items-start mb-4">
        <h3 className="text-gray-600 text-sm font-medium">{title}</h3>
        {icon && (
          <div className="text-blue-500">
            {icon}
          </div>
        )}
      </div>
      
      <div className="flex items-end justify-between">
        <div>
          <p className="text-3xl font-bold text-gray-900">
            {value}
            {unit && <span className="text-lg text-gray-600 ml-1">{unit}</span>}
          </p>
        </div>
        
        {percentageChange && (
          <div className={`flex items-center text-sm ${getTrendColor(computedTrend)}`}>
            {computedTrend === 'up' && <TrendingUp size={16} />}
            {computedTrend === 'down' && <TrendingDown size={16} />}
            <span className="ml-1">{percentageChange}%</span>
          </div>
        )}
      </div>
    </motion.div>
  )
}
```

### Hooks

```typescript
// ✅ GOOD: Custom hook with proper types and error handling
import { useState, useEffect, useCallback } from 'react'
import { io, Socket } from 'socket.io-client'

interface UseWebSocketOptions {
  url?: string
  autoConnect?: boolean
  reconnection?: boolean
}

interface UseWebSocketReturn {
  socket: Socket | null
  connected: boolean
  error: Error | null
  emit: (event: string, data: any) => void
  on: (event: string, handler: (...args: any[]) => void) => void
  off: (event: string) => void
}

export function useWebSocket(
  options: UseWebSocketOptions = {}
): UseWebSocketReturn {
  const {
    url = process.env.VITE_API_URL || 'http://localhost:8080',
    autoConnect = true,
    reconnection = true
  } = options
  
  const [socket, setSocket] = useState<Socket | null>(null)
  const [connected, setConnected] = useState(false)
  const [error, setError] = useState<Error | null>(null)
  
  useEffect(() => {
    if (!autoConnect) return
    
    const newSocket = io(url, {
      transports: ['websocket'],
      autoConnect,
      reconnection,
      reconnectionAttempts: 5,
      reconnectionDelay: 1000
    })
    
    newSocket.on('connect', () => {
      setConnected(true)
      setError(null)
    })
    
    newSocket.on('disconnect', () => {
      setConnected(false)
    })
    
    newSocket.on('connect_error', (err) => {
      setError(new Error(`Connection error: ${err.message}`))
      setConnected(false)
    })
    
    setSocket(newSocket)
    
    return () => {
      newSocket.close()
    }
  }, [url, autoConnect, reconnection])
  
  const emit = useCallback((event: string, data: any) => {
    if (!socket || !connected) {
      console.warn('Cannot emit: socket not connected')
      return
    }
    socket.emit(event, data)
  }, [socket, connected])
  
  const on = useCallback((event: string, handler: (...args: any[]) => void) => {
    if (!socket) return
    socket.on(event, handler)
  }, [socket])
  
  const off = useCallback((event: string) => {
    if (!socket) return
    socket.off(event)
  }, [socket])
  
  return { socket, connected, error, emit, on, off }
}
```

## API Design

### RESTful Principles

**Resource-based URLs**:
```
✅ GOOD:
GET    /api/sessions              # List sessions
POST   /api/sessions              # Create session
GET    /api/sessions/123          # Get specific session
PUT    /api/sessions/123          # Update session
DELETE /api/sessions/123          # Delete session

❌ BAD:
GET /api/getSessionsList
POST /api/createNewSession
GET /api/getSession?id=123
```

**Use HTTP methods correctly**:
- GET: Retrieve data (no side effects)
- POST: Create new resource
- PUT: Update/replace resource
- PATCH: Partial update
- DELETE: Remove resource

**Use appropriate status codes**:
```python
# Success
return jsonify(data), 200  # OK
return jsonify(data), 201  # Created
return '', 204            # No Content

# Client errors
return jsonify(error), 400  # Bad Request
return jsonify(error), 401  # Unauthorized
return jsonify(error), 404  # Not Found
return jsonify(error), 422  # Unprocessable Entity

# Server errors
return jsonify(error), 500  # Internal Server Error
```

## Database Design

### Table Naming
- Use plural nouns: `sessions`, `players`, `training_events`
- Use snake_case: `session_kpis`, `paired_devices`

### Column Naming
- Use snake_case: `player_id`, `max_speed_kmh`
- Be specific with units: `distance_m`, `speed_kmh`, `duration_seconds`
- Use consistent patterns: `created_at`, `updated_at`, `deleted_at`

### Relationships
- Use explicit foreign keys
- Name foreign keys consistently: `{table}_id`
- Add indexes on foreign keys
- Use cascading deletes appropriately

```sql
-- ✅ GOOD
CREATE TABLE sessions (
    id VARCHAR(50) PRIMARY KEY,
    player_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_sessions_player ON sessions(player_id);
```

## Security Standards

### Input Validation
```python
# ✅ GOOD: Validate and sanitize
from flask import request
from werkzeug.utils import secure_filename

@app.route('/upload', methods=['POST'])
def upload_file():
    # Validate file exists
    if 'video' not in request.files:
        return jsonify({'error': 'No video file'}), 400
    
    file = request.files['video']
    
    # Validate filename
    if file.filename == '':
        return jsonify({'error': 'Empty filename'}), 400
    
    # Sanitize filename
    filename = secure_filename(file.filename)
    
    # Validate file extension
    allowed_extensions = {'.mp4', '.avi', '.mov'}
    if not any(filename.endswith(ext) for ext in allowed_extensions):
        return jsonify({'error': 'Invalid file type'}), 400
    
    # Validate file size
    file.seek(0, os.SEEK_END)
    size = file.tell()
    file.seek(0)
    
    if size > 500 * 1024 * 1024:  # 500MB
        return jsonify({'error': 'File too large'}), 400
    
    # Process file
    # ...
```

### Secrets Management
```python
# ✅ GOOD: Use environment variables
import os
from dotenv import load_dotenv

load_dotenv()

AZURE_OPENAI_KEY = os.getenv('AZURE_OPENAI_KEY')
if not AZURE_OPENAI_KEY:
    raise ValueError("AZURE_OPENAI_KEY not set")

# ❌ BAD: Hardcoded secrets
AZURE_OPENAI_KEY = "sk-abc123..."  # NEVER DO THIS
```

### SQL Injection Prevention
```python
# ✅ GOOD: Use parameterized queries
from sqlalchemy import text

session_id = request.args.get('session_id')
query = text("SELECT * FROM sessions WHERE id = :id")
result = db.execute(query, {'id': session_id})

# ❌ BAD: String concatenation
query = f"SELECT * FROM sessions WHERE id = '{session_id}'"  # VULNERABLE
```

## Performance Guidelines

### Backend
- Use database indexes strategically
- Implement caching for expensive operations
- Use background jobs for heavy processing
- Batch database operations when possible
- Profile before optimizing

### Frontend
- Lazy load components
- Memoize expensive computations
- Virtualize long lists
- Optimize images and assets
- Code split large bundles

```typescript
// ✅ GOOD: Lazy loading and memoization
import { lazy, Suspense, useMemo } from 'react'

const Player3D = lazy(() => import('./Player3D'))

export const SessionViewer = ({ session }) => {
  // Memoize expensive computation
  const processedData = useMemo(() => {
    return processSessionData(session)
  }, [session])
  
  return (
    <div>
      <Suspense fallback={<LoadingSpinner />}>
        <Player3D data={processedData} />
      </Suspense>
    </div>
  )
}
```

## Error Handling

### Backend Error Handling
```python
# ✅ GOOD: Comprehensive error handling
@app.route('/api/sessions/<session_id>')
def get_session(session_id):
    try:
        # Validate input
        if not session_id or len(session_id) > 50:
            return jsonify({'error': 'Invalid session ID'}), 400
        
        # Retrieve session
        session = Session.query.get(session_id)
        if not session:
            return jsonify({'error': 'Session not found'}), 404
        
        # Return data
        return jsonify(session.to_dict()), 200
        
    except DatabaseError as e:
        logger.error(f"Database error: {e}")
        return jsonify({'error': 'Database error'}), 500
        
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return jsonify({'error': 'Internal server error'}), 500
```

### Frontend Error Handling
```typescript
// ✅ GOOD: Error boundaries and try-catch
try {
  const data = await api.fetchSession(sessionId)
  setSession(data)
} catch (error) {
  if (error.response?.status === 404) {
    setError('Session not found')
  } else if (error.response?.status >= 500) {
    setError('Server error. Please try again later.')
  } else {
    setError('An error occurred. Please try again.')
  }
  console.error('Failed to fetch session:', error)
}
```

## Related Documentation

- [Contributing Guide](contributing.md)
- [Backend Architecture](../architecture/backend.md)
- [Frontend Architecture](../architecture/frontend.md)
- [API Reference](../architecture/api-reference.md)
