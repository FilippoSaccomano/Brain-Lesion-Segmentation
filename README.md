# Brain Lesion Segmentation

A comprehensive MATLAB pipeline for automatic segmentation and analysis of brain lesions (tumors) from MRI scans.

## 🎯 Features

- **Multi-plane Segmentation**: Analyze tumors in both axial and sagittal planes
- **Noise Robustness**: Test segmentation with Gaussian, salt & pepper, and speckle noise
- **Volume Calculation**: Accurate tumor volume estimation in pixels³, mm³, and cm³
- **Missing Area Prediction**: Polynomial regression to estimate tumor in undetected slices
- **Accuracy Evaluation**: Dice coefficient calculation for segmentation validation
- **3D Visualization**: Interactive 3D rendering of segmented tumors

## 📁 Repository Structure

```
Brain-Lesion-Segmentation/
├── src/                          # Source code
│   ├── segmentation/             # Segmentation algorithms
│   │   ├── calculateTumorVolume_3.m
│   │   ├── calculateTumorVolume_Noisy.m
│   │   └── predictMissingTumorAreas.m
│   ├── visualization/            # 3D visualization
│   │   └── visualizeTumorIn3DInteractive.m
│   └── utils/                    # Utility functions
│       ├── add_noise.m
│       └── calculateDiceCoefficient.m
├── examples/                     # Example scripts
│   ├── quickstart.m              # Quick start example
│   ├── complete_pipeline.m       # Full pipeline demonstration
│   └── noise_testing.m           # Noise robustness testing
├── data/                         # Data directory (you must add your own)
│   └── README.md                 # Instructions for obtaining MRI data
├── docs/                         # Documentation
│   └── DOCUMENTATION.md          # Complete documentation
├── .gitignore                    # Git ignore rules
├── LICENSE                       # License information
└── README.md                     # This file
```

## 🚀 Quick Start

### Prerequisites

- MATLAB R2019b or later
- Image Processing Toolbox
- (Optional) Statistics and Machine Learning Toolbox

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/FilippoSaccomano/Brain-Lesion-Segmentation.git
   cd Brain-Lesion-Segmentation
   ```

2. **Obtain MRI Data** (see [Data Requirements](#-data-requirements))

3. Run the quick start example:
   ```matlab
   run examples/quickstart.m
   ```

## 📊 Data Requirements

### ⚠️ Important: Data Not Included

This repository does **NOT** include MRI data due to licensing restrictions. You must obtain your own MRI data.

### Where to Get Data

Public MRI datasets are available from:
- **BraTS** (Brain Tumor Segmentation Challenge): https://www.med.upenn.edu/cbica/brats2020/data.html
- **TCIA** (The Cancer Imaging Archive): https://www.cancerimagingarchive.net/
- **OpenNeuro**: https://openneuro.org/
- **Kaggle**: Search for "brain tumor MRI" datasets

### Required Format

Place a file named `MRIdata.mat` in the `data/` directory with:
- Variable name: `original_volume`
- Format: 3D array (uint8 or double)
- Dimensions: `[height, width, num_slices]`

**See `data/README.md` for detailed instructions** on converting NIfTI, DICOM, or image files to the required format.

### Quick Data Conversion Example

```matlab
% From NIfTI file
nii = load_nii('your_scan.nii');
original_volume = uint8(255 * mat2gray(nii.img));
save('data/MRIdata.mat', 'original_volume');
```

## 💡 Usage Examples

### Basic Segmentation

```matlab
% Setup
addpath(genpath('src'));
load('data/MRIdata.mat', 'original_volume');

% Segment tumor
voxelVolume = 1;  % mm³
voxelArea = 1;    % mm²

[volume, volume_mm3, volume_cm3, areas, masks, selected_mask] = ...
    calculateTumorVolume_3('sagittal', original_volume, voxelVolume, voxelArea);

fprintf('Tumor volume: %.2f cm³\n', volume_cm3);
```

### Complete Pipeline

```matlab
% Run the complete pipeline
run examples/complete_pipeline.m
```

This includes:
- Data loading
- Segmentation in both planes
- Volume prediction for missing slices
- Accuracy evaluation (if manual mask available)
- 3D visualization

### Noise Robustness Testing

```matlab
% Test with different noise types
run examples/noise_testing.m
```

## 📖 Documentation

Comprehensive documentation is available in `docs/DOCUMENTATION.md`, including:
- Detailed function reference
- Parameter configuration
- Troubleshooting guide
- Advanced usage examples

## 🔧 Main Functions

### Segmentation

- **`calculateTumorVolume_3`**: Main segmentation for clean data
- **`calculateTumorVolume_Noisy`**: Segmentation with noise filtering
- **`predictMissingTumorAreas`**: Predict tumor areas using regression

### Utilities

- **`add_noise`**: Add various noise types for robustness testing
- **`calculateDiceCoefficient`**: Evaluate segmentation accuracy

### Visualization

- **`visualizeTumorIn3DInteractive`**: 3D tumor visualization

## 📈 Workflow

1. **Load MRI data** from `data/MRIdata.mat`
2. **(Optional) Add noise** for robustness testing
3. **Segment tumor** in axial and/or sagittal planes
4. **Calculate volume** in pixels³, mm³, and cm³
5. **Predict missing areas** using polynomial regression
6. **(Optional) Evaluate accuracy** with Dice coefficient
7. **Visualize results** in 3D

## 🎓 Examples

Three example scripts are provided:

1. **`quickstart.m`**: Minimal example to get started quickly
2. **`complete_pipeline.m`**: Full pipeline with all features
3. **`noise_testing.m`**: Test robustness to different noise types

## 🔍 Troubleshooting

### Data file not found
- Ensure `MRIdata.mat` is in the `data/` directory
- Check that it contains a variable named `original_volume`
- See `data/README.md` for data preparation instructions

### Path issues
```matlab
% Add source directories to MATLAB path
addpath(genpath('src'));
```

### No tumor detected
- Adjust threshold values in segmentation functions
- Verify slice range matches your data
- Check that data contains visible lesions

For more troubleshooting tips, see `docs/DOCUMENTATION.md`.

## 📝 License

See [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This software is for research and educational purposes only. It is not intended for clinical use or medical diagnosis. Always ensure compliance with medical data regulations (HIPAA, GDPR, etc.) when working with patient data.

## 🤝 Contributing

Contributions are welcome! Please ensure:
- Code follows MATLAB best practices
- Documentation is updated
- Examples are tested
- No patient data is included

## 📧 Contact

For questions or issues, please open an issue on GitHub.

---

**Note**: This is a research project. Ensure you have appropriate authorization and ethical approval before using medical imaging data.
