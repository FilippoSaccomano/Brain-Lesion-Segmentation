function [totalTumorVolume, totalTumorVolume_mm3, totalTumorVolume_cm3, tumorAreas, tumorMasks] = calculateTumorVolume_Noisy(plane, volumeData, voxelVolume,noiseType)
    % INPUT:
    % plane        - A string specifying the plane for visualization: 'sagittal' or 'axial'
    % volumeData   - Structure containing the volume data (e.g., noisy_volumes.salt_pepper)
    % voxelVolume  - Volume of one voxel (in mm^3)
    % voxelArea    - Area of one voxel (in mm^2)
    
    % OUTPUT:
    % totalTumorVolume      - Total volume in pixel cubed
    % totalTumorVolume_mm3  - Total volume in mm^3
    % totalTumorVolume_cm3  - Total volume in cm^3
    % tumorAreas            - Vector of tumor areas for each slice
    % tumorMasks            - Struct with tumor masks for 'sagittal' and 'axial' planes
    
    % Initialize variables
    tumorAreas = [];
    totalTumorVolume = 0;
    tumorMasks = struct();
    tumor_index = 1;

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
        else % sagittal
            Slice = rot90(squeeze(volumeData(sliceNumber, :, :)));
        end

        % Create ROI mask
        [rows, cols] = size(Slice);
        roiMask = false(rows, cols);
        roiMask(roiBounds(1, 1):roiBounds(1, 2), roiBounds(2, 1):roiBounds(2, 2)) = true;

        % Normalize intensity
        minIntensity = double(min(Slice(:)));   
        maxIntensity = double(max(Slice(:)));   
        enhancedSlice = uint8(255 * (double(Slice) - minIntensity) / (maxIntensity - minIntensity));

        % Apply the appropriate filter based on the type of noise
        if strcmp(noiseType, 'gaussian')
            % For Gaussian noise, use an average filter to smooth the image
            filteredImage = imfilter(enhancedSlice, fspecial('average', [3 3]), 'replicate');
        elseif strcmp(noiseType, 'salt_pepper')
            % For Salt and Pepper noise, use a median filter to remove isolated pixels
            filteredImage = medfilt2(enhancedSlice, [3 3]);
        elseif strcmp(noiseType, 'speckle')
            % For Speckle noise, use a Gaussian filter to reduce multiplicative noise
            filteredImage = imgaussfilt(enhancedSlice, 1); % Or use imbilatfilt for edge-preserving smoothing
        else
            % If the noise type is not recognized, return the noisy image unfiltered
            filteredImage = noisyImage;
        end
        
        if sliceNumber==135 
            selected_slice=enhancedSlice;
            selected_filtered=filteredImage;
        end

        % Threshold-based mask
        thresholdMask = filteredImage < thresholdValue1 & filteredImage > thresholdValue2;
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

        % Calculate tumor area for the slice
        tumorArea = nnz(filteredComponents);
        tumorAreas = [tumorAreas; tumorArea];
        totalTumorVolume = totalTumorVolume + tumorArea;

        % Save the tumor mask for each plane
        if strcmp(plane, 'axial')
            tumorMasks.axial{tumor_index} = filteredComponents;
        else
            tumorMasks.sagittal{tumor_index} = filteredComponents;
        end
        tumor_index = tumor_index + 1;
    end

    % Calculate total volume
    totalTumorVolume_mm3 = totalTumorVolume * voxelVolume;
    totalTumorVolume_cm3 = totalTumorVolume_mm3 / 1000;

    if strcmp(plane, 'sagittal')
        figure();
        subplot(121)
        imshow(selected_slice)
        title("Slice with the selected noise ")

        subplot(122)
        imshow(selected_filtered)
        title('Slice after noise removal ');
    end

end
