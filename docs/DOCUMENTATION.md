# Brain Lesion Segmentation - Documentation

## Table of Contents
1. [Overview](#overview)
2. [Installation](#installation)
3. [Data Requirements](#data-requirements)
4. [Pipeline Workflow](#pipeline-workflow)
5. [Function Reference](#function-reference)
6. [Examples](#examples)
7. [Troubleshooting](#troubleshooting)

## Overview

This project provides a complete MATLAB pipeline for segmenting and analyzing brain lesions (tumors) from MRI scans. The pipeline includes:

- Multi-plane segmentation (axial and sagittal)
- Noise robustness testing
- Volume calculation
- Missing area prediction using polynomial regression
- Segmentation accuracy evaluation (Dice coefficient)
- 3D visualization

## Installation

### Prerequisites
- MATLAB R2019b or later
- Image Processing Toolbox
- (Optional) Statistics and Machine Learning Toolbox

### Setup
1. Clone or download this repository
2. Add the `src` directory and subdirectories to your MATLAB path:
   ```matlab
   addpath(genpath('src'));
   ```
3. Obtain MRI data (see [Data Requirements](#data-requirements))

## Data Requirements

### ⚠️ Important: Data Not Included
This repository does NOT include MRI data due to licensing restrictions. You must obtain your own data.

### Where to Get MRI Data
See `data/README.md` for detailed information on:
- Public MRI datasets (BraTS, TCIA, OpenNeuro, Kaggle)
- How to convert various formats (NIfTI, DICOM, PNG) to the required .mat format
- Creating synthetic test data

### Required Format
Place a file named `MRIdata.mat` in the `data/` directory containing:
- Variable name: `original_volume`
- Type: 3D array (uint8 or double)
- Dimensions: [height, width, num_slices]
- Content: Grayscale MRI volume

Example:
```matlab
% Load your MRI data
load('data/MRIdata.mat', 'original_volume');
% Should be a 3D array, e.g., 256x256x100
```

## Pipeline Workflow

### Basic Workflow

```matlab
% 1. Setup
addpath(genpath('src'));

% 2. Load data
load('data/MRIdata.mat', 'original_volume');

% 3. Set parameters
voxelVolume = 1; % mm³
voxelArea = 1;   % mm²

% 4. Segment tumor
[volume, volume_mm3, volume_cm3, areas, masks, selected_mask] = ...
    calculateTumorVolume_3('sagittal', original_volume, voxelVolume, voxelArea);

% 5. Predict missing areas
[areasWithPred, volPred, vol_mm3_pred, vol_cm3_pred] = ...
    predictMissingTumorAreas(areas, voxelVolume);

% 6. Visualize in 3D
visualizeTumorIn3DInteractive(masks, voxelVolume);
```

### Advanced Workflow with Noise Testing

```matlab
% Add noise
noisy_volumes = add_noise(original_volume, false);

% Test with noisy data
[volume, volume_mm3, volume_cm3, areas, masks] = ...
    calculateTumorVolume_Noisy('sagittal', noisy_volumes.gaussian{1}, voxelVolume, 'gaussian');
```

## Function Reference

### Segmentation Functions

#### `calculateTumorVolume_3`
Main segmentation function for clean data.

```matlab
[totalVolume, totalVolume_mm3, totalVolume_cm3, tumorAreas, tumorMasks, selected_mask] = ...
    calculateTumorVolume_3(plane, volumeData, voxelVolume, voxelArea)
```

**Inputs:**
- `plane`: String - 'axial' or 'sagittal'
- `volumeData`: 3D array - MRI volume
- `voxelVolume`: Scalar - Volume of one voxel (mm³)
- `voxelArea`: Scalar - Area of one voxel face (mm²)

**Outputs:**
- `totalVolume`: Total tumor volume in pixels³
- `totalVolume_mm3`: Total tumor volume in mm³
- `totalVolume_cm3`: Total tumor volume in cm³
- `tumorAreas`: Vector of tumor areas per slice
- `tumorMasks`: Struct containing binary masks for each slice
- `selected_mask`: Binary mask for a specific slice (for evaluation)

**Description:**
Segments brain tumors using threshold-based and edge detection methods. Processes slices in the specified plane and calculates total volume.

---

#### `calculateTumorVolume_Noisy`
Segmentation function with noise filtering.

```matlab
[totalVolume, totalVolume_mm3, totalVolume_cm3, tumorAreas, tumorMasks] = ...
    calculateTumorVolume_Noisy(plane, volumeData, voxelVolume, noiseType)
```

**Inputs:**
- `plane`: String - 'axial' or 'sagittal'
- `volumeData`: 3D array - Noisy MRI volume
- `voxelVolume`: Scalar - Volume of one voxel (mm³)
- `noiseType`: String - 'gaussian', 'salt_pepper', or 'speckle'

**Outputs:** Same as `calculateTumorVolume_3` (except selected_mask)

**Description:**
Similar to `calculateTumorVolume_3` but includes noise filtering appropriate for the specified noise type.

---

#### `predictMissingTumorAreas`
Predicts tumor areas in slices where detection failed.

```matlab
[tumorAreasWithPrediction, totalVolume, totalVolume_mm3, totalVolume_cm3] = ...
    predictMissingTumorAreas(tumorAreas_axial, voxelVolume)
```

**Inputs:**
- `tumorAreas_axial`: Vector of tumor areas (0 for missing slices)
- `voxelVolume`: Scalar - Volume of one voxel (mm³)

**Outputs:**
- `tumorAreasWithPrediction`: Vector with predicted values filled in
- `totalVolume`: Total volume including predictions (pixels³)
- `totalVolume_mm3`: Total volume in mm³
- `totalVolume_cm3`: Total volume in cm³

**Description:**
Uses polynomial regression to estimate tumor areas in slices where the tumor was not detected.

---

### Utility Functions

#### `add_noise`
Adds different types of noise to MRI volume.

```matlab
noisy_volumes = add_noise(original_volume, save_data)
```

**Inputs:**
- `original_volume`: 3D array - Clean MRI volume
- `save_data`: Boolean - True to save results to file

**Outputs:**
- `noisy_volumes`: Struct with fields:
  - `gaussian`: Cell array with 3 noise levels
  - `salt_pepper`: Cell array with 3 noise levels
  - `speckle`: Cell array with 3 noise levels

---

#### `calculateDiceCoefficient`
Evaluates segmentation accuracy.

```matlab
diceCoeff = calculateDiceCoefficient(manualMask, autoMask)
```

**Inputs:**
- `manualMask`: Binary mask from manual segmentation
- `autoMask`: Binary mask from automated segmentation

**Outputs:**
- `diceCoeff`: Dice coefficient (0-1, higher is better)

---

### Visualization Functions

#### `visualizeTumorIn3DInteractive`
Creates 3D visualization of segmented tumor.

```matlab
visualizeTumorIn3DInteractive(tumorMasks, voxelVolume)
```

**Inputs:**
- `tumorMasks`: Struct containing masks from axial and sagittal planes
- `voxelVolume`: Scalar - Volume of one voxel (mm³)

**Description:**
Creates an interactive 3D rendering of the tumor from both axial and sagittal plane segmentations.

## Examples

### Example 1: Basic Segmentation
See `examples/quickstart.m`

### Example 2: Complete Pipeline
See `examples/complete_pipeline.m`

Includes:
- Data loading
- Segmentation in both planes
- Volume prediction
- Accuracy evaluation
- 3D visualization

### Example 3: Noise Robustness Testing
See `examples/noise_testing.m`

Tests segmentation performance with:
- Gaussian noise
- Salt & pepper noise
- Speckle noise
- Three noise levels each

## Troubleshooting

### Data File Not Found
**Error:** `MRI data file not found!`

**Solution:** 
1. Check that `MRIdata.mat` exists in the `data/` directory
2. See `data/README.md` for instructions on obtaining and preparing data

### Incorrect Variable Name
**Error:** `Undefined variable 'original_volume'`

**Solution:**
Your .mat file must contain a variable named `original_volume`. Load your data and save it with the correct variable name:
```matlab
load('your_data.mat');
original_volume = your_variable_name;
save('data/MRIdata.mat', 'original_volume');
```

### Dimension Mismatch
**Error:** Related to array dimensions

**Solution:**
Ensure your volume data is a 3D array with dimensions [height, width, num_slices]:
```matlab
size(original_volume) % Should return something like [256 256 100]
```

### Path Not Set
**Error:** `Unrecognized function or variable`

**Solution:**
Add the source directories to your path:
```matlab
addpath(genpath('src'));
```

### No Tumor Detected
**Warning:** `Number of Slices where the tumor is not found: XX`

**Solution:**
- Check that your data contains visible lesions
- Adjust threshold values in `calculateTumorVolume_3.m` or `calculateTumorVolume_Noisy.m`
- Verify slice range is correct for your data

### Memory Issues
**Error:** Out of memory

**Solution:**
- Close unnecessary MATLAB figures
- Process fewer slices at a time
- Use smaller data or downsample your volume

## Advanced Configuration

### Adjusting Segmentation Parameters

Edit `src/segmentation/calculateTumorVolume_3.m`:

```matlab
% Line 26-36: Slice ranges and thresholds
if strcmp(plane, 'axial')
    sliceStart = 65;          % First slice to process
    sliceEnd = 89;            % Last slice to process
    thresholdValue1 = 255;    % Upper threshold
    thresholdValue2 = 110;    % Lower threshold
    roiBounds = [98, 158; 128, 180]; % Region of interest
```

Adjust these values based on your specific data characteristics.

### Modifying Noise Levels

Edit `src/utils/add_noise.m`:

```matlab
% Line 8: Adjust noise levels
noise_levels = [0.01, 0.1, 0.3]; % Low, medium, high
```

## Citation

If you use this code in your research, please cite appropriately and ensure compliance with all medical data regulations.

## License

See LICENSE file for details.
