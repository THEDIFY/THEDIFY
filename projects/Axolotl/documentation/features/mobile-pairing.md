# QR Pairing System Architecture

Visual reference for the QR-based phone pairing system architecture, data flows, and component interactions.

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AXOLOTL PAIRING SYSTEM                              │
└─────────────────────────────────────────────────────────────────────────────┘

                        HOST (Coach/Parent)
                               │
                               ▼
                    ┌──────────────────────┐
                    │  Frontend Dashboard  │
                    │  (React/TypeScript)  │
                    └──────────┬───────────┘
                               │
                               │ REST API
                               ▼
                    ┌──────────────────────┐
                    │  Backend Services    │
                    │  (Flask/Python)      │
                    └──────────┬───────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                ▼              ▼              ▼
        ┌──────────┐   ┌─────────────┐   ┌──────────┐
        │ Pairing  │   │   Stream    │   │   Edge   │
        │ Service  │   │   Handler   │   │ Gateway  │
        └──────────┘   └─────────────┘   └──────────┘
                │              │              │
                └──────────────┼──────────────┘
                               │
                               │ WebSocket/WebRTC
                               ▼
                    ┌──────────────────────┐
                    │  Mobile Clients      │
                    │  (Browser/Native)    │
                    └──────────────────────┘
                               │
                        ┌──────┴──────┐
                        │             │
                    Phone 1       Phone 2,3...
```

## Component Architecture

### Backend Services

```
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND SERVICES                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  pairing_service.py                                    │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │  • create_session()     → JWT token + QR URL          │    │
│  │  • validate_token()     → Verify signature & expiry   │    │
│  │  • register_device()    → Add phone to session        │    │
│  │  • get_session_status() → Connected devices list      │    │
│  │  • update_sync_offset() → Store NTP offset            │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  stream_handler.py                                     │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │  • register_stream()           → Track device stream  │    │
│  │  • handle_websocket_frame()    → Process WS frames    │    │
│  │  • handle_webrtc_frame()       → Process RTC frames   │    │
│  │  • handle_http_upload()        → Process HTTP frames  │    │
│  │  • update_sync_offset()        → Apply time offset    │    │
│  │  • get_stream_stats()          → Frame counts, etc.   │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  pairing_bp.py (Flask Blueprint)                       │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │  REST Endpoints:                                       │    │
│  │    POST /api/pairing/create_session                    │    │
│  │    GET  /api/pairing/validate                          │    │
│  │    POST /api/pairing/register_device                   │    │
│  │    POST /api/pairing/signal_offer                      │    │
│  │    GET  /api/pairing/session_status                    │    │
│  │    POST /api/pairing/ntp_sync                          │    │
│  │  Page Endpoints:                                       │    │
│  │    GET  /pair                                          │    │
│  │  WebSocket:                                            │    │
│  │    WS   /ws/pair                                       │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Session Creation Flow

```
Coach Browser                Backend                     Database
     │                          │                           │
     │  POST /create_session    │                           │
     ├─────────────────────────>│                           │
     │                          │                           │
     │                          │  Generate JWT Token       │
     │                          │  (HMAC-SHA256)            │
     │                          │                           │
     │                          │  Store Session            │
     │                          ├──────────────────────────>│
     │                          │                           │
     │                          │  Generate QR Code         │
     │                          │  (URL with token)         │
     │                          │                           │
     │  200 OK                  │                           │
     │  {session_id, token,     │                           │
     │   pairing_url, qr_svg}   │                           │
     │<─────────────────────────┤                           │
     │                          │                           │
     │  Display QR Code         │                           │
     │                          │                           │
```

### 2. Phone Connection Flow

