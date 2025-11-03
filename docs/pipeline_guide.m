%% Brain Lesion Segmentation Pipeline - Complete Guide
% This live script provides a comprehensive walkthrough of the brain lesion
% segmentation pipeline, explaining each step in detail.
%
% *Author:* Brain Lesion Segmentation Project
% *Date:* 2024
% *Purpose:* Educational and research use

%% Introduction
% This pipeline demonstrates automated segmentation of brain lesions (tumors)
% from MRI scans. The workflow includes:
%
% # Data preparation and loading
% # Image preprocessing
% # Tumor segmentation using threshold-based methods
% # Volume calculation and analysis
% # Noise robustness testing
% # Accuracy evaluation
% # 3D visualization
%
% *Note:* This is for research/educational purposes only, not clinical use.

%% Section 1: Setup and Data Loading
% Before starting, ensure you have:
%
% * MATLAB R2019b or later
% * Image Processing Toolbox
% * MRI data in the correct format (see data/README.md)

%%% 1.1: Add Source Directories to Path
% The pipeline code is organized in the src/ folder. Add it to MATLAB's path:

addpath(genpath('src'));
fprintf('Source directories added to path.\n');

%%% 1.2: Load MRI Data
% The pipeline expects a 3D MRI volume in a .mat file.
% 
% *IMPORTANT:* You must provide your own MRI data. See data/README.md for:
%
% * Where to obtain public MRI datasets (BraTS, TCIA, OpenNeuro, Kaggle)
% * How to convert NIfTI, DICOM, or image files to .mat format
% * Example code for data conversion

dataFile = 'data/MRIdata.mat';

% Check if data file exists
if ~exist(dataFile, 'file')
    error(['ERROR: MRI data file not found!\n\n' ...
           'Please place MRIdata.mat in the data/ directory.\n' ...
           'See data/README.md for detailed instructions on:\n' ...
           '  - Obtaining public MRI datasets\n' ...
           '  - Converting various formats to .mat\n' ...
           '  - Creating test data\n']);
end

% Load the MRI volume
load(dataFile, 'original_volume');

% Display information about the loaded data
fprintf('\n=== MRI Data Information ===\n');
fprintf('Volume dimensions: %d x %d x %d\n', size(original_volume));
fprintf('Data type: %s\n', class(original_volume));
fprintf('Value range: [%d, %d]\n', min(original_volume(:)), max(original_volume(:)));
fprintf('Total voxels: %d\n', numel(original_volume));

%%% 1.3: Visualize Sample Slices
% Let's visualize a few slices to understand our data

figure('Name', 'Sample MRI Slices', 'Position', [100, 100, 1200, 400]);

% Show three different slices
sliceIndices = round(linspace(1, size(original_volume, 3), 5));
for i = 1:min(3, length(sliceIndices))
    subplot(1, 3, i);
    imshow(original_volume(:, :, sliceIndices(i)), []);
    title(sprintf('Slice %d', sliceIndices(i)));
    colorbar;
end

%% Section 2: Voxel Parameters and Physical Measurements
% For accurate volume calculations, we need to know the physical size of voxels.
%
% *Voxel Information:* Typically found in DICOM headers or NIfTI metadata
%
% Common values:
%
% * 1mm x 1mm x 1mm (typical for many brain MRIs)
% * 0.5mm x 0.5mm x 0.5mm (high-resolution scans)
%
% *IMPORTANT:* Adjust these values based on your specific MRI scan!

%%% 2.1: Set Voxel Dimensions
voxelDimensions = [1, 1, 1]; % mm (x, y, z) - ADJUST BASED ON YOUR DATA
voxelVolume = prod(voxelDimensions); % mm³
voxelArea = voxelDimensions(1) * voxelDimensions(2); % mm²

fprintf('\n=== Voxel Parameters ===\n');
fprintf('Dimensions: %.2f x %.2f x %.2f mm\n', voxelDimensions);
fprintf('Volume per voxel: %.2f mm³\n', voxelVolume);
fprintf('Area per voxel face: %.2f mm²\n', voxelArea);

