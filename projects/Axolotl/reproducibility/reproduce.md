# Axolotl - Reproducibility Guide

**Goal:** Validate Axolotl's computer vision pipeline: player detection, tracking accuracy, and metric calculation.

**Estimated Time:** 45-60 minutes  
**Requirements:** Python 3.11+, NVIDIA GPU (8GB+ VRAM), Sample match video

---

## 📋 Prerequisites

### 1. Hardware Requirements
- **GPU:** NVIDIA GPU with 8GB+ VRAM (RTX 3060 or higher recommended)
- **CUDA:** 11.8 or higher
- **RAM:** Minimum 16GB
- **Storage:** 10GB free space

### 2. Software Requirements
- **OS:** Linux (Ubuntu 22.04+) or Windows 10+ with WSL2
- **Python:** 3.11+
- **Docker:** 24.0+ (optional but recommended)
- **CUDA Drivers:** Latest NVIDIA drivers

---

## 🚀 Step-by-Step Reproduction

### Step 1: Environment Setup

```bash
# Clone repository
git clone https://github.com/THEDIFY/THEDIFY.git
cd THEDIFY/projects/Axolotl

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate  # Linux/macOS
# .\venv\Scripts\activate  # Windows

# Install dependencies
cd code
pip install -r requirements.txt
```

### Step 2: Verify GPU Setup

```bash
# Check CUDA availability
python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}')"
python -c "import torch; print(f'GPU: {torch.cuda.get_device_name(0)}')"

# Expected output:
# CUDA Available: True
# GPU: NVIDIA GeForce RTX 3060
```

### Step 3: Download Sample Video

```bash
# Sample match footage provided
cd ../reproducibility
# sample_video.mp4 (5min match clip) should be present
ls -lh sample_video.mp4
```

### Step 4: Run Analysis Pipeline

```bash
# Run full analysis on sample video
python cv_pipeline/analyze_video.py \
    --input ../reproducibility/sample_video.mp4 \
    --output ../reproducibility/output/ \
    --fps 30

# Expected processing time: ~3-5 minutes
```

### Step 5: Validate Results

```bash
# Compare output with expected results
python tests/validate_output.py \
    --actual ../reproducibility/output/metrics.json \
    --expected ../reproducibility/expected_output.json \
    --tolerance 0.05

# Expected validation:
# ✅ Player detection count: 22 ± 2
# ✅ Tracking accuracy: 92% ± 3%
# ✅ Sprint distances within 5% tolerance
# ✅ Pass accuracy metrics validated
```

---

## 📊 Expected Results

### Detection & Tracking Metrics

| Metric | Expected | Tolerance |
|--------|----------|-----------|
| **Players Detected** | 22 | ±2 |
| **Tracking Accuracy** | 92% | ±3% |
| **FPS** | 30-45 | ±5 |
| **Processing Time** | 3-5 min | ±1 min |

### Performance Metrics

**Sample Output (`output/metrics.json`):**
```json
{
  "players": {
    "player_1": {
      "total_distance": 8234.5,  // meters
      "sprint_distance": 1245.3,
      "top_speed": 28.4,         // km/h
      "passes": 45,
      "pass_accuracy": 0.867
    }
  },
  "team": {
    "possession": 0.58,
    "formation": "4-3-3"
  }
}
```

---

## 🔬 Advanced Validation

### Visual Validation

```bash
# Generate annotated video with bounding boxes
python cv_pipeline/visualize.py \
    --input ../reproducibility/sample_video.mp4 \
    --output ../reproducibility/annotated_video.mp4

# Review annotated_video.mp4 for:
# - Correct player bounding boxes
# - Tracking IDs maintained across frames
# - Pose keypoints correctly placed
```

### Benchmark Performance

```bash
# Run performance benchmark
python benchmark/fps_test.py --video ../reproducibility/sample_video.mp4

# Expected:
# Average FPS: 40-45
# GPU Memory: 6-7 GB
# CPU Usage: 30-40%
```

### Docker Reproduction

```bash
# Build and run with Docker
cd code
docker build -t axolotl:repro .

docker run --gpus all \
    -v $(pwd)/../reproducibility:/data \
    axolotl:repro \
    python cv_pipeline/analyze_video.py \
    --input /data/sample_video.mp4 \
    --output /data/docker_output/
```

---

## 🐛 Troubleshooting

### Issue: CUDA Out of Memory

**Solution:**
```bash
# Reduce batch size
python cv_pipeline/analyze_video.py \
    --input sample_video.mp4 \
    --batch-size 1  # Default is 4
```

### Issue: Low FPS (<20)

**Solution:**
- Ensure no other GPU processes running
- Check GPU utilization: `nvidia-smi`
- Reduce video resolution: `--resolution 720p`

### Issue: Poor Detection Accuracy

**Solution:**
- Verify video quality (minimum 720p)
- Check lighting conditions
- Adjust confidence threshold: `--conf-threshold 0.3`

---

## 📞 Support

**Issues?** Open at [github.com/THEDIFY/THEDIFY/issues](https://github.com/THEDIFY/THEDIFY/issues)

**Contact:** rasanti2008@gmail.com

---

## 🔐 Reproducibility Checklist

- [ ] NVIDIA GPU with CUDA installed
- [ ] Python 3.11+ environment configured
- [ ] Dependencies installed (`requirements.txt`)
- [ ] Sample video downloaded
- [ ] Analysis completed (3-5 min)
- [ ] Validation tests passed
- [ ] Annotated video generated
- [ ] Metrics within expected tolerance

---

**Last Updated:** December 17, 2025  
**Reproducibility Version:** 1.0