```
Mobile Browser           Backend                    Stream Handler
     │                      │                            │
     │  Scan QR Code        │                            │
     │                      │                            │
     │  GET /pair?token=... │                            │
     ├─────────────────────>│                            │
     │                      │                            │
     │  200 OK (HTML page)  │                            │
     │<─────────────────────┤                            │
     │                      │                            │
     │  GET /validate       │                            │
     ├─────────────────────>│                            │
     │                      │                            │
     │  Verify JWT          │                            │
     │  Check expiry        │                            │
     │  Check single-use    │                            │
     │                      │                            │
     │  200 OK {valid}      │                            │
     │<─────────────────────┤                            │
     │                      │                            │
     │  POST /register      │                            │
     │  {device_id, meta}   │                            │
     ├─────────────────────>│                            │
     │                      │                            │
     │                      │  Mark token used           │
     │                      │  Store device info         │
     │                      │                            │
     │                      │  Register stream           │
     │                      ├───────────────────────────>│
     │                      │                            │
     │  200 OK {ws_url}     │                            │
     │<─────────────────────┤                            │
     │                      │                            │
     │  getUserMedia()      │                            │
     │  (Request camera)    │                            │
     │                      │                            │
     │  POST /ntp_sync (×5) │                            │
     ├─────────────────────>│                            │
     │                      │                            │
     │  Calculate offset    │                            │
     │                      │                            │
     │  200 OK {offset}     │                            │
     │<─────────────────────┤                            │
     │                      │                            │
     │  WebSocket Connect   │                            │
     ├─────────────────────>│                            │
     │                      │                            │
     │  Send Frames         │                            │
     │  (15 fps)            │                            │
     ├─────────────────────>│───────────────────────────>│
     │                      │                            │
```

### 3. Frame Processing Flow

```
Mobile                Stream Handler           Edge Gateway         Reconstruction
  │                         │                       │                      │
  │  Capture Frame          │                       │                      │
  │  (720p JPEG)            │                       │                      │
  │                         │                       │                      │
  │  WebSocket Send         │                       │                      │
  │  {frame_b64, ts}        │                       │                      │
  ├────────────────────────>│                       │                      │
  │                         │                       │                      │
  │                         │  Decode base64        │                      │
  │                         │  Validate JPEG        │                      │
  │                         │  Apply sync offset    │                      │
  │                         │                       │                      │
  │                         │  Forward Frame        │                      │
  │                         │  {device_id, data,    │                      │
  │                         │   ts_aligned}         │                      │
  │                         ├──────────────────────>│                      │
  │                         │                       │                      │
  │                         │                       │  Buffer Frame        │
  │                         │                       │  (by timestamp)      │
  │                         │                       │                      │
  │                         │                       │  Match Frames        │
  │                         │                       │  (±50ms tolerance)   │
  │                         │                       │                      │
  │                         │                       │  Run 2D Pose         │
  │                         │                       │  (MediaPipe)         │
  │                         │                       │                      │
  │                         │                       │  Forward to Recon    │
  │                         │                       ├─────────────────────>│
  │                         │                       │                      │
  │                         │                       │  Triangulate 3D      │
  │                         │                       │  (DLT algorithm)     │
  │                         │                       │                      │
  │                         │                       │  Return 3D Pose      │
  │                         │                       │<─────────────────────┤
  │                         │                       │                      │
  │  Frame ACK              │                       │                      │
  │<────────────────────────┤                       │                      │
  │                         │                       │                      │
```

## Token Lifecycle