%% Section 3: Image Preprocessing and Noise Addition (Optional)
% Real-world MRI scans often contain noise. This section demonstrates how to
% test the robustness of segmentation algorithms to different noise types.

%%% 3.1: Decide Whether to Add Noise
% Set this to true to test with noisy data, false for clean data

testWithNoise = false; % Change to true to test noise robustness

if testWithNoise
    fprintf('\n=== Adding Noise for Robustness Testing ===\n');
    
    % Generate noisy versions of the volume
    noisy_volumes = add_noise(original_volume, false);
    
    % Choose which noise type and level to use
    % Noise types: 'gaussian', 'salt_pepper', 'speckle'
    % Noise levels: 1 (low), 2 (medium), 3 (high)
    
    selectedNoiseType = 'gaussian';
    selectedNoiseLevel = 1; % Low noise
    
    testVolume = noisy_volumes.(selectedNoiseType){selectedNoiseLevel};
    
    fprintf('Using %s noise at level %d\n', selectedNoiseType, selectedNoiseLevel);
    
    % Visualize the effect of noise
    figure('Name', 'Noise Comparison', 'Position', [100, 100, 800, 400]);
    sliceNum = round(size(original_volume, 3) / 2);
    
    subplot(1, 2, 1);
    imshow(original_volume(:, :, sliceNum), []);
    title('Original (Clean) Slice');
    
    subplot(1, 2, 2);
    imshow(testVolume(:, :, sliceNum), []);
    title(sprintf('%s Noise (Level %d)', selectedNoiseType, selectedNoiseLevel));
else
    testVolume = original_volume;
    fprintf('\n=== Using Original (Clean) Data ===\n');
end

%% Section 4: Tumor Segmentation - Axial Plane
% The segmentation is performed on axial slices (horizontal cross-sections).
%
% *Segmentation Method:*
%
% # Intensity normalization
% # Threshold-based mask creation
% # Region of Interest (ROI) filtering
% # Morphological operations (opening, closing)
% # Connected component analysis
%
% *Parameters:* Thresholds and ROI bounds are tuned for typical brain MRI

fprintf('\n=== AXIAL PLANE SEGMENTATION ===\n');

[totalVolume_axial, totalVolume_mm3_axial, totalVolume_cm3_axial, ...
 tumorAreas_axial, tumorMasks_axial, selected_mask_axial] = ...
    calculateTumorVolume_3('axial', testVolume, voxelVolume, voxelArea);

fprintf('\nAxial Plane Results:\n');
fprintf('  Total Volume: %d pixels³\n', totalVolume_axial);
fprintf('  Total Volume: %.2f mm³\n', totalVolume_mm3_axial);
fprintf('  Total Volume: %.2f cm³\n', totalVolume_cm3_axial);
fprintf('  Slices processed: %d\n', length(tumorAreas_axial));
fprintf('  Slices with tumor: %d\n', sum(tumorAreas_axial > 0));

%%% 4.1: Analyze Tumor Area Distribution (Axial)
figure('Name', 'Axial Tumor Areas', 'Position', [100, 100, 800, 400]);
plot(tumorAreas_axial, 'b-o', 'LineWidth', 2);
xlabel('Slice Number');
ylabel('Tumor Area (pixels)');
title('Tumor Area per Slice - Axial Plane');
grid on;

%% Section 5: Tumor Segmentation - Sagittal Plane
% The segmentation is also performed on sagittal slices (side view).
%
% Segmenting in multiple planes provides:
%
% * Cross-validation of results
% * Better 3D tumor reconstruction
% * Detection of lesions that may be missed in one plane

fprintf('\n=== SAGITTAL PLANE SEGMENTATION ===\n');

[totalVolume_sagittal, totalVolume_mm3_sagittal, totalVolume_cm3_sagittal, ...
 tumorAreas_sagittal, tumorMasks_sagittal, selected_mask_sagittal] = ...
    calculateTumorVolume_3('sagittal', testVolume, voxelVolume, voxelArea);

