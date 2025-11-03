# Pipeline Architecture

## Overview Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Brain Lesion Segmentation                     │
│                         Pipeline v2.0                            │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ INPUT: 3D MRI Volume (data/MRIdata.mat)                         │
│ Format: [height × width × slices] uint8 or double               │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                    ┌──────────┴──────────┐
                    │   PREPROCESSING     │
                    │  (Optional Noise)   │
                    └──────────┬──────────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
        ┌───────▼──────┐              ┌──────▼───────┐
        │    AXIAL     │              │  SAGITTAL    │
        │ Segmentation │              │ Segmentation │
        └───────┬──────┘              └──────┬───────┘
                │                             │
                │  Per-slice Processing:      │
                │  • Normalization           │
                │  • Thresholding            │
                │  • ROI Filtering           │
                │  • Morphological Ops       │
                │  • Component Analysis      │
                │                             │
        ┌───────▼──────┐              ┌──────▼───────┐
        │ Tumor Areas  │              │ Tumor Areas  │
        │   (Vector)   │              │   (Vector)   │
        └───────┬──────┘              └──────┬───────┘
                │                             │
                │                             │
        ┌───────▼──────┐              ┌──────▼───────┐
        │  Volume Calc │              │  Volume Calc │
        │ pixels³/mm³  │              │ pixels³/mm³  │
        └───────┬──────┘              └──────┬───────┘
                │                             │
                │                             │
        ┌───────▼──────────┐                 │
        │ Missing Area     │                 │
        │   Prediction     │                 │
        │ (Polynomial Reg) │                 │
        └───────┬──────────┘                 │
                │                             │
                └──────────┬──────────────────┘
                           │
                    ┌──────▼──────┐
                    │  EVALUATION │
                    │ (Dice Score)│
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │     3D      │
                    │VISUALIZATION│
                    └─────────────┘
                           │
                    ┌──────▼──────┐
                    │   RESULTS   │
                    │  - Volumes  │
                    │  - Metrics  │
                    │  - Figures  │
                    └─────────────┘
```

## Data Flow

```
┌──────────────┐
│ User's MRI   │
│   Dataset    │
└──────┬───────┘
       │
       │ Convert to .mat
       ▼
┌──────────────────┐
│ MRIdata.mat      │
│ ┌──────────────┐ │
│ │original_     │ │
│ │volume        │ │
│ │[H×W×S]       │ │
│ └──────────────┘ │
└──────┬───────────┘
       │
       │ Load
       ▼
┌──────────────────┐
│ Pipeline         │
│ Processing       │
└──────┬───────────┘
       │
       ├─► Figures (visualization)
       ├─► Metrics (printed)
       └─► 3D Model (interactive)
```

## Module Dependencies

```
┌────────────────────────────────────────────────────────┐
│                      Examples                          │
│  quickstart.m | complete_pipeline.m | noise_testing.m  │
└───────────────────────┬────────────────────────────────┘
                        │ uses
                        ▼
┌────────────────────────────────────────────────────────┐
│                   Source Modules                       │
├────────────────────────────────────────────────────────┤
│                                                        │
│  ┌──────────────────┐  ┌──────────────────┐          │
│  │  Segmentation    │  │  Visualization   │          │
│  ├──────────────────┤  ├──────────────────┤          │
│  │ • Tumor Vol 3    │  │ • 3D Interactive │          │
│  │ • Tumor Vol Noisy│  └──────────────────┘          │
│  │ • Predict Areas  │                                 │
│  └──────────────────┘                                 │
│                                                        │
│  ┌──────────────────┐                                 │
│  │    Utilities     │                                 │
│  ├──────────────────┤                                 │
│  │ • Add Noise      │                                 │
│  │ • Dice Coeff     │                                 │
│  └──────────────────┘                                 │
│                                                        │
└────────────────────────────────────────────────────────┘
                        │
                        │ requires
                        ▼
┌────────────────────────────────────────────────────────┐
│               MATLAB Toolboxes                         │
│  • Image Processing Toolbox (required)                 │
│  • Statistics Toolbox (optional)                       │
└────────────────────────────────────────────────────────┘
```

## Segmentation Algorithm Flow

```
Input Slice
     │
     ▼
┌─────────────────┐
│ Normalize       │ (map to 0-255)
│ Intensity       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Apply           │ (low < intensity < high)
│ Threshold       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ ROI Mask        │ (focus on brain region)
│ Filtering       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Morphological   │ (opening, closing)
│ Operations      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Edge Detection  │ (Canny - sagittal only)
│ (Optional)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Connected       │ (find components)
│ Components      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Select Largest  │ (area > threshold)
│ Component       │
└────────┬────────┘
         │
         ▼
  Binary Tumor Mask
```

## File Organization Logic

```
Brain-Lesion-Segmentation/
│
├── Core Functions (src/)
│   ├── What: Functions user calls
│   ├── Why: Reusable components
│   └── Structure:
│       ├── segmentation/ → Image analysis
│       ├── visualization/ → Display results
│       └── utils/ → Helper functions
│
├── Usage Examples (examples/)
│   ├── What: Runnable scripts
│   ├── Why: Show how to use functions
│   └── Files:
│       ├── quickstart.m → Minimal example
│       ├── complete_pipeline.m → Full workflow
│       └── noise_testing.m → Robustness test
│
├── User Data (data/)
│   ├── What: User-provided MRI files
│   ├── Why: Not included (licensing)
│   └── Contains: README with instructions
│
└── Documentation (docs/)
    ├── What: Guides and references
    ├── Why: Help users understand
    └── Files:
        ├── DOCUMENTATION.md → Function reference
        ├── README_IT.md → Italian guide
        └── pipeline_guide.m → Walkthrough
```

## Noise Robustness Testing Flow

```
Original Volume
       │
       ├──► Gaussian Noise ──► Level 1 (0.01) ──┐
       │                   ├──► Level 2 (0.10) ──┤
       │                   └──► Level 3 (0.30) ──┤
       │                                         │
       ├──► Salt&Pepper ────► Level 1 (0.01) ──┤
       │                   ├──► Level 2 (0.10) ──┤
       │                   └──► Level 3 (0.30) ──┤
       │                                         │
       └──► Speckle ────────► Level 1 (0.01) ──┤
                           ├──► Level 2 (0.10) ──┤
                           └──► Level 3 (0.30) ──┤
                                                 │
                           ┌─────────────────────┘
                           │
                           ▼
                    Filter Application
                    • Gaussian → Average Filter
                    • Salt&Pepper → Median Filter
                    • Speckle → Gaussian Filter
                           │
                           ▼
                      Segmentation
                           │
                           ▼
                    Volume Comparison
                    • Plot results
                    • Calculate differences
                    • Assess robustness
```

## Key Parameters

```
┌─────────────────────────────────────────┐
│ Voxel Parameters (User-Defined)        │
├─────────────────────────────────────────┤
│ voxelDimensions = [x, y, z] mm          │
│ voxelVolume = x * y * z mm³             │
│ voxelArea = x * y mm²                   │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Segmentation Parameters (Tunable)      │
├─────────────────────────────────────────┤
│ Axial:                                  │
│   sliceStart = 65, sliceEnd = 89        │
│   threshold1 = 255, threshold2 = 110    │
│   roiBounds = [98,158; 128,180]         │
│                                         │
│ Sagittal:                               │
│   sliceStart = 108, sliceEnd = 143      │
│   threshold1 = 245, threshold2 = 105    │
│   roiBounds = [10,60; 135,180]          │
└─────────────────────────────────────────┘
```

---

**See docs/DOCUMENTATION.md for detailed function documentation**