```
┌──────────────────────────────────────────────────────────────────┐
│                     TOKEN LIFECYCLE                              │
└──────────────────────────────────────────────────────────────────┘

    [1] CREATION
         │
         │  pairing_service.create_session()
         │    ↓
         │  JWT.encode({
         │    session_id: "sess-123",
         │    user_id: "coach-001", 
         │    mode: "3d",
         │    expected_devices: 3,
         │    iat: 1625000000,
         │    exp: 1625000600  ← 10 min TTL
         │  }, SECRET, algorithm='HS256')
         │    ↓
         ▼  Token: "eyJhbGciOiJIUzI1NiIs..."
         
    [2] STORAGE
         │
         │  tokens[token] = {
         │    session_id: "sess-123",
         │    created_at: 1625000000,
         │    used_by: set(),        ← Empty set
         │    max_uses: 3            ← Expected devices
         │  }
         ▼
         
    [3] VALIDATION (First Device)
         │
         │  Device: phone-001 attempts to use token
         │    ↓
         │  JWT.decode(token, SECRET, verify_signature=True)
         │    ↓ Check expiry
         │  if exp < now: REJECT ✗
         │    ↓
         │  if "phone-001" in used_by: REJECT ✗
         │    ↓
         │  if len(used_by) >= max_uses: REJECT ✗
         │    ↓
         │  used_by.add("phone-001")  ← Mark as used
         │    ↓
         ▼  ACCEPT ✓
         
    [4] REUSE ATTEMPT (Same Device)
         │
         │  Device: phone-001 attempts again
         │    ↓
         │  if "phone-001" in used_by: REJECT ✗
         │    ↓
         ▼  "Token already used by this device"
         
    [5] ADDITIONAL DEVICES
         │
         │  Device: phone-002 attempts
         │    ↓ All checks pass
         │  used_by.add("phone-002")
         │    ↓
         ▼  ACCEPT ✓ (2/3 devices)
         │
         │  Device: phone-003 attempts
         │    ↓ All checks pass
         │  used_by.add("phone-003")
         │    ↓
         ▼  ACCEPT ✓ (3/3 devices - FULL)
         
    [6] MAX DEVICES REACHED
         │
         │  Device: phone-004 attempts
         │    ↓
         │  if len(used_by) >= max_uses: REJECT ✗
         │    ↓
         ▼  "Maximum devices reached"
         
    [7] EXPIRY
         │
         │  After 10 minutes (TTL expired)
         │    ↓
         │  Any device attempts
         │    ↓
         │  JWT.decode() → ExpiredSignatureError
         │    ↓
         ▼  REJECT ✗ "Token expired"
         
    [8] CLEANUP
         │
         │  Periodic cleanup job (every 5 min)
         │    ↓
         │  for token, meta in tokens.items():
         │    if now - meta['created_at'] > TTL + 60:
         │      del tokens[token]
         │    ↓
         ▼  Old tokens removed
```

## Sync System Architecture

### NTP-Lite Handshake

```
┌───────────────────────────────────────────────────────────────┐
│                NTP-LITE SYNCHRONIZATION                       │
└───────────────────────────────────────────────────────────────┘

Mobile Phone          Network           Backend Server
     │                   │                     │
     │  Round 1          │                     │
     │  ───────────────────────────────────>   │
     │  ts_device: 1000  │                     │
     │                   │                     │  ts_server: 1042
     │                   │                     │  offset_1 = 1042-1000 = 42ms
     │                   │                     │
     │  <───────────────────────────────────   │
     │  ts_server: 1042  │                     │
     │                   │                     │
     │  offset_1 = 42ms  │                     │
     │                   │                     │
     │  Round 2          │                     │
     │  ───────────────────────────────────>   │
     │  ts_device: 1100  │                     │
     │                   │                     │  ts_server: 1138
     │                   │                     │  offset_2 = 1138-1100 = 38ms
     │                   │                     │
     │  <───────────────────────────────────   │
     │  ts_server: 1138  │                     │
     │                   │                     │
     │  offset_2 = 38ms  │                     │
     │                   │                     │
     │  Round 3, 4, 5... │                     │
     │  (similar)        │                     │
     │                   │                     │
     │  After 5 rounds:  │                     │
     │  offsets = [42, 38, 45, 40, 41]         │
     │                   │                     │
     │  Sort: [38, 40, 41, 42, 45]             │
     │  Median: 41ms ← SYNC OFFSET             │
     │                   │                     │
     │  Store offset     │                     │
     │                   │                     │
     
  All future frames:
     ts_aligned = ts_device + 41ms
```

### Frame Alignment