fprintf('\nSagittal Plane Results:\n');
fprintf('  Total Volume: %d pixels³\n', totalVolume_sagittal);
fprintf('  Total Volume: %.2f mm³\n', totalVolume_mm3_sagittal);
fprintf('  Total Volume: %.2f cm³\n', totalVolume_cm3_sagittal);
fprintf('  Slices processed: %d\n', length(tumorAreas_sagittal));
fprintf('  Slices with tumor: %d\n', sum(tumorAreas_sagittal > 0));

%%% 5.1: Analyze Tumor Area Distribution (Sagittal)
figure('Name', 'Sagittal Tumor Areas', 'Position', [100, 100, 800, 400]);
plot(tumorAreas_sagittal, 'r-o', 'LineWidth', 2);
xlabel('Slice Number');
ylabel('Tumor Area (pixels)');
title('Tumor Area per Slice - Sagittal Plane');
grid on;

%%% 5.2: Compare Both Planes
figure('Name', 'Plane Comparison', 'Position', [100, 100, 800, 400]);
bar([totalVolume_cm3_axial, totalVolume_cm3_sagittal]);
set(gca, 'XTickLabel', {'Axial', 'Sagittal'});
ylabel('Tumor Volume (cm³)');
title('Tumor Volume Comparison: Axial vs Sagittal');
grid on;

%% Section 6: Predicting Missing Tumor Areas
% Sometimes the tumor is not detected in certain slices due to:
%
% * Partial volume effects
% * Low contrast
% * Image artifacts
%
% We use polynomial regression to estimate tumor areas in these slices.

fprintf('\n=== PREDICTING MISSING AREAS (Axial Plane) ===\n');

[tumorAreasWithPrediction_axial, totalVolume_predicted_axial, ...
 totalVolume_predicted_mm3_axial, totalVolume_predicted_cm3_axial] = ...
    predictMissingTumorAreas(tumorAreas_axial, voxelVolume);

fprintf('\nPrediction Results:\n');
fprintf('  Original volume: %.2f cm³\n', totalVolume_cm3_axial);
fprintf('  Predicted volume: %.2f cm³\n', totalVolume_predicted_cm3_axial);
fprintf('  Difference: %.2f cm³ (%.1f%%)\n', ...
        totalVolume_predicted_cm3_axial - totalVolume_cm3_axial, ...
        100 * (totalVolume_predicted_cm3_axial - totalVolume_cm3_axial) / totalVolume_cm3_axial);

%% Section 7: Segmentation Accuracy Evaluation
% The Dice coefficient measures overlap between two segmentations.
%
% *Dice Coefficient:* 
%
% * Range: 0 to 1
% * 0 = no overlap
% * 1 = perfect overlap
% * Values > 0.7 are generally considered good for medical image segmentation
%
% *Note:* Requires a ground truth (manual) segmentation for comparison

hasGroundTruth = false; % Set to true if you have manual segmentation

if hasGroundTruth
    % If you have a manual segmentation, load it here
    % Example:
    % load('manual_segmentation.mat', 'manualMask');
    
    % For demonstration, we'll compare axial vs sagittal masks
    % (not a true accuracy measure, just for demonstration)
    manualMask = selected_mask_sagittal;
    autoMask = selected_mask_axial;
    
    diceScore = calculateDiceCoefficient(manualMask, autoMask);
    
    fprintf('\n=== SEGMENTATION ACCURACY ===\n');
    fprintf('Dice Coefficient: %.4f\n', diceScore);
    
    if diceScore > 0.7
        fprintf('Interpretation: Good overlap\n');
    elseif diceScore > 0.5
        fprintf('Interpretation: Moderate overlap\n');
    else
        fprintf('Interpretation: Poor overlap\n');
    end
else
    fprintf('\n=== SEGMENTATION ACCURACY ===\n');
    fprintf('Skipping Dice coefficient calculation.\n');
    fprintf('To evaluate accuracy, provide a manual (ground truth) segmentation.\n');
    fprintf('See docs/DOCUMENTATION.md for details.\n');
end

%% Section 8: 3D Visualization
% Visualize the segmented tumor in 3D space using isosurface rendering.
%
% The visualization shows:
%
% * Cyan surface: Axial plane segmentation
% * Magenta surface: Sagittal plane segmentation
% * Interactive rotation and zoom

