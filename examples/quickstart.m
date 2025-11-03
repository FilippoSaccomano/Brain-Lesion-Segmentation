% Quick Start Example
% Minimal example to get started with brain lesion segmentation

%% Setup
% Add source directories to path
addpath(genpath('src'));

%% Load Data
% Make sure you have placed MRIdata.mat in the data/ directory
% See data/README.md for instructions on obtaining MRI data

load('data/MRIdata.mat', 'original_volume');

fprintf('Loaded MRI volume: %d x %d x %d\n', size(original_volume));

%% Set Parameters
voxelVolume = 1;  % mm³ (adjust based on your MRI scan specifications)
voxelArea = 1;    % mm² (adjust based on your MRI scan specifications)

%% Segment Tumor - Sagittal Plane
fprintf('\nSegmenting tumor in sagittal plane...\n');

[totalVolume, totalVolume_mm3, totalVolume_cm3, tumorAreas, tumorMasks, selected_mask] = ...
    calculateTumorVolume_3('sagittal', original_volume, voxelVolume, voxelArea);

%% Display Results
fprintf('\n=== RESULTS ===\n');
fprintf('Total tumor volume: %.2f cm³\n', totalVolume_cm3);
fprintf('Total tumor volume: %.2f mm³\n', totalVolume_mm3);
fprintf('Number of slices processed: %d\n', length(tumorAreas));

%% Optional: Predict Missing Areas
fprintf('\nPredicting missing tumor areas...\n');

[areasWithPrediction, volumeWithPrediction, volume_mm3_predicted, volume_cm3_predicted] = ...
    predictMissingTumorAreas(tumorAreas, voxelVolume);

fprintf('Volume with prediction: %.2f cm³\n', volume_cm3_predicted);

fprintf('\n=== DONE ===\n');
fprintf('Check the figures for visualization of each slice.\n');
