# Fire Prevention System - Next Steps & Training Guide

This guide provides step-by-step instructions to train all models in the fire prevention system, with paste-ready terminal commands for parallel training and deployment.

## 🚀 Quick Start - Complete Training Pipeline

### Prerequisites

Ensure you have the required environment set up:

```bash
# Verify Python version (3.10+)
python --version

# Check GPU availability
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"

# Verify disk space (need ~50GB for datasets and models)
df -h .

# Install dependencies
pip install -r requirements.txt
```

## 📋 Training Sequence Overview

The models should be trained in the following order for optimal results:

1. **Fire Detection (YOLOv8)** - Foundation model, needed by others
2. **Smoke Detection (TimeSFormer)** - Temporal analysis 
3. **Vegetation Health (ResNet50+VARI)** - Fuel condition assessment
4. **Fauna Detection (YOLOv8+CSRNet)** - Wildlife monitoring
5. **Fire Spread (Hybrid Physics-ML)** - Prediction model

Total estimated training time: **18-24 hours** on RTX 3080/4090

## 🔥 Phase 1: Data Preparation

Run all data preparation steps first:

```bash
# Terminal 1: Download all datasets
cd /home/runner/work/FIREPREVENTION/FIREPREVENTION
python scripts/download_all.py --config config.yaml

# Convert datasets to required formats
python scripts/convert_all.py --config config.yaml

# Verify data integrity
python scripts/validate_datasets.py --config config.yaml --check-all
```

Expected output structure:
```
data/
├── raw/
│   ├── fire/           # Raw fire detection images
│   ├── smoke/          # Raw smoke video sequences  
│   ├── fauna/          # Raw wildlife imagery
│   └── vegetation/     # Raw vegetation health data
└── processed/
    ├── fire/           # YOLO format fire data
    ├── smoke/          # Processed video clips
    ├── fauna/          # YOLO + density map data
    └── vegetation/     # Health classification data
```

## 🔥 Phase 2: Fire Detection Training (Priority 1)

**Training time**: ~4-6 hours on RTX 3080

```bash
# Terminal 1: Fire Detection Training
cd /home/runner/work/FIREPREVENTION/FIREPREVENTION

# Standard training (recommended)
python models/fire_yolov8/train_fire.py \
  --config config.yaml \
  --epochs 150 \
  --batch-size 16 \
  --device 0 \
  --project runs/fire_yolov8 \
  --name baseline_training

# Alternative: Quick training for testing (30 minutes)
python models/fire_yolov8/train_fire.py \
  --config config.yaml \
  --epochs 20 \
  --batch-size 8 \
  --device 0 \
  --project runs/fire_yolov8 \
  --name quick_test

# Alternative: High-performance training (8+ hours, better accuracy)
python models/fire_yolov8/train_fire.py \
  --config config.yaml \
  --epochs 300 \
  --batch-size 32 \
  --device 0 \
  --img-size 1280 \
  --project runs/fire_yolov8 \
  --name high_performance
```

**Monitor progress**:
```bash
# In another terminal, monitor training
tensorboard --logdir runs/fire_yolov8 --port 6006
# Open browser to http://localhost:6006
```

**Validation commands**:
```bash
# Evaluate trained model
python scripts/evaluate_fire_yolov8.py \
  --config config.yaml \
  --output experiments/fire_yolov8_evaluation

# Export for deployment
python scripts/export_fire_yolov8.py \
  --formats onnx torchscript \
  --output models/fire_yolov8/exports/
```

## 💨 Phase 3: Smoke Detection Training (Can run in parallel)

**Training time**: ~8-12 hours on RTX 4090

```bash
# Terminal 2: Smoke Detection Training
cd /home/runner/work/FIREPREVENTION/FIREPREVENTION

# Standard training
python models/smoke_timesformer/train_smoke.py \
  --config config.yaml \
  --epochs 30 \
  --batch-size 8 \
  --device 0 \
  --sequence-length 8 \
  --project runs/smoke_timesformer \
  --name baseline_training

# Memory-optimized training (if GPU memory < 16GB)  
python models/smoke_timesformer/train_smoke.py \
  --config config.yaml \
  --epochs 30 \
  --batch-size 4 \
  --device 0 \
  --sequence-length 6 \
  --gradient-checkpointing \
  --project runs/smoke_timesformer \
  --name memory_optimized

# High-quality training (24+ hours)
python models/smoke_timesformer/train_smoke.py \
  --config config.yaml \
  --epochs 50 \
  --batch-size 12 \
  --device 0 \
  --sequence-length 16 \
  --project runs/smoke_timesformer \
  --name high_quality
```

