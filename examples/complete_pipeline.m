% Brain Lesion Segmentation Pipeline
% Complete workflow for MRI brain tumor segmentation and analysis
%
% This script demonstrates the complete pipeline for:
% 1. Loading MRI data
% 2. Adding noise (optional, for robustness testing)
% 3. Segmenting brain lesions/tumors
% 4. Calculating tumor volumes
% 5. Predicting missing tumor areas
% 6. Evaluating segmentation accuracy (Dice coefficient)
% 7. 3D visualization

%% Pipeline Overview
% This pipeline processes 3D MRI volumes to segment and analyze brain lesions.
% The main steps are:
%
% Step 1: Data Loading
% Step 2: Noise Addition (optional)
% Step 3: Tumor Segmentation (axial and sagittal planes)
% Step 4: Volume Calculation
% Step 5: Missing Area Prediction
% Step 6: Accuracy Evaluation
% Step 7: 3D Visualization

%% Setup: Add Source Directories to Path
% Add all source folders to MATLAB path
addpath(genpath('src'));

%% Step 1: Load MRI Data
% Load the MRI volume data from the data directory
% NOTE: You must provide your own MRI data - see data/README.md for details

dataFile = 'data/MRIdata.mat';

if ~exist(dataFile, 'file')
    error(['MRI data file not found! Please place MRIdata.mat in the data/ directory.\n' ...
           'See data/README.md for instructions on obtaining and preparing MRI data.']);
end

% Load the data
load(dataFile, 'original_volume');

% Display data information
fprintf('MRI Data Loaded Successfully!\n');
fprintf('Volume dimensions: %d x %d x %d\n', size(original_volume));
fprintf('Data type: %s\n', class(original_volume));
fprintf('Value range: [%d, %d]\n', min(original_volume(:)), max(original_volume(:)));

%% Step 2: Define Voxel Parameters
% These parameters are critical for accurate volume calculations
% Adjust these values based on your MRI scan specifications

voxelDimensions = [1, 1, 1]; % mm (x, y, z) - adjust based on your data
voxelVolume = prod(voxelDimensions); % mm³
voxelArea = voxelDimensions(1) * voxelDimensions(2); % mm²

fprintf('\nVoxel Parameters:\n');
fprintf('Dimensions: %.2f x %.2f x %.2f mm\n', voxelDimensions);
fprintf('Volume: %.2f mm³\n', voxelVolume);
fprintf('Area: %.2f mm²\n', voxelArea);

%% Step 3 (Optional): Add Noise for Robustness Testing
% This step is optional - it tests the segmentation algorithm's robustness
% to different types of noise

addNoiseToData = false; % Set to true to test with noisy data

if addNoiseToData
    fprintf('\nAdding noise to MRI volume...\n');
    noisy_volumes = add_noise(original_volume, false);
    
    % Choose which noise type to use for testing
    % Options: 'gaussian', 'salt_pepper', 'speckle'
    % Noise levels: 1 (low), 2 (medium), 3 (high)
    
    testVolume = noisy_volumes.gaussian{1}; % Low Gaussian noise
    fprintf('Using Gaussian noise (low level) for testing\n');
else
    testVolume = original_volume;
    fprintf('\nUsing original (clean) data\n');
end

%% Step 4: Tumor Segmentation - Axial Plane
% Segment the tumor in axial slices (horizontal cross-sections)

fprintf('\n=== AXIAL PLANE SEGMENTATION ===\n');

[totalVolume_axial, totalVolume_mm3_axial, totalVolume_cm3_axial, ...
 tumorAreas_axial, tumorMasks_axial, selected_mask_axial] = ...
    calculateTumorVolume_3('axial', testVolume, voxelVolume, voxelArea);

fprintf('\nAxial Plane Results:\n');
fprintf('Total Volume: %d pixels³\n', totalVolume_axial);
fprintf('Total Volume: %.2f mm³\n', totalVolume_mm3_axial);
fprintf('Total Volume: %.2f cm³\n', totalVolume_cm3_axial);

%% Step 5: Tumor Segmentation - Sagittal Plane
% Segment the tumor in sagittal slices (side view)

