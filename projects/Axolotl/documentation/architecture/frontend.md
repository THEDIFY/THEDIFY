# Frontend Architecture

## Table of Contents
- [Overview](#overview)
- [Technology Stack](#technology-stack)
- [Directory Structure](#directory-structure)
- [Component Architecture](#component-architecture)
- [State Management](#state-management)
- [Routing](#routing)
- [Real-time Communication](#real-time-communication)
- [3D Visualization](#3d-visualization)
- [Styling](#styling)
- [Build System](#build-system)
- [Testing](#testing)

## Overview

The Axolotl frontend is a modern single-page application (SPA) built with React and TypeScript. It provides an intuitive interface for football performance analysis, live tracking, training planning, and data visualization.

**Location**: `app/frontend/`

**Key Characteristics**:
- Type-safe with TypeScript
- Component-based architecture
- Real-time data updates via WebSocket
- 3D player visualization
- Responsive design
- Fast builds with Vite

## Technology Stack

### Core Framework
- **React 18**: Modern UI library with concurrent features
- **TypeScript 5**: Static typing for better DX and fewer bugs
- **Vite 4**: Ultra-fast build tool and dev server

### UI & Styling
- **TailwindCSS 3**: Utility-first CSS framework
- **Lucide React**: Beautiful, consistent icon library
- **Framer Motion**: Smooth animations and transitions
- **class-variance-authority**: Component variant management
- **clsx**: Dynamic className composition

### State Management
- **Zustand 4**: Lightweight, simple state management
- **React Hooks**: Built-in state management for local state

### Data Visualization
- **Recharts 2.8**: Responsive chart library
- **Three.js 0.157**: 3D graphics engine
- **React Three Fiber**: React renderer for Three.js
- **@react-three/drei**: Useful helpers for R3F

### Real-time Features
- **Socket.IO Client 4.7**: WebSocket communication
- **FullCalendar 6.1**: Interactive calendar component

### Routing
- **React Router DOM 6**: Declarative routing

### Development
- **ESLint**: Code linting
- **TypeScript ESLint**: TypeScript-specific linting
- **Vitest**: Fast unit testing framework
- **Testing Library**: Component testing utilities

## Directory Structure

```
app/frontend/
├── src/                        # Source code
│   ├── components/             # Reusable UI components
│   │   ├── Dashboard.tsx       # Performance dashboard
│   │   ├── LiveAnalysis.tsx    # Real-time tracking
│   │   ├── SessionList.tsx     # Session browser
│   │   ├── Calendar.tsx        # Training calendar
│   │   ├── PairingPage.tsx     # Device pairing
│   │   ├── ConnectHelp.tsx     # Help documentation
│   │   └── ...
│   ├── pages/                  # Page-level components
│   │   ├── Dashboard.tsx
│   │   ├── LiveAnalysis.tsx
│   │   ├── SessionList.tsx
│   │   ├── Calendar.tsx
│   │   └── PairingPage.tsx
│   ├── hooks/                  # Custom React hooks
│   │   ├── useWebSocket.ts     # WebSocket connection
│   │   ├── useApi.ts          # API requests
│   │   ├── useAuth.ts         # Authentication
│   │   └── useLocalStorage.ts # Local storage
│   ├── stores/                 # Zustand stores
│   │   ├── sessionStore.ts    # Session state
│   │   ├── liveStore.ts       # Live analysis state
│   │   ├── calendarStore.ts   # Calendar state
│   │   └── uiStore.ts         # UI state
│   ├── types/                  # TypeScript type definitions
│   │   ├── api.ts             # API types
│   │   ├── models.ts          # Data models
│   │   └── components.ts      # Component props
│   ├── utils/                  # Utility functions
│   │   ├── api.ts             # API client
│   │   ├── formatting.ts      # Data formatting
│   │   ├── validation.ts      # Input validation
│   │   └── constants.ts       # App constants
│   ├── styles/                 # Global styles
│   │   └── globals.css        # Global CSS + Tailwind
│   ├── mobile/                 # Mobile-specific code
│   │   └── ...
│   ├── test/                   # Test utilities
│   │   └── setup.ts
│   ├── App.tsx                 # Root component
│   ├── main.tsx               # Application entry point
│   └── vite-env.d.ts          # Vite type definitions
├── public/                     # Static assets
│   ├── favicon.ico
│   └── ...
├── package.json               # Dependencies
├── tsconfig.json              # TypeScript config
├── vite.config.ts             # Vite configuration
├── tailwind.config.js         # Tailwind config
├── postcss.config.js          # PostCSS config
└── .eslintrc.cjs              # ESLint config
```

## Component Architecture

### Page Components

Page components represent full views and orchestrate multiple smaller components.

#### Dashboard Page

```typescript
// src/pages/Dashboard.tsx
import { useEffect } from 'react'
import { useSessionStore } from '@/stores/sessionStore'
import { MetricsCard } from '@/components/MetricsCard'
import { PerformanceChart } from '@/components/PerformanceChart'
import { PlayerComparison } from '@/components/PlayerComparison'

export const Dashboard = () => {
  const { sessions, fetchSessions, isLoading } = useSessionStore()
  
  useEffect(() => {
    fetchSessions()
  }, [fetchSessions])
  
  return (
    <div className="container mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6">Performance Dashboard</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <MetricsCard title="Avg Speed" value="24.5 km/h" />
        <MetricsCard title="Total Distance" value="8.2 km" />
        <MetricsCard title="Sessions" value={sessions.length} />
      </div>
      
      <PerformanceChart data={sessions} />
      <PlayerComparison players={getPlayers(sessions)} />
    </div>
  )
}
```

#### Live Analysis Page

```typescript
// src/pages/LiveAnalysis.tsx
import { useState, useEffect } from 'react'
import { useWebSocket } from '@/hooks/useWebSocket'
import { useLiveStore } from '@/stores/liveStore'
import { VideoStream } from '@/components/VideoStream'
import { LiveMetrics } from '@/components/LiveMetrics'
import { PlayerMarkers } from '@/components/PlayerMarkers'

export const LiveAnalysis = () => {
  const { socket, connected } = useWebSocket()
  const { metrics, startSession, stopSession } = useLiveStore()
  const [sessionId, setSessionId] = useState<string | null>(null)
  
  useEffect(() => {
    if (!socket || !connected) return
    
    socket.on('metrics_update', (data) => {
      useLiveStore.setState({ metrics: data.metrics })
    })
    
    return () => {
      socket.off('metrics_update')
    }
  }, [socket, connected])
  
  const handleStart = async () => {
    const id = await startSession()
    setSessionId(id)
  }
  
  const handleStop = () => {
    if (sessionId) {
      stopSession(sessionId)
      setSessionId(null)
    }
  }
  
  return (
    <div className="h-screen flex">
      <div className="flex-1">
        <VideoStream sessionId={sessionId} />
        <PlayerMarkers players={metrics?.players || []} />
      </div>
      
      <div className="w-96 bg-gray-100 p-6">
        <div className="mb-6">
          {!sessionId ? (
            <button onClick={handleStart} className="btn-primary w-full">
              Start Session
            </button>
          ) : (
            <button onClick={handleStop} className="btn-danger w-full">
              Stop Session
            </button>
          )}
        </div>
        
        {connected && <LiveMetrics metrics={metrics} />}
      </div>
    </div>
  )
}
```

#### Calendar Page

```typescript
// src/pages/Calendar.tsx
import { useState, useEffect } from 'react'
import FullCalendar from '@fullcalendar/react'
import dayGridPlugin from '@fullcalendar/daygrid'
import interactionPlugin from '@fullcalendar/interaction'
import { useCalendarStore } from '@/stores/calendarStore'
import { useWebSocket } from '@/hooks/useWebSocket'
import { EventModal } from '@/components/EventModal'

export const Calendar = () => {
  const { events, fetchEvents, createEvent, updateEvent } = useCalendarStore()
  const { socket, connected } = useWebSocket()
  const [selectedEvent, setSelectedEvent] = useState(null)
  const [showModal, setShowModal] = useState(false)
  
  useEffect(() => {
    fetchEvents()
  }, [fetchEvents])
  
  useEffect(() => {
    if (!socket || !connected) return
    
    socket.on('calendar_update', (data) => {
      fetchEvents() // Refresh calendar
    })
    
    return () => {
      socket.off('calendar_update')
    }
  }, [socket, connected, fetchEvents])
  
  const handleDateClick = (arg) => {
    setSelectedEvent({ start: arg.dateStr })
    setShowModal(true)
  }
  
  const handleEventClick = (arg) => {
    setSelectedEvent(arg.event)
    setShowModal(true)
  }
  
  return (
    <div className="container mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6">Training Calendar</h1>
      
      <FullCalendar
        plugins={[dayGridPlugin, interactionPlugin]}
        initialView="dayGridMonth"
        events={events}
        dateClick={handleDateClick}
        eventClick={handleEventClick}
        headerToolbar={{
          left: 'prev,next today',
          center: 'title',
          right: 'dayGridMonth,dayGridWeek,dayGridDay'
        }}
      />
      
      {showModal && (
        <EventModal
          event={selectedEvent}
          onClose={() => setShowModal(false)}
          onSave={(event) => {
            if (event.id) {
              updateEvent(event.id, event)
            } else {
              createEvent(event)
            }
            setShowModal(false)
          }}
        />
      )}
    </div>
  )
}
```

### Reusable Components

#### Metrics Card Component

```typescript
// src/components/MetricsCard.tsx
import { motion } from 'framer-motion'
import { TrendingUp, TrendingDown } from 'lucide-react'

interface MetricsCardProps {
  title: string
  value: string | number
  trend?: 'up' | 'down'
  trendValue?: string
  icon?: React.ReactNode
}

export const MetricsCard = ({ 
  title, 
  value, 
  trend, 
  trendValue,
  icon 
}: MetricsCardProps) => {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white rounded-lg shadow-md p-6"
    >
      <div className="flex justify-between items-start mb-4">
        <h3 className="text-gray-600 text-sm font-medium">{title}</h3>
        {icon && <div className="text-blue-500">{icon}</div>}
      </div>
      
      <div className="flex items-end justify-between">
        <p className="text-3xl font-bold text-gray-900">{value}</p>
        
        {trend && trendValue && (
          <div className={`flex items-center text-sm ${
            trend === 'up' ? 'text-green-600' : 'text-red-600'
          }`}>
            {trend === 'up' ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
            <span className="ml-1">{trendValue}</span>
          </div>
        )}
      </div>
    </motion.div>
  )
}
```

#### 3D Player Visualization Component

```typescript
// src/components/Player3D.tsx
import { Canvas } from '@react-three/fiber'
import { OrbitControls, PerspectiveCamera } from '@react-three/drei'
import { PlayerMesh } from './PlayerMesh'

interface Player3DProps {
  poseData: {
    keypoints: Array<{ x: number; y: number; z: number }>
  }
  smplData?: {
    vertices: Float32Array
    faces: Uint32Array
  }
}

export const Player3D = ({ poseData, smplData }: Player3DProps) => {
  return (
    <div className="w-full h-full">
      <Canvas>
        <PerspectiveCamera makeDefault position={[0, 1.5, 5]} />
        <OrbitControls />
        
        <ambientLight intensity={0.5} />
        <directionalLight position={[10, 10, 5]} intensity={1} />
        
        <PlayerMesh poseData={poseData} smplData={smplData} />
        
        <gridHelper args={[20, 20]} />
      </Canvas>
    </div>
  )
}
```

## State Management

### Zustand Stores

Zustand provides simple, efficient state management without boilerplate.

#### Session Store

```typescript
// src/stores/sessionStore.ts
import { create } from 'zustand'
import { api } from '@/utils/api'

interface Session {
  id: string
  player_id: string
  created_at: string
  kpis: Record<string, any>
  metadata: Record<string, any>
}

interface SessionStore {
  sessions: Session[]
  currentSession: Session | null
  isLoading: boolean
  error: string | null
  
  fetchSessions: () => Promise<void>
  fetchSession: (id: string) => Promise<void>
  createSession: (data: Partial<Session>) => Promise<Session>
  updateSession: (id: string, data: Partial<Session>) => Promise<void>
  deleteSession: (id: string) => Promise<void>
}

export const useSessionStore = create<SessionStore>((set, get) => ({
  sessions: [],
  currentSession: null,
  isLoading: false,
  error: null,
  
  fetchSessions: async () => {
    set({ isLoading: true, error: null })
    try {
      const response = await api.get('/api/sessions')
      set({ sessions: response.data, isLoading: false })
    } catch (error) {
      set({ error: error.message, isLoading: false })
    }
  },
  
  fetchSession: async (id) => {
    set({ isLoading: true, error: null })
    try {
      const response = await api.get(`/api/sessions/${id}`)
      set({ currentSession: response.data, isLoading: false })
    } catch (error) {
      set({ error: error.message, isLoading: false })
    }
  },
  
  createSession: async (data) => {
    try {
      const response = await api.post('/api/sessions', data)
      set((state) => ({
        sessions: [...state.sessions, response.data]
      }))
      return response.data
    } catch (error) {
      set({ error: error.message })
      throw error
    }
  },
  
  updateSession: async (id, data) => {
    try {
      await api.put(`/api/sessions/${id}`, data)
      set((state) => ({
        sessions: state.sessions.map((s) => 
          s.id === id ? { ...s, ...data } : s
        )
      }))
    } catch (error) {
      set({ error: error.message })
      throw error
    }
  },
  
  deleteSession: async (id) => {
    try {
      await api.delete(`/api/sessions/${id}`)
      set((state) => ({
        sessions: state.sessions.filter((s) => s.id !== id)
      }))
    } catch (error) {
      set({ error: error.message })
      throw error
    }
  }
}))
```

#### Live Store

```typescript
// src/stores/liveStore.ts
import { create } from 'zustand'
import { api } from '@/utils/api'

interface LiveMetrics {
  players: Array<{
    id: number
    bbox: number[]
    speed: number
    distance: number
  }>
  fps: number
  timestamp: string
}

interface LiveStore {
  sessionId: string | null
  isActive: boolean
  metrics: LiveMetrics | null
  
  startSession: () => Promise<string>
  stopSession: (sessionId: string) => Promise<void>
  updateMetrics: (metrics: LiveMetrics) => void
}

export const useLiveStore = create<LiveStore>((set) => ({
  sessionId: null,
  isActive: false,
  metrics: null,
  
  startSession: async () => {
    const response = await api.post('/api/live/start')
    const sessionId = response.data.session_id
    set({ sessionId, isActive: true })
    return sessionId
  },
  
  stopSession: async (sessionId) => {
    await api.post('/api/live/stop', { session_id: sessionId })
    set({ sessionId: null, isActive: false, metrics: null })
  },
  
  updateMetrics: (metrics) => {
    set({ metrics })
  }
}))
```

## Routing

### Router Configuration

```typescript
// src/App.tsx
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { Dashboard } from '@/pages/Dashboard'
import { LiveAnalysis } from '@/pages/LiveAnalysis'
import { SessionList } from '@/pages/SessionList'
import { Calendar } from '@/pages/Calendar'
import { PairingPage } from '@/pages/PairingPage'
import { Layout } from '@/components/Layout'

export const App = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<Navigate to="/dashboard" replace />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/live" element={<LiveAnalysis />} />
          <Route path="/sessions" element={<SessionList />} />
          <Route path="/calendar" element={<Calendar />} />
          <Route path="/pairing" element={<PairingPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  )
}
```

### Layout Component

```typescript
// src/components/Layout.tsx
import { Outlet, Link } from 'react-router-dom'
import { Home, Activity, Calendar, List, Smartphone } from 'lucide-react'

export const Layout = () => {
  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm">
        <div className="container mx-auto px-4">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-8">
              <h1 className="text-xl font-bold text-blue-600">Axolotl</h1>
              
              <div className="flex space-x-4">
                <NavLink to="/dashboard" icon={<Home />}>Dashboard</NavLink>
                <NavLink to="/live" icon={<Activity />}>Live</NavLink>
                <NavLink to="/sessions" icon={<List />}>Sessions</NavLink>
                <NavLink to="/calendar" icon={<Calendar />}>Calendar</NavLink>
                <NavLink to="/pairing" icon={<Smartphone />}>Pairing</NavLink>
              </div>
            </div>
          </div>
        </div>
      </nav>
      
      <main>
        <Outlet />
      </main>
    </div>
  )
}
```

## Real-time Communication

### WebSocket Hook

```typescript
// src/hooks/useWebSocket.ts
import { useEffect, useState, useCallback } from 'react'
import { io, Socket } from 'socket.io-client'

const SOCKET_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080'

export const useWebSocket = () => {
  const [socket, setSocket] = useState<Socket | null>(null)
  const [connected, setConnected] = useState(false)
  
  useEffect(() => {
    const newSocket = io(SOCKET_URL, {
      transports: ['websocket'],
      autoConnect: true
    })
    
    newSocket.on('connect', () => {
      console.log('WebSocket connected')
      setConnected(true)
    })
    
    newSocket.on('disconnect', () => {
      console.log('WebSocket disconnected')
      setConnected(false)
    })
    
    setSocket(newSocket)
    
    return () => {
      newSocket.close()
    }
  }, [])
  
  const emit = useCallback((event: string, data: any) => {
    if (socket && connected) {
      socket.emit(event, data)
    }
  }, [socket, connected])
  
  const on = useCallback((event: string, callback: Function) => {
    if (socket) {
      socket.on(event, callback as any)
    }
  }, [socket])
  
  const off = useCallback((event: string) => {
    if (socket) {
      socket.off(event)
    }
  }, [socket])
  
  return { socket, connected, emit, on, off }
}
```

## 3D Visualization

### Player Mesh Component

```typescript
// src/components/PlayerMesh.tsx
import { useRef, useMemo } from 'react'
import { useFrame } from '@react-three/fiber'
import * as THREE from 'three'

interface PlayerMeshProps {
  poseData: {
    keypoints: Array<{ x: number; y: number; z: number }>
  }
  smplData?: {
    vertices: Float32Array
    faces: Uint32Array
  }
}

export const PlayerMesh = ({ poseData, smplData }: PlayerMeshProps) => {
  const meshRef = useRef<THREE.Mesh>(null)
  
  const geometry = useMemo(() => {
    if (smplData) {
      const geom = new THREE.BufferGeometry()
      geom.setAttribute('position', new THREE.BufferAttribute(smplData.vertices, 3))
      geom.setIndex(new THREE.BufferAttribute(smplData.faces, 1))
      geom.computeVertexNormals()
      return geom
    }
    return new THREE.SphereGeometry(0.5)
  }, [smplData])
  
  useFrame((state) => {
    if (meshRef.current) {
      meshRef.current.rotation.y = state.clock.elapsedTime * 0.5
    }
  })
  
  return (
    <mesh ref={meshRef} geometry={geometry}>
      <meshStandardMaterial color="#3b82f6" />
    </mesh>
  )
}
```

## Styling

### Tailwind Configuration

```javascript
// tailwind.config.js
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        }
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      }
    },
  },
  plugins: [],
}
```

### Global Styles

```css
/* src/styles/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html, body, #root {
    @apply h-full;
  }
  
  body {
    @apply font-sans antialiased;
  }
}

@layer components {
  .btn-primary {
    @apply px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors;
  }
  
  .btn-danger {
    @apply px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors;
  }
  
  .card {
    @apply bg-white rounded-lg shadow-md p-6;
  }
}
```

## Build System

### Vite Configuration

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: '../backend/static',
    emptyOutDir: true,
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'three-vendor': ['three', '@react-three/fiber', '@react-three/drei'],
          'ui-vendor': ['framer-motion', 'lucide-react'],
        }
      }
    }
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
      '/socket.io': {
        target: 'http://localhost:8080',
        ws: true,
      }
    }
  }
})
```

### Build Scripts

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "build:watch": "vite build --watch",
    "preview": "vite preview --port 5173",
    "lint": "eslint . --ext .ts,.tsx",
    "type-check": "tsc --noEmit",
    "test": "vitest",
    "test:run": "vitest run"
  }
}
```

## Testing

### Component Testing

```typescript
// src/components/__tests__/MetricsCard.test.tsx
import { render, screen } from '@testing-library/react'
import { MetricsCard } from '../MetricsCard'

describe('MetricsCard', () => {
  it('renders title and value', () => {
    render(<MetricsCard title="Speed" value="24.5 km/h" />)
    
    expect(screen.getByText('Speed')).toBeInTheDocument()
    expect(screen.getByText('24.5 km/h')).toBeInTheDocument()
  })
  
  it('shows trend indicator when provided', () => {
    render(
      <MetricsCard 
        title="Distance" 
        value="8.2 km" 
        trend="up" 
        trendValue="+5%" 
      />
    )
    
    expect(screen.getByText('+5%')).toBeInTheDocument()
  })
})
```

### Hook Testing

```typescript
// src/hooks/__tests__/useWebSocket.test.ts
import { renderHook, waitFor } from '@testing-library/react'
import { useWebSocket } from '../useWebSocket'

describe('useWebSocket', () => {
  it('connects to WebSocket server', async () => {
    const { result } = renderHook(() => useWebSocket())
    
    await waitFor(() => {
      expect(result.current.connected).toBe(true)
    })
  })
  
  it('emits events when connected', async () => {
    const { result } = renderHook(() => useWebSocket())
    
    await waitFor(() => {
      expect(result.current.connected).toBe(true)
    })
    
    result.current.emit('test_event', { data: 'test' })
    // Assert event was emitted
  })
})
```

## Performance Optimization

### Code Splitting

```typescript
// Lazy load heavy components
const Player3D = lazy(() => import('@/components/Player3D'))
const Calendar = lazy(() => import('@/pages/Calendar'))

// Use with Suspense
<Suspense fallback={<LoadingSpinner />}>
  <Player3D poseData={data} />
</Suspense>
```

### Memoization

```typescript
// Memoize expensive computations
const processedData = useMemo(() => {
  return computeHeavyCalculation(rawData)
}, [rawData])

// Memoize callbacks
const handleClick = useCallback(() => {
  doSomething(value)
}, [value])
```

### Virtual Scrolling

```typescript
// For large lists
import { FixedSizeList } from 'react-window'

<FixedSizeList
  height={600}
  itemCount={sessions.length}
  itemSize={80}
  width="100%"
>
  {({ index, style }) => (
    <div style={style}>
      <SessionCard session={sessions[index]} />
    </div>
  )}
</FixedSizeList>
```

## Related Documentation

- [System Architecture Overview](overview.md)
- [Backend Architecture](backend.md)
- [API Reference](api-reference.md)
- [Development Guide](../development/contributing.md)
- [Testing Guide](../development/testing.md)