**Validation commands**:
```bash
# Evaluate smoke model
python scripts/evaluate_smoke_timesformer.py \
  --config config.yaml \
  --output experiments/smoke_timesformer_evaluation

# Export smoke model
python scripts/export_smoke_timesformer.py \
  --formats torchscript onnx \
  --output models/smoke_timesformer/exports/
```

## 🌿 Phase 4: Vegetation Health Training

**Training time**: ~2-3 hours on RTX 3080

```bash  
# Terminal 3: Vegetation Health Training
cd /home/runner/work/FIREPREVENTION/FIREPREVENTION

# Standard training with VARI integration
python models/vegetation_resnet_vari/train_vegetation.py \
  --config config.yaml \
  --epochs 35 \
  --batch-size 24 \
  --device 0 \
  --vari-enabled \
  --project runs/vegetation_resnet_vari \
  --name vari_integration

# Without VARI (baseline comparison)
python models/vegetation_resnet_vari/train_vegetation.py \
  --config config.yaml \
  --epochs 35 \
  --batch-size 32 \
  --device 0 \
  --project runs/vegetation_resnet_vari \
  --name baseline_no_vari

# High-resolution training (requires more memory)
python models/vegetation_resnet_vari/train_vegetation.py \
  --config config.yaml \
  --epochs 50 \
  --batch-size 16 \
  --device 0 \
  --img-size 448 \
  --vari-enabled \
  --project runs/vegetation_resnet_vari \
  --name high_resolution
```

**Validation commands**:
```bash
# Evaluate vegetation model
python scripts/evaluate_vegetation_resnet_vari.py \
  --config config.yaml \
  --output experiments/vegetation_evaluation

# Export vegetation model  
python scripts/export_vegetation_resnet_vari.py \
  --formats torchscript onnx \
  --include-vari-helper \
  --output models/vegetation_resnet_vari/exports/
```

## 🦌 Phase 5: Fauna Detection Training

**Training time**: ~12-16 hours total (dual component)

```bash
# Terminal 4: Fauna Detection Training
cd /home/runner/work/FIREPREVENTION/FIREPREVENTION

# Stage 1: Train YOLOv8 detector (6-8 hours)
python models/fauna_yolov8_csrnet/train_yolo.py \
  --config config.yaml \
  --epochs 200 \
  --batch-size 12 \
  --device 0 \
  --img-size 960 \
  --project runs/fauna_yolov8 \
  --name yolo_detector

# Stage 2: Train CSRNet density estimator (4-6 hours) 
python models/fauna_yolov8_csrnet/train_csrnet.py \
  --config config.yaml \
  --epochs 100 \
  --batch-size 8 \
  --device 0 \
  --project runs/fauna_csrnet \
  --name density_estimator

# Stage 3: Joint fine-tuning (2-4 hours)
python models/fauna_yolov8_csrnet/train_joint.py \
  --config config.yaml \
  --epochs 50 \
  --batch-size 6 \
  --device 0 \
  --project runs/fauna_joint \
  --name joint_finetuning
```

**Alternative: One-step training** (experimental):
```bash
# All-in-one fauna training script
python models/fauna_yolov8_csrnet/train_fauna.py \
  --config config.yaml \
  --train-yolo \
  --train-csrnet \
  --joint-finetune \
  --device 0 \
  --project runs/fauna_complete
```

**Validation commands**:
```bash
# Evaluate fauna models
python scripts/evaluate_fauna_yolo_csrnet.py \
  --config config.yaml \
  --output experiments/fauna_evaluation

# Export fauna models
python scripts/export_fauna_yolo_csrnet.py \
  --formats onnx torchscript \
  --output models/fauna_yolov8_csrnet/exports/
```

