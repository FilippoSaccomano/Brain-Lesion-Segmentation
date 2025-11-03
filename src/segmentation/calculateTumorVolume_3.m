function [totalTumorVolume, totalTumorVolume_mm3, totalTumorVolume_cm3, tumorAreas, tumorMasks, selected_mask] = calculateTumorVolume_3(plane, volumeData, voxelVolume, voxelArea)
    % INPUT:
    % plane        - A string specifying the plane for visualization: 'sagittal' or 'axial'
    % volumeData   - Structure containing the volume data (e.g., noisy_volumes.salt_pepper)
    % voxelVolume  - Volume of one voxel (in mm^3)
    
    % OUTPUT:
    % totalTumorVolume      - Total volume in pixel cubed
    % totalTumorVolume_mm3  - Total volume in mm^3
    % totalTumorVolume_cm3  - Total volume in cm^3
    % tumorAreas            - Vector of tumor areas for each slice
    % tumorMasks            - Struct with tumor masks for 'sagittal' and 'axial' planes
    % selected_mask         - A binary mask used for further analysis (i.e.
    %                         dice coefficient
    
    % Initialize variables
    tumorAreas = [];
    totalTumorVolume = 0;
    index_neg = 0;
    index_slices = 0;
    tumorMasks = struct();
    tumor_index=1;
    selected_mask=[];
    % Define slice indices and thresholds based on plane
    if strcmp(plane, 'axial')
        sliceStart = 65; 
        sliceEnd = 89;
        thresholdValue1 = 255;  
        thresholdValue2 = 110;
        roiBounds = [98, 158; 128, 180]; % [rows_start, rows_end; cols_start, cols_end]
    elseif strcmp(plane, 'sagittal')
        sliceStart = 108; 
        sliceEnd = 143;
        thresholdValue1 = 245;  
        thresholdValue2 = 105;
        roiBounds = [10, 60; 135, 180]; % [rows_start, rows_end; cols_start, cols_end]
    else
        error('Invalid plane. Use "sagittal" or "axial".');
    end

    % Loop through each slice in the specified plane
    for sliceNumber = sliceStart:sliceEnd
        if strcmp(plane, 'axial')
            Slice = squeeze(volumeData(:, :, sliceNumber));
            if sliceNumber == 74
                [counts, binLocations] = imhist(Slice);
                figure;
                bar(binLocations, counts);
                title('Histogram of Slice');
                xlabel('Pixel Intensity');
                ylabel('Frequency');
            end
        else % sagittal
            Slice = rot90(squeeze(volumeData(sliceNumber, :, :)));
            if sliceNumber == 127
                [counts, binLocations] = imhist(Slice);
                figure;
                bar(binLocations, counts);
                title('Histogram of Slice');
                xlabel('Pixel Intensity');
                ylabel('Frequency');
            end
        end

        % Create ROI mask
        [rows, cols] = size(Slice);
        roiMask = false(rows, cols);
        roiMask(roiBounds(1, 1):roiBounds(1, 2), roiBounds(2, 1):roiBounds(2, 2)) = true;

        % Normalize intensity
        minIntensity = double(min(Slice(:)));   
        maxIntensity = double(max(Slice(:)));   
        enhancedSlice = uint8(255 * (double(Slice) - minIntensity) / (maxIntensity - minIntensity));

        % Threshold-based mask
        thresholdMask = enhancedSlice < thresholdValue1 & enhancedSlice > thresholdValue2;
        thresholdMask = thresholdMask & roiMask;
        thresholdMask = bwareaopen(thresholdMask, 80); 
        se1 = strel('disk', 7); 
        thresholdMask = imopen(thresholdMask, se1);

        % Edge detection mask (only for sagittal plane)
        if strcmp(plane, 'sagittal')
            edges = edge(Slice, 'canny');
            edgeMask = imfill(edges, 'holes');
            edgeMask = edgeMask & roiMask;
            se2 = strel('disk', 2);
            edgeMask = imopen(edgeMask, se2);

            % Combine both masks
            combinedMask = thresholdMask | edgeMask;
        else
            combinedMask = thresholdMask;
        end

        % Filter connected components
        connectedComponents = bwconncomp(combinedMask);
        stats = regionprops(connectedComponents, 'Area');
        areas = [stats.Area];
        tumorMask = areas > 5;
        filteredComponents = ismember(labelmatrix(connectedComponents), find(tumorMask));

        if sum(tumorMask) > 1
            [~, largestIdx] = max(areas .* tumorMask);
            largestComponent = ismember(labelmatrix(connectedComponents), largestIdx);
            filteredComponents = largestComponent;
        end

        error_1 = double(Slice)-double(filteredComponents)*255;

        % Calculate tumor area for the slice
        tumorArea = nnz(filteredComponents);
        if tumorArea == 0
            index_neg = index_neg + 1;
        else
            index_slices = index_slices + 1;
        end
        tumorAreas = [tumorAreas; tumorArea];
        totalTumorVolume = totalTumorVolume + tumorArea;

        if sliceNumber == 135
            if strcmp(plane, 'sagittal')
                selected_mask=filteredComponents;
            end
            fprintf('The value of the Area for the slice number 135 is equal to: %d pixels\n', tumorArea);
            fprintf('The value of the Area for the slice number 135 is equal to: %.2f mm^2\n', tumorArea * voxelArea);
            fprintf('The value of the Area for the slice number 135 is equal to: %.2f cm^2\n', (tumorArea * voxelArea) / 100);
        end

        % Save the tumor mask for each plane
        if strcmp(plane, 'axial')
            tumorMasks.axial{tumor_index} = filteredComponents;
        else
            tumorMasks.sagittal{tumor_index} = filteredComponents;
        end
        tumor_index=tumor_index+1;
        % Visualization for each slice
        figure;
        subplot(2, 2, 1);
        imshow(Slice, [], 'InitialMagnification', 'fit');
        title(sprintf('Original Slice (No. %d)', sliceNumber));

        subplot(2, 2, 2);
        imshow(filteredComponents, []);
        title(sprintf('Combined Tumor Mask (Area: %d px)', tumorArea));

        subplot(2, 2, 3);
        imshow(roiMask, []);
        title('Region of Interest (ROI)');

        subplot(2, 2, 4);
        imshow(error_1, []);
        title('Tumor over the image');
    end

    % Calculate total volume
    totalTumorVolume_mm3 = totalTumorVolume * voxelVolume;
    totalTumorVolume_cm3 = totalTumorVolume_mm3 / 1000;

    % Display results
    disp(['Number of Slices where the tumor is not found: ' num2str(index_neg)]);
    disp(['Ratio between found and not found is: ' num2str(100*(index_slices/(index_slices + index_neg))) '%']);
    disp(['Tumor Areas (pixels): ', mat2str(tumorAreas)]);
    disp(['Total Tumor Volume ', plane, '(pixels^3): ', num2str(totalTumorVolume)]);
    disp(['Total Tumor Volume ', plane, ' (mm^3): ', num2str(totalTumorVolume_mm3)]);
    disp(['Total Tumor Volume ', plane, ' (cm^3): ', num2str(totalTumorVolume_cm3)]);
end
