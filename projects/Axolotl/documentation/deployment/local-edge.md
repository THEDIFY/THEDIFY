# Local Edge Gateway - Quick Start

## 30-Second Setup

```bash
# 1. Clone & install
git clone https://github.com/THEDIFY/axolotl.git
cd axolotl
pip install -r requirements.txt flask flask-socketio PyJWT

# 2. Copy config
cp .env.local.example .env.local

# 3. Start gateway
./scripts/run_local_edge.sh
```

## 60-Second Demo

```bash
# Start gateway (terminal 1)
./scripts/run_local_edge.sh

# In another terminal, test the workflow:

# 1. Register device
curl -X POST http://localhost:5050/api/local/pair/register \
  -H "Content-Type: application/json" \
  -d '{"device_id":"phone-1","user_id":"demo","label":"phone-left"}'

# Save the pairing_token from response

# 2. Start session
curl -X POST http://localhost:5050/api/local/demo-session/start \
  -H "Content-Type: application/json" \
  -d '{
    "user_id":"demo",
    "player_id":"player1",
    "phones":["phone-1"],
    "expected_camera_setup":"3phone-tri"
  }'

# 3. Check status
curl http://localhost:5050/api/local/demo-session/status

# 4. Stop session
curl -X POST http://localhost:5050/api/local/demo-session/stop
```

## Phone Client Example

```javascript
// Connect to gateway
const ws = new WebSocket('ws://192.168.1.100:5050/socketio/?EIO=4&transport=websocket');

ws.onopen = () => {
  // Join session
  ws.send(JSON.stringify({
    type: 'join_session',
    session_id: 'demo-session',
    device_id: 'phone-1',
    pairing_token: '<YOUR_TOKEN>'
  }));
};

// Send frame
function sendFrame(imageData) {
  ws.send(JSON.stringify({
    type: 'frame',
    session_id: 'demo-session',
    device_id: 'phone-1',
    frame_b64: imageData.split(',')[1],
    ts_device: Date.now()
  }));
}
```

## Common Issues

**Port already in use?**
```bash
./scripts/run_local_edge.sh --port 8080
```

**Phones can't connect?**
- Check all devices on same Wi-Fi
- Try laptop's IP address instead of hostname
- Disable firewall temporarily

**High clock skew?**
- Move phones closer to router
- Reduce network congestion
- Check Wi-Fi signal strength

## What's Next?

- See `docs/LOCAL_SETUP.md` for complete guide
- See `PHASE_7_1_COMPLETE.md` for implementation details
- Run tests: `pytest tests/test_local_edge.py`
- Check logs: `./app/backend/local_storage/`

## Quick Commands

```bash
# Health check
curl http://localhost:5050/api/local/health

# List all endpoints
curl http://localhost:5050/api

# Run tests
pytest tests/test_local_edge.py -v

# Check logs (if running as service)
tail -f /var/log/axolotl/edge_gateway.log
```

## Configuration Presets

### 2-Phone Setup
```bash
MAX_PHONES=2
MIN_PHONES=2
MAX_PHONE_FPS=15
```

### 3-Phone Setup (default)
```bash
MAX_PHONES=3
MIN_PHONES=2
MAX_PHONE_FPS=10
```

### High-Quality Mode
```bash
MAX_PHONE_FPS=15
FRAME_BUFFER_SIZE=450
SYNC_TOLERANCE_MS=30
```

### Low-Bandwidth Mode
```bash
MAX_PHONE_FPS=5
FRAME_BUFFER_SIZE=150
```

## Support

- 📖 Full docs: `docs/LOCAL_SETUP.md`
- 🧪 Run tests: `tests/test_local_edge.py`
- 💬 Issues: https://github.com/THEDIFY/axolotl/issues
- 📧 Email: support@axolotl.ai (placeholder)

---

**Ready to capture in 5 minutes!** 🎥⚽
