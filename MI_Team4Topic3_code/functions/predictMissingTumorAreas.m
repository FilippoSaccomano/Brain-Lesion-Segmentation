function [tumorAreasWithPrediction, totalTumorVolume, totalTumorVolume_mm3, totalTumorVolume_cm3] = predictMissingTumorAreas(tumorAreas_axial, voxelVolume)
    % INPUT:
    % tumorAreas_axial  - Vector of tumor areas for the axial slices
    % voxelVolume       - Volume of one voxel (in mm^3)
    
    % OUTPUT:
    % tumorAreasWithPrediction - Tumor areas with predicted values for missing slices
    % totalTumorVolume         - Total volume in pixel cubed
    % totalTumorVolume_mm3     - Total volume in mm^3
    % totalTumorVolume_cm3     - Total volume in cm^3

    % Identify known and missing slices
    allSlices = 1:length(tumorAreas_axial);
    knownSlices = find(tumorAreas_axial > 0);
    knownAreas = tumorAreas_axial(knownSlices);

    % Perform cubic regression for the known values
    p = polyfit(knownSlices, knownAreas, 2);
    predictedAreas = polyval(p, allSlices);

    % Replace negative predictions with 1 (or any desired value)
    predictedAreas(predictedAreas < 0) = 1; 
    
    % Create final tumor areas with predictions for missing values
    tumorAreasWithPrediction = tumorAreas_axial;
    tumorAreasWithPrediction(tumorAreas_axial == 0) = predictedAreas(tumorAreas_axial == 0);

    % Plot original and predicted tumor areas
    figure;
    plot(allSlices, tumorAreas_axial, 'bo', 'DisplayName', 'Original Data');
    hold on;
    plot(allSlices, tumorAreasWithPrediction, 'r-', 'DisplayName', 'Predicted Data');
    legend;
    xlabel('Slice Number');
    ylabel('Tumor Area (pixels)');
    title('Tumor Area Estimation with Squared Regression');

    % Calculate total tumor volume
    totalTumorVolume = sum(tumorAreasWithPrediction);  % Add area to total volume

    % Calculate total volume in mm³ and cm³
    totalTumorVolume_mm3 = totalTumorVolume * voxelVolume;
    totalTumorVolume_cm3 = totalTumorVolume_mm3 / 1000;

    % Display results
    disp(['Total Tumor Volume (pixels^3): ', num2str(totalTumorVolume)]);
    disp(['Total Tumor Volume (mm^3): ', num2str(totalTumorVolume_mm3)]);
    disp(['Total Tumor Volume (cm^3): ', num2str(totalTumorVolume_cm3)]);
end
