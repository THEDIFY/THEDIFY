# Vegetation Health Dataset

This document describes the dataset for vegetation health classification.

## Source

The dataset consists of aerial or satellite images of vegetation, classified into different health categories.

## Format

The dataset is organized into subdirectories, each corresponding to a health class. A JSON manifest is generated to manage the data splits and associated metadata.

### Classes

1.  `healthy`
2.  `dry`
3.  `burned`

### Manifest Format (`vegetation_health.json`)

```json
{
  "train": [
    {
      "image_path": "path/to/image.jpg",
      "label": 0,
      "vari": 0.123
    },
    ...
  ],
  "val": [...],
  "test": [...]
}
```

- `image_path`: Path to the image file.
- `label`: The health class ID.
- `vari`: The calculated Visible Atmospherically Resistant Index (VARI) for the image.