fprintf('\n=== CREATING 3D VISUALIZATION ===\n');

% Combine masks from both planes
combinedMasks = struct();
combinedMasks.axial = tumorMasks_axial;
combinedMasks.sagittal = tumorMasks_sagittal;

% Create 3D visualization
visualizeTumorIn3DInteractive(combinedMasks, voxelVolume);

fprintf('3D visualization created!\n');
fprintf('Rotate the 3D plot to view from different angles.\n');

%% Section 9: Summary and Results
% Let's summarize all the results from the pipeline.

fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║           BRAIN LESION SEGMENTATION SUMMARY           ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n');
fprintf('\n');
fprintf('DATA INFORMATION:\n');
fprintf('  Volume dimensions: %d x %d x %d\n', size(testVolume));
fprintf('  Voxel size: %.2f mm³\n', voxelVolume);
fprintf('  Data type: %s\n', class(testVolume));
fprintf('\n');
fprintf('SEGMENTATION RESULTS:\n');
fprintf('  Axial Plane:\n');
fprintf('    - Volume: %.2f cm³ (%.2f mm³)\n', totalVolume_cm3_axial, totalVolume_mm3_axial);
fprintf('    - With prediction: %.2f cm³\n', totalVolume_predicted_cm3_axial);
fprintf('    - Slices with tumor: %d / %d\n', sum(tumorAreas_axial > 0), length(tumorAreas_axial));
fprintf('\n');
fprintf('  Sagittal Plane:\n');
fprintf('    - Volume: %.2f cm³ (%.2f mm³)\n', totalVolume_cm3_sagittal, totalVolume_mm3_sagittal);
fprintf('    - Slices with tumor: %d / %d\n', sum(tumorAreas_sagittal > 0), length(tumorAreas_sagittal));
fprintf('\n');
fprintf('ANALYSIS NOTES:\n');
fprintf('  - Different planes may yield different volumes due to:\n');
fprintf('    * Segmentation algorithm variations\n');
fprintf('    * Anisotropic voxel spacing\n');
fprintf('    * Tumor orientation\n');
fprintf('  - Average of both planes: %.2f cm³\n', ...
        (totalVolume_cm3_axial + totalVolume_cm3_sagittal) / 2);
fprintf('\n');
fprintf('═══════════════════════════════════════════════════════\n');

%% Section 10: Next Steps and Recommendations
% 
% *For Further Analysis:*
%
% # *Test with different datasets:* Try various MRI scans to validate robustness
% # *Parameter tuning:* Adjust thresholds in segmentation functions for your data
% # *Noise testing:* Use examples/noise_testing.m to test robustness
% # *Validation:* Compare with manual segmentations using Dice coefficient
% # *Advanced methods:* Consider implementing machine learning approaches
%
% *Useful Scripts:*
%
% * examples/quickstart.m - Quick start guide
% * examples/complete_pipeline.m - Full pipeline
% * examples/noise_testing.m - Noise robustness testing
%
% *Documentation:*
%
% * docs/DOCUMENTATION.md - Complete function reference
% * data/README.md - Data preparation guide
%
% *Important Reminders:*
%
% * This is for research/educational purposes only
% * Not for clinical diagnosis
% * Ensure compliance with medical data regulations
% * Always validate results with expert annotation

fprintf('\n=== PIPELINE COMPLETE ===\n');
fprintf('Check the generated figures for detailed visualizations.\n');
fprintf('See docs/DOCUMENTATION.md for more information.\n');

%% Appendix: Troubleshooting
%
% *Common Issues and Solutions:*
%
% *Issue:* Data file not found
%
% * Solution: Ensure MRIdata.mat is in data/ directory
% * See data/README.md for data preparation
%
% *Issue:* No tumor detected
%
% * Solution: Adjust thresholds in calculateTumorVolume_3.m
% * Check slice range matches your data
%
% *Issue:* Memory error
%
% * Solution: Close unnecessary figures
% * Process fewer slices
% * Use smaller data
%
% *Issue:* Path not found
%
% * Solution: Run: addpath(genpath('src'));
%
% For more help, see docs/DOCUMENTATION.md
