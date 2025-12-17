# Smoke Detection Dataset (Temporal)

This document describes the dataset used for training the TimeSFormer model for temporal smoke detection.

## Source

The dataset consists of video clips, each labeled as either containing smoke or not. The videos are sourced from various public and private collections.

## Format

The raw videos are processed into sequences of frames. A JSON manifest file is created to organize the dataset into training, validation, and test splits.

### Manifest Format

The `smoke_timesformer.json` manifest file has the following structure:

```json
{
  "train": [
    {
      "video_path": "path/to/frames/for/video_1",
      "label": 1,
      "num_frames": 150
    },
    ...
  ],
  "val": [...],
  "test": [...]
}
```

- `video_path`: Path to the directory containing the extracted frames for a video.
- `label`: `1` for smoke, `0` for no smoke.
- `num_frames`: Total number of frames in the video.