fprintf('\n=== SAGITTAL PLANE SEGMENTATION ===\n');

[totalVolume_sagittal, totalVolume_mm3_sagittal, totalVolume_cm3_sagittal, ...
 tumorAreas_sagittal, tumorMasks_sagittal, selected_mask_sagittal] = ...
    calculateTumorVolume_3('sagittal', testVolume, voxelVolume, voxelArea);

fprintf('\nSagittal Plane Results:\n');
fprintf('Total Volume: %d pixels³\n', totalVolume_sagittal);
fprintf('Total Volume: %.2f mm³\n', totalVolume_mm3_sagittal);
fprintf('Total Volume: %.2f cm³\n', totalVolume_cm3_sagittal);

%% Step 6: Predict Missing Tumor Areas (Axial Plane)
% Use polynomial regression to estimate tumor areas in slices where
% the tumor was not detected

fprintf('\n=== PREDICTING MISSING AREAS ===\n');

[tumorAreasWithPrediction_axial, totalVolume_predicted_axial, ...
 totalVolume_predicted_mm3_axial, totalVolume_predicted_cm3_axial] = ...
    predictMissingTumorAreas(tumorAreas_axial, voxelVolume);

fprintf('\nPredicted Volume Results (Axial):\n');
fprintf('Total Volume (with prediction): %d pixels³\n', totalVolume_predicted_axial);
fprintf('Total Volume (with prediction): %.2f mm³\n', totalVolume_predicted_mm3_axial);
fprintf('Total Volume (with prediction): %.2f cm³\n', totalVolume_predicted_cm3_axial);

%% Step 7: Evaluate Segmentation Accuracy (Optional)
% Calculate Dice coefficient to compare automatic segmentation with manual
% NOTE: This requires a manual segmentation mask for comparison
% If you don't have a manual mask, skip this step

hasManualMask = false; % Set to true if you have a manual segmentation

if hasManualMask
    % Load or create your manual segmentation mask
    % manualMask = ... (load your manual segmentation here)
    
    % Example: Using the sagittal mask as "ground truth" for demonstration
    % In practice, use actual expert-annotated masks
    manualMask = selected_mask_sagittal;
    autoMask = selected_mask_axial;
    
    diceScore = calculateDiceCoefficient(manualMask, autoMask);
    fprintf('\n=== SEGMENTATION ACCURACY ===\n');
    fprintf('Dice Coefficient: %.4f\n', diceScore);
    fprintf('Interpretation: 0 = no overlap, 1 = perfect overlap\n');
else
    fprintf('\n=== SEGMENTATION ACCURACY ===\n');
    fprintf('Skipping Dice coefficient calculation (no manual mask available)\n');
    fprintf('To evaluate accuracy, provide a manual segmentation mask\n');
end

%% Step 8: 3D Visualization
% Visualize the segmented tumor in 3D space

fprintf('\n=== 3D VISUALIZATION ===\n');

% Combine masks from both planes
combinedMasks = struct();
combinedMasks.axial = tumorMasks_axial;
combinedMasks.sagittal = tumorMasks_sagittal;

visualizeTumorIn3DInteractive(combinedMasks, voxelVolume);

fprintf('\n3D visualization complete!\n');

%% Summary
fprintf('\n===========================================\n');
fprintf('          PIPELINE SUMMARY\n');
fprintf('===========================================\n');
fprintf('Data dimensions: %d x %d x %d\n', size(testVolume));
fprintf('Voxel volume: %.2f mm³\n', voxelVolume);
fprintf('\nAxial Plane:\n');
fprintf('  - Volume: %.2f cm³\n', totalVolume_cm3_axial);
fprintf('  - Volume (predicted): %.2f cm³\n', totalVolume_predicted_cm3_axial);
fprintf('\nSagittal Plane:\n');
fprintf('  - Volume: %.2f cm³\n', totalVolume_cm3_sagittal);
fprintf('===========================================\n');

%% Next Steps
% - Experiment with different noise types and levels
% - Adjust segmentation thresholds in calculateTumorVolume_3.m
% - Compare results from different planes
% - Test with different MRI datasets
% - Add more sophisticated segmentation algorithms
