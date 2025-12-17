# Fauna Detection & Count Dataset

This document describes the dataset for fauna detection (YOLOv8) and density estimation (CSRNet).

## Source

The dataset is a collection of aerial images containing various animal species.

## Format for YOLOv8 (Detection)

The dataset is converted to YOLOv8 format for object detection.

- `images/`: Image files.
- `labels/`: YOLO format annotation files (`<class_id> <x_center> <y_center> <width> <height>`).

### Species Classes

1.  `deer`
2.  `elk`
3.  `bear`
4.  `bird`
5.  `other`

## Format for CSRNet (Counting)

For density estimation and counting, the dataset is processed to include ground truth density maps.

- `images/`: Image files.
- `ground_truth/`: `.mat` files containing point annotations for each animal.

A JSON manifest `fauna_csrnet.json` is created to manage the data splits.
