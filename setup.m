% Setup Script for Brain Lesion Segmentation Pipeline
% Run this script once to configure your environment

%% Add Source Paths
fprintf('===================================\n');
fprintf('Brain Lesion Segmentation - Setup\n');
fprintf('===================================\n\n');

% Add source directories to MATLAB path
fprintf('Adding source directories to MATLAB path...\n');
addpath(genpath('src'));
savepath; % Save the path for future MATLAB sessions
fprintf('✓ Source directories added and saved.\n\n');

%% Check for Required Toolboxes
fprintf('Checking for required toolboxes...\n');

% Check for Image Processing Toolbox
if license('test', 'Image_Toolbox')
    fprintf('✓ Image Processing Toolbox: Available\n');
else
    warning('✗ Image Processing Toolbox: NOT FOUND (required)');
end

% Check for Statistics and Machine Learning Toolbox (optional)
if license('test', 'Statistics_Toolbox')
    fprintf('✓ Statistics Toolbox: Available\n');
else
    fprintf('⚠ Statistics Toolbox: Not found (optional, some features may be limited)\n');
end

fprintf('\n');

%% Check for Data File
fprintf('Checking for MRI data...\n');

if exist('data/MRIdata.mat', 'file')
    fprintf('✓ MRIdata.mat found in data/ directory\n');
    
    % Try to load and validate
    try
        data = load('data/MRIdata.mat');
        if isfield(data, 'original_volume')
            fprintf('✓ Variable "original_volume" found\n');
            volSize = size(data.original_volume);
            fprintf('  - Dimensions: %d x %d x %d\n', volSize);
            fprintf('  - Data type: %s\n', class(data.original_volume));
            fprintf('\n✓ Data validation successful!\n');
        else
            warning('✗ Variable "original_volume" not found in MRIdata.mat');
            fprintf('  Expected variable name: original_volume\n');
        end
    catch ME
        warning('✗ Error loading MRIdata.mat: %s', ME.message);
    end
else
    fprintf('✗ MRIdata.mat NOT FOUND in data/ directory\n\n');
    fprintf('ACTION REQUIRED:\n');
    fprintf('You must provide your own MRI data to use this pipeline.\n');
    fprintf('See data/README.md for:\n');
    fprintf('  - Where to obtain public MRI datasets\n');
    fprintf('  - How to convert various formats to .mat\n');
    fprintf('  - Example conversion code\n\n');
    fprintf('Quick links to public datasets:\n');
    fprintf('  - BraTS: https://www.med.upenn.edu/cbica/brats2020/data.html\n');
    fprintf('  - TCIA: https://www.cancerimagingarchive.net/\n');
    fprintf('  - OpenNeuro: https://openneuro.org/\n');
    fprintf('  - Kaggle: https://www.kaggle.com/datasets (search "brain tumor MRI")\n');
end

fprintf('\n');

%% Display Directory Structure
fprintf('Repository structure:\n');
fprintf('  src/              - Source code (segmentation, visualization, utils)\n');
fprintf('  examples/         - Example scripts to get started\n');
fprintf('  data/             - Place your MRIdata.mat here\n');
fprintf('  docs/             - Documentation and guides\n\n');

%% Next Steps
fprintf('===================================\n');
fprintf('NEXT STEPS:\n');
fprintf('===================================\n\n');

if exist('data/MRIdata.mat', 'file')
    fprintf('✓ Setup complete! You can now run:\n');
    fprintf('  1. examples/quickstart.m - Quick start example\n');
    fprintf('  2. examples/complete_pipeline.m - Full pipeline\n');
    fprintf('  3. examples/noise_testing.m - Noise robustness test\n\n');
    fprintf('For detailed guidance:\n');
    fprintf('  - docs/pipeline_guide.m - Step-by-step walkthrough\n');
    fprintf('  - docs/DOCUMENTATION.md - Complete function reference\n');
    fprintf('  - docs/README_IT.md - Italian documentation\n');
else
    fprintf('1. Obtain MRI data (see data/README.md)\n');
    fprintf('2. Place MRIdata.mat in the data/ directory\n');
    fprintf('3. Run this setup script again to verify\n');
    fprintf('4. Start with examples/quickstart.m\n');
end

fprintf('\n===================================\n');
fprintf('Setup script completed!\n');
fprintf('===================================\n');
