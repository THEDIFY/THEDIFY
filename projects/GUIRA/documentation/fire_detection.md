# Fire Detection Dataset

This document describes the fire detection dataset used for training the YOLOv8 model.

## Source

The dataset is a collection of images sourced from various public and private collections. It contains images with and without fire and smoke.

## Format

The dataset is provided in YOLOv8 format.

### Directory Structure

- `images/`: Contains the image files (e.g., `.jpg`, `.png`).
- `labels/`: Contains the corresponding annotation files in YOLO format. Each `.txt` file has one line per bounding box in the format: `<class_id> <x_center> <y_center> <width> <height>`.

### Classes

1.  `fire`
2.  `smoke`
