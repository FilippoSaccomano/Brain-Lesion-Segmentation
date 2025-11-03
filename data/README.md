# Data Directory

This directory should contain the MRI data files required for the brain lesion segmentation pipeline.

## ⚠️ Important Note
This repository does NOT include MRI data files due to licensing restrictions. You must obtain your own MRI data from public datasets or create compatible data files.

## Where to Find Compatible MRI Data

### Public MRI Brain Tumor Datasets

1. **BraTS (Brain Tumor Segmentation Challenge)**
   - Website: https://www.med.upenn.edu/cbica/brats2020/data.html
   - Format: NIfTI (.nii, .nii.gz)
   - Content: Multi-modal MRI scans with brain tumors
   - License: Free for research purposes (registration required)

2. **The Cancer Imaging Archive (TCIA)**
   - Website: https://www.cancerimagingarchive.net/
   - Collections with brain tumors:
     - "TCGA-GBM" (Glioblastoma Multiforme)
     - "TCGA-LGG" (Lower Grade Glioma)
   - Format: DICOM or NIfTI
   - License: Public domain or specific licenses per collection

3. **OpenfMRI / OpenNeuro**
   - Website: https://openneuro.org/
   - Format: NIfTI (.nii, .nii.gz)
   - Content: Various neuroimaging datasets
   - License: Varies by dataset (check individual licenses)

4. **Kaggle Brain MRI Datasets**
   - Website: https://www.kaggle.com/datasets
   - Search: "brain tumor MRI" or "brain lesion"
   - Format: Various (PNG, DICOM, NIfTI)
   - License: Varies by dataset

## Required Data Format

### MRIdata.mat
The pipeline expects a MATLAB .mat file named `MRIdata.mat` containing:

- **Variable name**: `original_volume`
- **Format**: 3D matrix (MATLAB array)
- **Type**: Grayscale MRI scan data
- **Expected dimensions**: Approximately 256x256xN slices (where N is number of slices)
- **Data type**: `uint8` (0-255) or `double` (normalized)
- **Orientation**: Axial slices stacked along the third dimension

### How to Create MRIdata.mat from Common Formats

#### From NIfTI files (.nii, .nii.gz):
```matlab
% Install NIfTI toolbox: https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image
% Or use: https://github.com/NIFTI-Imaging/nifti_matlab

% Load NIfTI file
nii = load_nii('your_mri_scan.nii');
original_volume = nii.img;

% Convert to uint8 if needed
if ~isa(original_volume, 'uint8')
    original_volume = uint8(255 * mat2gray(original_volume));
end

% Save as .mat file
save('MRIdata.mat', 'original_volume');
```

#### From DICOM files:
```matlab
% If you have multiple DICOM slices in a folder
dicomDir = 'path/to/dicom/folder';
dicomFiles = dir(fullfile(dicomDir, '*.dcm'));

% Read all slices
for i = 1:length(dicomFiles)
    filename = fullfile(dicomDir, dicomFiles(i).name);
    slice = dicomread(filename);
    if i == 1
        [rows, cols] = size(slice);
        original_volume = zeros(rows, cols, length(dicomFiles), 'like', slice);
    end
    original_volume(:, :, i) = slice;
end

% Convert to uint8 if needed
if ~isa(original_volume, 'uint8')
    original_volume = uint8(255 * mat2gray(original_volume));
end

% Save as .mat file
save('MRIdata.mat', 'original_volume');
```

#### From PNG/JPEG image slices:
```matlab
% If you have sequential image slices
imageDir = 'path/to/image/slices';
imageFiles = dir(fullfile(imageDir, '*.png')); % or '*.jpg'

% Read all slices
for i = 1:length(imageFiles)
    filename = fullfile(imageDir, imageFiles(i).name);
    slice = imread(filename);
    
    % Convert to grayscale if needed
    if size(slice, 3) == 3
        slice = rgb2gray(slice);
    end
    
    if i == 1
        [rows, cols] = size(slice);
        original_volume = zeros(rows, cols, length(imageFiles), 'uint8');
    end
    original_volume(:, :, i) = slice;
end

% Save as .mat file
save('MRIdata.mat', 'original_volume');
```

## Voxel Information

When working with the data, you'll need to specify physical dimensions:
- **Voxel dimensions**: Physical size of each voxel in mm (e.g., 1mm x 1mm x 1mm)
  - This information is usually in the DICOM header or NIfTI header
  - Common values: 1mm³, 0.5mm³, etc.
- **Voxel volume**: Product of voxel dimensions (mm³)
- **Voxel area**: Area of a single voxel face (mm²)

These parameters are used for accurate volume and area calculations in the segmentation pipeline.

## Data Placement

Place your MRI data file in this directory:
```
data/
  ├── MRIdata.mat          (Your MRI volume data - YOU MUST CREATE THIS)
  └── README.md            (This file)
```

## Example: Creating Test Data

If you just want to test the pipeline without real MRI data:
```matlab
% Create synthetic test data (not medically meaningful)
[X, Y, Z] = meshgrid(1:256, 1:256, 1:100);
original_volume = uint8(127 + 50 * sin(X/20) .* cos(Y/20) .* sin(Z/10));

% Add a spherical "lesion" for testing
center = [128, 128, 50];
radius = 20;
distances = sqrt((X - center(1)).^2 + (Y - center(2)).^2 + (Z - center(3)).^2);
original_volume(distances < radius) = 50; % Dark region simulating lesion

% Save
save('MRIdata.mat', 'original_volume');
```

## Ethical and Legal Considerations

- Ensure you have proper authorization to use any medical imaging data
- Follow HIPAA, GDPR, or other relevant privacy regulations
- Medical data must be anonymized before use
- Check the specific license of any public dataset you download
- This code is for research and educational purposes only
