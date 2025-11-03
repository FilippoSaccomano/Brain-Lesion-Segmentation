# Quick Reference Guide

## 🚀 Getting Started (5 Minutes)

```matlab
% 1. Run setup
setup

% 2. Get MRI data (see data/README.md for sources)
% Place MRIdata.mat in data/ folder

% 3. Run quickstart example
run examples/quickstart.m
```

## 📂 File Organization

```
Brain-Lesion-Segmentation/
├── src/              ← Core functions (add to path)
├── examples/         ← Start here!
├── data/             ← Put MRIdata.mat here
└── docs/             ← Documentation
```

## 🎯 Common Tasks

### Basic Segmentation
```matlab
addpath(genpath('src'));
load('data/MRIdata.mat', 'original_volume');

[vol, vol_mm3, vol_cm3, areas, masks, ~] = ...
    calculateTumorVolume_3('sagittal', original_volume, 1, 1);

fprintf('Volume: %.2f cm³\n', vol_cm3);
```

### Add Noise
```matlab
noisy = add_noise(original_volume, false);
testVolume = noisy.gaussian{1}; % low Gaussian noise
```

### Test with Noisy Data
```matlab
[vol, vol_mm3, vol_cm3, areas, masks] = ...
    calculateTumorVolume_Noisy('sagittal', testVolume, 1, 'gaussian');
```

### Predict Missing Areas
```matlab
[areasWithPred, volPred, vol_mm3, vol_cm3] = ...
    predictMissingTumorAreas(tumorAreas, 1);
```

### Calculate Dice Score
```matlab
dice = calculateDiceCoefficient(manualMask, autoMask);
```

### 3D Visualization
```matlab
visualizeTumorIn3DInteractive(masks, 1);
```

## 📊 Data Requirements

**File:** `data/MRIdata.mat`
**Variable:** `original_volume`
**Type:** 3D array (uint8 or double)
**Dimensions:** [height, width, num_slices]

## 🔗 Quick Links

### Get MRI Data
- BraTS: https://www.med.upenn.edu/cbica/brats2020/data.html
- TCIA: https://www.cancerimagingarchive.net/
- OpenNeuro: https://openneuro.org/
- Kaggle: Search "brain tumor MRI"

### Documentation
- `README.md` - Main documentation
- `docs/DOCUMENTATION.md` - Function reference
- `docs/README_IT.md` - Italian version
- `docs/pipeline_guide.m` - Step-by-step guide
- `data/README.md` - Data preparation

### Examples
- `examples/quickstart.m` - 2-minute start
- `examples/complete_pipeline.m` - Full workflow
- `examples/noise_testing.m` - Robustness test

## 🛠️ Function Quick Reference

### Segmentation
| Function | Purpose |
|----------|---------|
| `calculateTumorVolume_3` | Main segmentation (clean data) |
| `calculateTumorVolume_Noisy` | Segmentation with noise filtering |
| `predictMissingTumorAreas` | Regression-based prediction |

### Utilities
| Function | Purpose |
|----------|---------|
| `add_noise` | Add Gaussian/salt-pepper/speckle noise |
| `calculateDiceCoefficient` | Accuracy evaluation |

### Visualization
| Function | Purpose |
|----------|---------|
| `visualizeTumorIn3DInteractive` | 3D tumor rendering |

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Data not found | Place `MRIdata.mat` in `data/` folder |
| Function not found | Run `addpath(genpath('src'))` |
| No tumor detected | Adjust thresholds in segmentation functions |
| Wrong variable name | Must be named `original_volume` |

## 💡 Pro Tips

1. **Always add paths first**: `addpath(genpath('src'));`
2. **Run setup once**: `setup.m` configures everything
3. **Start simple**: Use `quickstart.m` before full pipeline
4. **Test with noise**: Validates algorithm robustness
5. **Check dimensions**: Volume should be 3D array
6. **Adjust voxel size**: Critical for accurate volume calculations

## 📝 Typical Workflow

```matlab
% 1. Setup
addpath(genpath('src'));
load('data/MRIdata.mat', 'original_volume');
voxelVolume = 1; % mm³ - adjust for your data

% 2. Segment
[vol_ax, vol_mm3_ax, vol_cm3_ax, areas_ax, masks_ax, mask_ax] = ...
    calculateTumorVolume_3('axial', original_volume, voxelVolume, 1);

[vol_sg, vol_mm3_sg, vol_cm3_sg, areas_sg, masks_sg, mask_sg] = ...
    calculateTumorVolume_3('sagittal', original_volume, voxelVolume, 1);

% 3. Predict
[areas_pred, vol_pred, vol_mm3_pred, vol_cm3_pred] = ...
    predictMissingTumorAreas(areas_ax, voxelVolume);

% 4. Evaluate (if you have ground truth)
dice = calculateDiceCoefficient(groundTruthMask, mask_ax);

% 5. Visualize
combinedMasks.axial = masks_ax;
combinedMasks.sagittal = masks_sg;
visualizeTumorIn3DInteractive(combinedMasks, voxelVolume);

% 6. Results
fprintf('Axial: %.2f cm³\n', vol_cm3_ax);
fprintf('Sagittal: %.2f cm³\n', vol_cm3_sg);
fprintf('With prediction: %.2f cm³\n', vol_cm3_pred);
```

## 🎓 Learning Path

1. **Day 1**: Read README.md, run setup.m, get MRI data
2. **Day 2**: Run quickstart.m, understand basic segmentation
3. **Day 3**: Run complete_pipeline.m, explore all features
4. **Day 4**: Run noise_testing.m, test robustness
5. **Day 5**: Read pipeline_guide.m, understand algorithms
6. **Day 6**: Modify parameters, test with your own data
7. **Day 7**: Read DOCUMENTATION.md, advanced usage

## 📞 Need Help?

1. Check `docs/DOCUMENTATION.md` - Troubleshooting section
2. Read `data/README.md` - Data preparation issues
3. Open GitHub issue - Report bugs/ask questions
4. Read comments in functions - Inline documentation

---

**Remember**: This is research software, not for clinical use! 🔬