## 🔥 Phase 6: Fire Spread Prediction Training

**Training time**: ~6-8 hours on RTX 4090

```bash
# Terminal 5: Fire Spread Training  
cd /home/runner/work/FIREPREVENTION/FIREPREVENTION

# Standard hybrid physics-ML training
python models/spread_hybrid/train_spread.py \
  --config config.yaml \
  --epochs 50 \
  --batch-size 4 \
  --device 0 \
  --physics-lambda 0.1 \
  --project runs/spread_hybrid \
  --name physics_hybrid

# Pure ML training (no physics constraints)
python models/spread_hybrid/train_spread.py \
  --config config.yaml \
  --epochs 50 \
  --batch-size 6 \
  --device 0 \
  --physics-lambda 0.0 \
  --project runs/spread_hybrid \
  --name pure_ml

# High-physics constraint training
python models/spread_hybrid/train_spread.py \
  --config config.yaml \
  --epochs 75 \
  --batch-size 3 \
  --device 0 \
  --physics-lambda 0.3 \
  --project runs/spread_hybrid \
  --name high_physics
```

**Validation commands**:
```bash
# Evaluate spread model
python scripts/evaluate_spread_hybrid.py \
  --config config.yaml \
  --output experiments/spread_evaluation

# Export spread model
python scripts/export_spread_hybrid.py \
  --formats torchscript onnx \
  --include-physics-helper \
  --output models/spread_hybrid/exports/
```

## 🔄 Parallel Training Strategy

To maximize GPU utilization, you can train multiple models in parallel:

### Option 1: Single GPU, Sequential Training
```bash
# Run models one after another (safest)
./scripts/train_sequence.sh
```

### Option 2: Multi-GPU Parallel Training  
```bash
# Terminal 1 (GPU 0): Fire Detection
CUDA_VISIBLE_DEVICES=0 python models/fire_yolov8/train_fire.py --device 0

# Terminal 2 (GPU 1): Vegetation Health  
CUDA_VISIBLE_DEVICES=1 python models/vegetation_resnet_vari/train_vegetation.py --device 0

# Terminal 3 (GPU 2): Fauna Detection YOLO
CUDA_VISIBLE_DEVICES=2 python models/fauna_yolov8_csrnet/train_yolo.py --device 0
```

### Option 3: Memory-Aware Parallel Training
```bash
# Light models together on single GPU
python models/fire_yolov8/train_fire.py --batch-size 8 --device 0 &
python models/vegetation_resnet_vari/train_vegetation.py --batch-size 12 --device 0 &
wait
```

## 🧪 Rapid Prototyping Mode (Fast Training)

For quick testing and development:

```bash
# Create development environment
export FIRE_PREVENTION_MODE="development"
export EPOCHS_OVERRIDE="10"
export BATCH_SIZE_OVERRIDE="4"

# Quick training all models (2-3 hours total)
python scripts/train_all_quick.py \
  --config config.yaml \
  --dev-mode \
  --epochs 10 \
  --small-datasets
```

## 📊 Training Monitoring & Management

### Real-time Monitoring Setup
```bash
# Terminal for monitoring (run alongside training)
# Install monitoring tools
pip install tensorboard wandb

# Start TensorBoard  
tensorboard --logdir runs/ --port 6006 --reload_interval 30

# Optional: Weights & Biases monitoring
export WANDB_PROJECT="fire-prevention-training"
wandb login
# Training scripts will automatically log to W&B
```

### Training Management Scripts
```bash
# Check training status
python scripts/check_training_status.py --all

# Resume interrupted training
python models/fire_yolov8/train_fire.py --resume runs/fire_yolov8/baseline_training/weights/last.pt

# Compare model performance
python scripts/compare_models.py --experiments experiments/ --output comparison_report.html
```

## 🎯 Model Evaluation Pipeline

After training completion, run comprehensive evaluation:

```bash
# Evaluate all trained models
python scripts/evaluate_all_models.py \
  --config config.yaml \
  --output experiments/complete_evaluation \
  --generate-reports

# Generate comparison dashboard
python scripts/generate_dashboard.py \
  --experiments experiments/ \
  --output dashboard/index.html

# Test end-to-end pipeline
python test_complete_pipeline.py \
  --config config.yaml \
  --test-video data/test_videos/sample_fire_scene.mp4
```

