function visualizeTumorIn3DInteractive(tumorMasks, voxelVolume)
    % Ensure the tumorMasks.axial and tumorMasks.sagittal are logical 3D matrices
    % Initialize the 3D arrays for axial and sagittal volumes
    axialSize = size(tumorMasks.axial.axial{1});  % Get the size of the first slice (axial)
    sagittalSize = size(tumorMasks.sagittal.sagittal{1});  % Get the size of the first slice (sagittal)
    
    % Initialize the 3D arrays for axial and sagittal volumes
    tumor3D_axial = false([axialSize(1), axialSize(2), length(tumorMasks.axial.axial)]);
    tumor3D_sagittal = false([sagittalSize(1), sagittalSize(2), length(tumorMasks.sagittal.sagittal)]);
    
    % Fill 3D tumor mask for axial slices
    for i = 1:length(tumorMasks.axial.axial)
        if ~isempty(tumorMasks.axial.axial{i})  % Check if the slice exists
            tumor3D_axial(:,:,i) = tumorMasks.axial.axial{i};  % Access and assign each slice
        end
    end
    
    % Fill 3D tumor mask for sagittal slices
    for i = 1:length(tumorMasks.sagittal.sagittal)
        if ~isempty(tumorMasks.sagittal.sagittal{i})  % Check if the slice exists
            tumor3D_sagittal(:,:,i) = tumorMasks.sagittal.sagittal{i};  % Access and assign each slice
        end
    end
    
    % Reorient the sagittal mask to match the axial mask orientation
    tumor3D_sagittal_reoriented = permute(tumor3D_sagittal, [3, 2, 1]); % Align axes
    
    % Visualize both axial and sagittal tumor masks in 3D
    figure;
    hold on;
    
    % Visualize the axial tumor mask
    p_axial = patch(isosurface(tumor3D_axial, 0.5));
    isonormals(tumor3D_axial, p_axial);
    p_axial.FaceColor = 'cyan';  % Axial mask color
    p_axial.EdgeColor = 'none';  % No edges
    p_axial.FaceAlpha = 1;  % Reduced transparency for axial mask


    % Visualize the reoriented sagittal tumor mask
    p_sagittal = patch(isosurface(tumor3D_sagittal_reoriented, 0.5));
    isonormals(tumor3D_sagittal_reoriented, p_sagittal);
    p_sagittal.FaceColor = 'magenta';  % Sagittal mask color
    p_sagittal.EdgeColor = 'none';  % No edges
    p_sagittal.FaceAlpha = 1;  % Reduced transparency for sagittal mask
    
    % Add lights and settings
    camlight('headlight');
    lighting gouraud;
    axis tight;
    daspect([1 1 1]);
    grid on;
    view(3);
    title('3D Visualization of Axial and Sagittal Tumor Masks (Aligned)');
    xlabel('X-axis');
    ylabel('Y-axis');
    zlabel('Z-axis');
    
    % Calculate tumor volume in mm^3 and cm^3 for each plane
    totalTumorVolume3D_axial = sum(tumor3D_axial(:));  % Total tumor voxels (axial)
    totalTumorVolume3D_sagittal = sum(tumor3D_sagittal(:));  % Total tumor voxels (sagittal)
    
    totalTumorVolume_mm3_axial = totalTumorVolume3D_axial * voxelVolume;  % Volume in mm³ (axial)
    totalTumorVolume_mm3_sagittal = totalTumorVolume3D_sagittal * voxelVolume;  % Volume in mm³ (sagittal)
    
    totalTumorVolume_cm3_axial = totalTumorVolume_mm3_axial / 1000;  % Volume in cm³ (axial)
    totalTumorVolume_cm3_sagittal = totalTumorVolume_mm3_sagittal / 1000;  % Volume in cm³ (sagittal)

    % Display results
    disp(['Total Tumor Volume in Axial Plane (mm^3): ', num2str(totalTumorVolume_mm3_axial)]);
    disp(['Total Tumor Volume in Sagittal Plane (mm^3): ', num2str(totalTumorVolume_mm3_sagittal)]);
    disp(['Total Tumor Volume in Axial Plane (cm^3): ', num2str(totalTumorVolume_cm3_axial)]);
    disp(['Total Tumor Volume in Sagittal Plane (cm^3): ', num2str(totalTumorVolume_cm3_sagittal)]);
end