```
┌─────────────────────────────────────────────────────────────────┐
│                    FRAME ALIGNMENT                              │
└─────────────────────────────────────────────────────────────────┘

Phone 1 (offset: +10ms)     Phone 2 (offset: +15ms)     Phone 3 (offset: +20ms)
     │                           │                            │
     │  ts_device: 1000          │  ts_device: 1005           │  ts_device: 995
     │  ts_aligned: 1010         │  ts_aligned: 1020          │  ts_aligned: 1015
     │           │               │           │                │           │
     │           └───────────────┼───────────┘                │           │
     │                           │                            │           │
     │                      Edge Gateway                      │           │
     │                           │                            │           │
     │                    Frame Buffer:                       │           │
     │                    [1010, 1015, 1020]                  │           │
     │                           │                            │           │
     │                    Match Frames                        │           │
     │                    (±50ms tolerance)                   │           │
     │                           │                            │           │
     │                    Matched Set:                        │           │
     │                    {                                   │           │
     │                      phone1: frame@1010               │           │
     │                      phone2: frame@1020               │           │
     │                      phone3: frame@1015               │           │
     │                    }                                   │           │
     │                           │                            │           │
     │                    Max Delta: 10ms ✓                  │           │
     │                    (within 50ms tolerance)            │           │
     │                           │                            │           │
     │                    Send to Reconstruction             │           │
     │                           │                            │           │
     └───────────────────────────┴────────────────────────────┘
```

## Mobile Client State Machine

```
┌──────────────────────────────────────────────────────────────┐
│              MOBILE CLIENT STATE MACHINE                     │
└──────────────────────────────────────────────────────────────┘

         ┌─────────┐
         │ INITIAL │
         └────┬────┘
              │
              │ Visit /pair?token=...
              ▼
         ┌─────────┐
         │VALIDATING│ ──── Token Invalid ───> [ERROR]
         └────┬────┘
              │
              │ Token Valid
              ▼
         ┌──────────┐
         │REGISTERING│ ── Register Failed ──> [ERROR]
         └────┬─────┘
              │
              │ Registered
              ▼
         ┌──────────┐
         │ CAMERA   │ ── Permission Denied ─> [ERROR]
         │ REQUEST  │
         └────┬─────┘
              │
              │ Camera Granted
              ▼
         ┌──────────┐
         │ NTP SYNC │ (5 rounds)
         │   (1/5)  │
         └────┬─────┘
              │
              │ Sync Complete
              ▼
      ┌───────────────┐
      │  CONNECTING   │
      │  (Try WebRTC) │
      └───────┬───────┘
              │
      ┌───────┴────────┐
      │                │
 WebRTC OK        WebRTC Failed
      │                │
      ▼                ▼
 ┌─────────┐    ┌──────────┐
 │STREAMING│    │ FALLBACK │
 │ (WebRTC)│    │(WebSocket)│
 └────┬────┘    └────┬─────┘
      │              │
      │              │ WebSocket OK
      │              ▼
      │         ┌─────────┐
      │         │STREAMING│
      │         │  (WS)   │
      │         └────┬────┘
      │              │
      └──────┬───────┘
             │
             │ Streaming Active
             ▼
        ┌─────────┐
        │ ACTIVE  │ <─── Frame Loop (15 fps)
        │         │      • Capture frame
        │         │      • Encode JPEG
        │         │      • Send with ts_device
        │         │      • Update stats
        └────┬────┘
             │
             │ User Disconnects
             │ OR
             │ Connection Lost
             ▼
        ┌─────────┐
        │DISCONNECTED│
        └─────────┘
```

## Security Model

