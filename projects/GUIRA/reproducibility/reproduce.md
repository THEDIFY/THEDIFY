# GUIRA - Reproducibility Guide

**Goal:** Validate GUIRA's multi-model fire detection, temporal prediction, and geospatial risk mapping.

**Estimated Time:** 60-90 minutes  
**Requirements:** Python 3.11+, GDAL 3.8+, 16GB RAM, Sample satellite + video data

---

## 📋 Prerequisites

### 1. System Requirements
- **OS:** Linux (Ubuntu 22.04+) recommended
- **RAM:** Minimum 16GB (32GB recommended for full pipeline)
- **Storage:** 20GB free space
- **GDAL:** 3.8 or higher

### 2. Software Requirements
- **Python:** 3.11+
- **Docker:** 24.0+ (recommended for easier GDAL setup)
- **GDAL/GEOS:** Geospatial libraries

---

## 🚀 Step-by-Step Reproduction

### Step 1: Environment Setup

#### Option A: Docker (Recommended)

```bash
# Clone repository
git clone https://github.com/THEDIFY/THEDIFY.git
cd THEDIFY/projects/GUIRA

# Build Docker image
cd code
docker build -t guira:repro .

# Run container
docker run -it --rm \
    -v $(pwd)/../reproducibility:/data \
    guira:repro bash
```

#### Option B: Native Setup

```bash
# Install GDAL
sudo apt-get update
sudo apt-get install -y gdal-bin libgdal-dev python3-gdal

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
cd code
pip install -r requirements.txt
```

### Step 2: Download Test Data

```bash
# Navigate to reproducibility folder
cd ../reproducibility

# Download sample data (provided)
ls -lh sample_data/
# Expected files:
# - fire_video.mp4 (5min test footage)
# - satellite_image.tif (Sentinel-2 sample)
# - dem_terrain.tif (elevation data)
# - weather_data.json (meteorological conditions)
```

### Step 3: Run Detection Pipeline

```bash
# Run YOLOv8 fire/smoke detection
python detection/run_detection.py \
    --video sample_data/fire_video.mp4 \
    --output output/detection_results.json

# Expected:
# ✅ Fire detected: Frame 45 (confidence: 0.94)
# ✅ Smoke detected: Frame 38 (confidence: 0.87)
```

### Step 4: Temporal Analysis

```bash
# Run TimeSFormer prediction
python temporal/predict_spread.py \
    --video sample_data/fire_video.mp4 \
    --horizon 60  # Predict 60 minutes ahead
    --output output/temporal_prediction.json

# Expected lead time: 30-40 minutes
```

### Step 5: Vegetation Analysis

```bash
# Run ResNet50 on satellite imagery
python vegetation/analyze_health.py \
    --image sample_data/satellite_image.tif \
    --output output/vegetation_risk.json

# Expected: High-risk zones identified
```

### Step 6: Geospatial Risk Mapping

```bash
# Generate risk map with DEM projection
python geospatial/generate_risk_map.py \
    --detection output/detection_results.json \
    --prediction output/temporal_prediction.json \
    --vegetation output/vegetation_risk.json \
    --dem sample_data/dem_terrain.tif \
    --weather sample_data/weather_data.json \
    --output output/risk_map.html

# Open output/risk_map.html in browser
```

### Step 7: Validate Results

```bash
# Compare with expected outputs
python tests/validate_pipeline.py \
    --actual output/ \
    --expected expected_outputs/ \
    --tolerance 0.10

# Expected validation:
# ✅ Detection accuracy: 95% ± 5%
# ✅ Prediction lead time: 35 min ± 10 min
# ✅ Risk map zones match ground truth
```

---

## 📊 Expected Results

### Detection Metrics

| Metric | Expected | Tolerance |
|--------|----------|-----------|
| **Fire Detection Acc** | 95% | ±5% |
| **Smoke Detection Acc** | 90% | ±5% |
| **False Positive Rate** | 8% | ±3% |
| **Prediction Lead Time** | 35 min | ±10 min |

### Output Files

**`output/detection_results.json`:**
```json
{
  "fire_detected": true,
  "first_detection_frame": 45,
  "confidence": 0.94,
  "bounding_boxes": [...]
}
```

**`output/risk_map.html`:**
Interactive Folium map showing:
- Fire origin point
- Predicted spread zones (color-coded by time)
- Evacuation routes
- High-risk vegetation areas

---

## 🔬 Advanced Validation

### Full Pipeline Integration Test

```bash
# Run end-to-end test
python tests/integration_test.py \
    --input sample_data/ \
    --output integration_output/

# Expected: Complete workflow in 10-15 minutes
```

### Model Performance Benchmarking

```bash
# Benchmark individual models
python benchmark/model_performance.py

# Expected output:
# YOLOv8: 45 FPS (GPU) / 8 FPS (CPU)
# TimeSFormer: 12 FPS (GPU) / 2 FPS (CPU)
# ResNet50: 100 images/sec
```

---

## 🐛 Troubleshooting

### Issue: GDAL Import Error

**Solution:**
```bash
# Set environment variables
export GDAL_DATA=/usr/share/gdal
export PROJ_LIB=/usr/share/proj

# Or use Docker image (GDAL pre-configured)
```

### Issue: Satellite Image Processing Slow

**Solution:**
```bash
# Reduce resolution for testing
python vegetation/analyze_health.py \
    --image sample_data/satellite_image.tif \
    --resolution 100  # Downscale to 100m/pixel
```

### Issue: Risk Map Not Displaying

**Solution:**
- Ensure Folium installed: `pip install folium`
- Open `risk_map.html` in modern browser (Chrome/Firefox)
- Check browser console for JavaScript errors

---

## 📞 Support

**Issues?** Open at [github.com/THEDIFY/THEDIFY/issues](https://github.com/THEDIFY/THEDIFY/issues)

**Contact:** rasanti2008@gmail.com

---

## 🔐 Reproducibility Checklist

- [ ] GDAL 3.8+ installed (or Docker image built)
- [ ] Python 3.11+ environment configured
- [ ] Dependencies installed (`requirements.txt`)
- [ ] Sample data downloaded
- [ ] Detection pipeline completed
- [ ] Temporal prediction validated
- [ ] Risk map generated successfully
- [ ] Validation tests passed

---

**Last Updated:** December 17, 2025  
**Reproducibility Version:** 1.0
