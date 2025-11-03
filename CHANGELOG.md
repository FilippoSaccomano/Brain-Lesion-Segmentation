# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2024-11-03

### 🎉 Major Reorganization

This release represents a complete restructuring of the Brain Lesion Segmentation project to make it more accessible, well-documented, and ready for immediate use.

### ✨ Added

#### Directory Structure
- **src/** folder for all source code
  - **src/segmentation/** - Segmentation algorithms
  - **src/visualization/** - 3D visualization functions
  - **src/utils/** - Utility functions
- **examples/** folder with practical examples
  - `quickstart.m` - Quick start guide
  - `complete_pipeline.m` - Full pipeline demonstration
  - `noise_testing.m` - Noise robustness testing
- **data/** folder for user-provided MRI data
- **docs/** folder for comprehensive documentation
  - `DOCUMENTATION.md` - Complete function reference
  - `README_IT.md` - Italian documentation
  - `pipeline_guide.m` - Step-by-step walkthrough

#### Documentation
- Comprehensive `README.md` with:
  - Feature overview
  - Quick start guide
  - Data requirements
  - Usage examples
  - Troubleshooting section
- Detailed `data/README.md` explaining:
  - Where to obtain public MRI datasets (BraTS, TCIA, OpenNeuro, Kaggle)
  - How to convert NIfTI, DICOM, and image files to required format
  - Example conversion code
  - Synthetic test data generation
- Complete function reference in `docs/DOCUMENTATION.md`
- Italian documentation in `docs/README_IT.md`
- Interactive `docs/pipeline_guide.m` with detailed explanations

#### Configuration
- `.gitignore` file to exclude:
  - `.mat` data files
  - MATLAB autosave files
  - Temporary files
  - OS-specific files
- `setup.m` script for easy environment configuration

### 🔄 Changed

#### File Organization
- Moved all `.m` functions to appropriate subdirectories:
  - Segmentation functions → `src/segmentation/`
  - Visualization functions → `src/visualization/`
  - Utility functions → `src/utils/`
- Renamed and organized:
  - Original project notebook → `docs/original_project_notebook.mlx`

#### Documentation
- Completely rewritten `README.md` with professional structure
- Added clear instructions for data acquisition and preparation
- Added troubleshooting guides
- Added Italian language support

### 🗑️ Removed

#### Data Files
- **Removed `MRIdata.mat`** - Not included due to licensing restrictions
  - Users must now provide their own MRI data
  - Detailed instructions provided in `data/README.md`
  - Links to public datasets included

#### Reference Files
- **Removed `topic3.pdf`** - Context-only file not needed in repository

### 📋 Migration Guide

If you have an existing clone of this repository:

1. **Data Files**: 
   - Your `MRIdata.mat` is not tracked anymore
   - Keep it in the `data/` directory
   - See `data/README.md` if you need to recreate it

2. **Function Paths**:
   - Add source directories to path: `addpath(genpath('src'));`
   - Or run `setup.m` to configure automatically

3. **Examples**:
   - Old scripts may need path updates
   - Use provided examples in `examples/` as reference

### 🎯 Features

The reorganized pipeline includes:

1. **Multi-plane Segmentation**
   - Axial plane analysis
   - Sagittal plane analysis
   - Combined 3D reconstruction

2. **Noise Robustness**
   - Gaussian noise testing
   - Salt & pepper noise testing
   - Speckle noise testing
   - Multiple noise levels (low, medium, high)

3. **Volume Calculation**
   - Pixel-based counting
   - mm³ conversion
   - cm³ conversion
   - Physical dimension support

4. **Missing Area Prediction**
   - Polynomial regression
   - Automatic gap filling
   - Volume estimation improvement

5. **Accuracy Evaluation**
   - Dice coefficient calculation
   - Manual vs automatic comparison
   - Cross-plane validation

6. **3D Visualization**
   - Interactive isosurface rendering
   - Multi-plane overlay
   - Volume metrics display

### 🛠️ Technical Details

#### Functions

**Segmentation:**
- `calculateTumorVolume_3(plane, volumeData, voxelVolume, voxelArea)`
- `calculateTumorVolume_Noisy(plane, volumeData, voxelVolume, noiseType)`
- `predictMissingTumorAreas(tumorAreas_axial, voxelVolume)`

**Utilities:**
- `add_noise(original_volume, save_data)`
- `calculateDiceCoefficient(manualMask, autoMask)`

**Visualization:**
- `visualizeTumorIn3DInteractive(tumorMasks, voxelVolume)`

### 📚 Documentation Updates

- Added complete function signatures and parameter descriptions
- Added usage examples for each function
- Added troubleshooting for common issues
- Added links to public datasets
- Added data conversion examples
- Added Italian translations for Italian-speaking users

### ⚠️ Breaking Changes

1. **Path Structure**: Functions are now in subdirectories
   - Solution: Use `addpath(genpath('src'))` or run `setup.m`

2. **Data Files**: `MRIdata.mat` is no longer included
   - Solution: Provide your own data (see `data/README.md`)

3. **File Locations**: Original `.m` files moved
   - Solution: Use new organized structure or update old scripts

### 🔒 Privacy & Licensing

- No patient data included in repository
- No licensed data files included
- Users must obtain their own MRI data
- Links to public datasets provided
- Compliance with medical data regulations emphasized

### 📖 Learning Resources

New examples help users:
- Get started quickly (`quickstart.m`)
- Understand the complete workflow (`complete_pipeline.m`)
- Test robustness (`noise_testing.m`)
- Learn step-by-step (`docs/pipeline_guide.m`)

---

## [1.0.0] - Previous

### Initial Version
- Basic segmentation functions
- Included sample data
- Single notebook file
- Minimal documentation

---

**Note**: This changelog follows [Keep a Changelog](https://keepachangelog.com/) format.