```
┌───────────────────────────────────────────────────────────────┐
│                     SECURITY LAYERS                           │
└───────────────────────────────────────────────────────────────┘

Layer 1: Token Security
  ┌────────────────────────────────────────────────────────┐
  │  • HMAC-SHA256 signed JWT                             │
  │  • Secret key from env (or Azure Key Vault)           │
  │  • Signature prevents tampering                       │
  │  • Payload: session_id, user_id, mode, iat, exp       │
  └────────────────────────────────────────────────────────┘

Layer 2: Expiry Control
  ┌────────────────────────────────────────────────────────┐
  │  • Default TTL: 10 minutes (600s)                     │
  │  • Configurable via PAIRING_TOKEN_TTL                 │
  │  • JWT 'exp' claim enforced                           │
  │  • Expired tokens automatically rejected              │
  └────────────────────────────────────────────────────────┘

Layer 3: Single-Use Enforcement
  ┌────────────────────────────────────────────────────────┐
  │  • Track used_by set per token                        │
  │  • Device ID recorded on first use                    │
  │  • Subsequent attempts from same device rejected      │
  │  • Prevents token sharing between devices             │
  └────────────────────────────────────────────────────────┘

Layer 4: Max Devices Limit
  ┌────────────────────────────────────────────────────────┐
  │  • max_uses = expected_devices                        │
  │  • Reject if len(used_by) >= max_uses                 │
  │  • Prevents unauthorized device additions             │
  └────────────────────────────────────────────────────────┘

Layer 5: Transport Security
  ┌────────────────────────────────────────────────────────┐
  │  • Production: HTTPS/WSS required                     │
  │  • Development: HTTP/WS allowed (local only)          │
  │  • REQUIRE_HTTPS=true in production                   │
  │  • Camera access requires secure origin               │
  └────────────────────────────────────────────────────────┘

Layer 6: Privacy Controls
  ┌────────────────────────────────────────────────────────┐
  │  • Parental consent checkbox required                 │
  │  • Data retention policy displayed                    │
  │  • Default retention: 7 days                          │
  │  • Deletion on request supported                      │
  └────────────────────────────────────────────────────────┘
```

## Error Handling Flow

```
┌───────────────────────────────────────────────────────────────┐
│                    ERROR HANDLING                             │
└───────────────────────────────────────────────────────────────┘

 Error Type                Action                        User Message
 ───────────────────────────────────────────────────────────────
 Token Expired          → Reject (401)                  "Token expired, 
                                                         generate new QR"
                                                         
 Token Invalid          → Reject (401)                  "Invalid token,
                                                         check QR code"
                                                         
 Already Used           → Reject (401)                  "Token already used
                                                         by this device"
                                                         
 Max Devices            → Reject (403)                  "Maximum devices
                                                         reached"
                                                         
 Camera Denied          → Show instructions             "Camera permission
                                                         required. Enable in
                                                         Settings > Chrome >
                                                         Permissions"
                                                         
 WebRTC Failed          → Try WebSocket                 [Silent fallback]
                                                         "Using WebSocket
                                                         fallback"
                                                         
 WebSocket Failed       → Try HTTP Upload               "Connection issues,
                                                         using backup mode"
                                                         
 HTTP Failed            → Show error                    "Unable to connect.
                                                         Check WiFi"
                                                         
 Sync Failed            → Retry NTP                     "Syncing clocks..."
                                                         (auto-retry 3x)
                                                         
 Frame Invalid          → Log & skip                    [Silent, logged]
                                                         Continue streaming
                                                         
 High Latency           → Warn user                     "Poor connection.
                                                         Move closer to
                                                         router"
                                                         
 Battery Low            → Suggest tips                  "Low battery. Enable
                                                         airplane mode + WiFi"
```

## Deployment Architecture

### Local Development

```
┌────────────────────────────────────────────────────────────┐
│                  LOCAL DEVELOPMENT                         │
└────────────────────────────────────────────────────────────┘

    Coach Laptop (192.168.1.100)
         │
         │ flask run --port=5050
         │
    ┌────┴─────┐
    │  Flask   │
    │  Server  │
    └────┬─────┘
         │
         │ Same WiFi Network
         │
    ┌────┴──────────────────┐
    │                       │
Phone 1               Phone 2, 3
(192.168.1.101)       (192.168.1.102-103)
    │                       │
    │  Scan QR              │
    │  http://192.168.1.100:5050/pair?token=...
    │                       │
    └───────────────────────┘
```

### Production (Cloud)

