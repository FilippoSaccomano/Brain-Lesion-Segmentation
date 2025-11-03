% Noise Robustness Testing Example
% This script demonstrates how to test the segmentation pipeline's
% robustness to different types of noise

%% Setup
addpath(genpath('src'));

%% Load MRI Data
dataFile = 'data/MRIdata.mat';

if ~exist(dataFile, 'file')
    error(['MRI data file not found! Please place MRIdata.mat in the data/ directory.\n' ...
           'See data/README.md for instructions.']);
end

load(dataFile, 'original_volume');

%% Define Parameters
voxelVolume = 1; % mm³ - adjust based on your data
plane = 'sagittal'; % or 'axial'

%% Add Different Types of Noise
fprintf('Adding noise to MRI volume...\n');
noisy_volumes = add_noise(original_volume, false);

%% Test with Different Noise Types
noiseTypes = {'gaussian', 'salt_pepper', 'speckle'};
noiseLevels = [0.01, 0.1, 0.3]; % Low, medium, high

fprintf('\n=== TESTING NOISE ROBUSTNESS ===\n\n');

% Store results
results = struct();

for i = 1:length(noiseTypes)
    noiseType = noiseTypes{i};
    fprintf('Testing %s noise:\n', noiseType);
    
    for level = 1:3
        fprintf('  Level %d (%.2f):\n', level, noiseLevels(level));
        
        % Get noisy volume
        noisyVolume = noisy_volumes.(noiseType){level};
        
        % Segment with noise filtering
        [totalVol, totalVol_mm3, totalVol_cm3, tumorAreas, tumorMasks] = ...
            calculateTumorVolume_Noisy(plane, noisyVolume, voxelVolume, noiseType);
        
        % Store results
        results.(noiseType){level}.volume_cm3 = totalVol_cm3;
        results.(noiseType){level}.areas = tumorAreas;
        
        fprintf('    Volume: %.2f cm³\n', totalVol_cm3);
    end
    fprintf('\n');
end

%% Segment Clean Data for Comparison
fprintf('Segmenting clean (original) data for comparison...\n');
[totalVol_clean, totalVol_mm3_clean, totalVol_cm3_clean, ~, ~, ~] = ...
    calculateTumorVolume_3(plane, original_volume, voxelVolume, 1);

fprintf('Clean data volume: %.2f cm³\n\n', totalVol_cm3_clean);

%% Compare Results
fprintf('=== COMPARISON WITH CLEAN DATA ===\n\n');

for i = 1:length(noiseTypes)
    noiseType = noiseTypes{i};
    fprintf('%s noise:\n', upper(noiseType));
    
    for level = 1:3
        vol = results.(noiseType){level}.volume_cm3;
        diff = abs(vol - totalVol_cm3_clean);
        diffPercent = (diff / totalVol_cm3_clean) * 100;
        
        fprintf('  Level %d: %.2f cm³ (difference: %.2f%% )\n', ...
                level, vol, diffPercent);
    end
    fprintf('\n');
end

%% Visualization: Volume vs Noise Level
figure;
hold on;

for i = 1:length(noiseTypes)
    noiseType = noiseTypes{i};
    volumes = zeros(1, 3);
    
    for level = 1:3
        volumes(level) = results.(noiseType){level}.volume_cm3;
    end
    
    plot(1:3, volumes, '-o', 'LineWidth', 2, 'DisplayName', noiseType);
end

% Add clean data reference line
yline(totalVol_cm3_clean, '--k', 'LineWidth', 2, 'DisplayName', 'Clean data');

xlabel('Noise Level (1=low, 2=medium, 3=high)');
ylabel('Tumor Volume (cm³)');
title('Segmentation Robustness to Noise');
legend('Location', 'best');
grid on;

fprintf('\n=== NOISE TESTING COMPLETE ===\n');