## 🚀 Deployment Preparation  

Once training is complete:

```bash
# Export all models for production
python scripts/export_all_models.py \
  --formats onnx torchscript \
  --optimize-for-inference \
  --output production_models/

# Create deployment package
python scripts/create_deployment_package.py \
  --models production_models/ \
  --config config.yaml \
  --output fire_prevention_v1.0.tar.gz

# Test deployment package
python scripts/test_deployment.py \
  --package fire_prevention_v1.0.tar.gz \
  --test-data data/test_samples/
```

## ⚠️ Troubleshooting Common Issues

### GPU Memory Issues
```bash
# Reduce batch size
export CUDA_VISIBLE_DEVICES=0
python model_train.py --batch-size 2 --gradient-accumulation 4

# Enable gradient checkpointing
python model_train.py --gradient-checkpointing --mixed-precision

# Monitor GPU memory
watch -n 1 nvidia-smi
```

### Training Instability
```bash
# Lower learning rate
python model_train.py --lr 1e-5 --lr-warmup 1000

# Add regularization
python model_train.py --weight-decay 1e-4 --dropout 0.2
```

### Data Loading Issues  
```bash
# Check data integrity
python scripts/validate_datasets.py --fix-corrupted

# Reduce workers if memory constrained
python model_train.py --num-workers 2
```

### Slow Training
```bash
# Profile training bottlenecks
python -m torch.profiler model_train.py --profile

# Optimize data loading
python model_train.py --pin-memory --persistent-workers
```

## 📈 Performance Targets

### Minimum Acceptable Performance
- **Fire Detection**: mAP@0.5 ≥ 0.60
- **Smoke Detection**: AUC ≥ 0.70
- **Vegetation Health**: Accuracy ≥ 0.75
- **Fauna Detection**: mAP@0.5 ≥ 0.65, Density MAE < 10%
- **Fire Spread**: IoU@1h ≥ 0.60

### Production Ready Performance
- **Fire Detection**: mAP@0.5 ≥ 0.75
- **Smoke Detection**: AUC ≥ 0.85  
- **Vegetation Health**: Accuracy ≥ 0.80
- **Fauna Detection**: mAP@0.5 ≥ 0.70, Density MAE < 8%
- **Fire Spread**: IoU@1h ≥ 0.70

### Speed Requirements (RTX 3070)
- **Fire Detection**: ≥15 FPS on 640×640 input
- **Smoke Detection**: ≥2 FPS on 8-frame sequences
- **Vegetation Health**: ≥10 FPS on 224×224 patches  
- **Fauna Detection**: ≥5 FPS on 960×960 input
- **Fire Spread**: ≥1 FPS on 256×256 grids

## 🎉 Completion Checklist

After all training is complete, verify:

- [ ] All models achieve minimum performance targets
- [ ] Models exported to production formats (ONNX/TorchScript)  
- [ ] Evaluation reports generated in `experiments/`
- [ ] Integration tests pass with `test_complete_pipeline.py`
- [ ] Speed benchmarks meet real-time requirements
- [ ] Documentation updated with final model performance
- [ ] Deployment package created and tested

## 🔗 Next Steps After Training

1. **Integration Testing**: Test models in complete pipeline
2. **Field Validation**: Deploy on test drone missions  
3. **Performance Optimization**: Profile and optimize inference speed
4. **Continuous Learning**: Set up model retraining pipeline
5. **Monitoring Setup**: Deploy model performance monitoring
6. **Documentation**: Update deployment guides with final configs

## 📞 Getting Help

If you encounter issues during training:

1. **Check logs**: Training logs are saved in `runs/` directories
2. **Review documentation**: Model-specific docs in `docs/models/`
3. **Performance issues**: Check `scripts/benchmark_*.py` for profiling
4. **Data issues**: Run `scripts/validate_datasets.py --debug`
5. **Create issue**: Open GitHub issue with training logs and config

---

**Happy Training! 🔥🚁🌲**