# Fire Spread Dataset

This document describes the dataset for the physics-neural hybrid fire spread model.

## Source

The dataset consists of sequences of raster data, representing the evolution of a fire over time. Each raster can have multiple channels, including:

-   Fire intensity/presence
-   Vegetation type/density
-   Terrain elevation
-   Wind speed and direction (as separate channels)

## Format

The data is stored as sequences of `.tif` (GeoTIFF) files. A JSON manifest (`fire_spread.json`) is used to organize these sequences into training, validation, and test sets.

### Manifest Format

```json
{
  "train": [
    [
      "path/to/sequence_1/frame_00.tif",
      "path/to/sequence_1/frame_01.tif",
      ...
    ],
    ...
  ],
  "val": [...],
  "test": [...]
}
```

Each entry in the splits is a list of paths to the raster files in a single temporal sequence.