```
┌────────────────────────────────────────────────────────────┐
│                  CLOUD PRODUCTION                          │
└────────────────────────────────────────────────────────────┘

              Internet
                 │
                 │ HTTPS/WSS
                 ▼
        ┌────────────────┐
        │  Load Balancer │
        │  (Azure ALB)   │
        └────────┬───────┘
                 │
         ┌───────┴────────┐
         │                │
    ┌────▼────┐      ┌────▼────┐
    │ Server  │      │ Server  │
    │   #1    │      │   #2    │
    └────┬────┘      └────┬────┘
         │                │
         └────────┬───────┘
                  │
           ┌──────▼──────┐
           │    Redis    │
           │   (Session  │
           │    Store)   │
           └─────────────┘
                  │
           ┌──────▼──────┐
           │   Azure     │
           │    Blob     │
           │  (Frames)   │
           └─────────────┘
                  │
           ┌──────▼──────┐
           │   TURN      │
           │   Server    │
           │ (NAT trav.) │
           └─────────────┘
```

## Performance Optimization

```
┌────────────────────────────────────────────────────────────┐
│              PERFORMANCE OPTIMIZATIONS                     │
└────────────────────────────────────────────────────────────┘

Mobile Client:
  • Frame capture:          15 fps (configurable 10-30)
  • Resolution:             1280x720 (adjustable)
  • JPEG quality:           0.8 (balance size/quality)
  • Compression:            Base64 (WebSocket) or binary (WebRTC)
  • Batching:               Single frame per send (low latency)
  • Telemetry:              Every 5s (DataChannel or WS)

Backend:
  • Token validation:       <10ms (in-memory lookup + JWT verify)
  • Frame validation:       Optional (disable PIL if slow)
  • Sync offset:            Precomputed (stored per device)
  • Session lookup:         O(1) dict access
  • Device registry:        In-memory (Redis for production)

Network:
  • WebRTC:                 Direct P2P (when possible)
  • WebSocket:              Single persistent connection
  • HTTP Upload:            Keep-alive connections
  • Compression:            JPEG already compressed
  • Frame size:             ~50-100 KB per frame

Sync:
  • NTP handshake:          5 rounds (~500ms total)
  • Offset calculation:     Median (jitter reduction)
  • Frame matching:         ±50ms tolerance
  • Buffer size:            300 frames (~30s @ 10fps)
```

## Monitoring & Observability

```
┌────────────────────────────────────────────────────────────┐
│              MONITORING POINTS                             │
└────────────────────────────────────────────────────────────┘

Metrics to Track:

  Pairing:
    • pairing_sessions_created_total
    • pairing_sessions_active
    • pairing_tokens_generated_total
    • pairing_tokens_validated_total
    • pairing_tokens_expired_total
    • pairing_devices_registered_total
    • pairing_token_validation_duration_seconds

  Streaming:
    • stream_frames_received_total (by device)
    • stream_frames_dropped_total (by device)
    • stream_frame_processing_duration_seconds
    • stream_sync_offset_ms (by device)
    • stream_active_devices

  Errors:
    • pairing_token_validation_errors_total
    • stream_frame_validation_errors_total
    • stream_connection_errors_total
    • camera_permission_denials_total

  System:
    • pairing_sessions_in_memory
    • stream_active_connections
    • http_request_duration_seconds
    • websocket_connections_active

Logs to Capture:

  INFO:
    • Session created: {session_id, mode, expected_devices}
    • Device registered: {session_id, device_id, label}
    • Stream started: {session_id, device_id, transport}
    • Sync complete: {device_id, offset_ms}

  WARNING:
    • Token near expiry: {session_id, expires_in}
    • High sync offset: {device_id, offset_ms}
    • Frame drop: {device_id, reason}
    • Connection quality poor: {device_id, latency_ms}

  ERROR:
    • Token validation failed: {token_hash, reason}
    • Frame processing failed: {device_id, error}
    • Connection lost: {device_id, reason}
    • WebRTC failed: {device_id, error, fallback}
```

---

**Version**: 1.0.0  
**Last Updated**: October 5, 2025  
**Maintainer**: Axolotl Team
