function noisy_volumes=add_noise(original_volume, save_data)
    % Add and visualize noise for a given MRI volume
    % INPUTS:
    % original_volume: 3D matrix of the MRI data
    % save_data: boolean, true to save the noisy volumes, false otherwise
    
    % Define noise levels
    noise_levels = [0.01, 0.1, 0.3]; % Low, high, really high levels
    
    % Initialize structure for noisy data
    noisy_volumes = struct();
    
    %% Add Gaussian noise
    for i = 1:length(noise_levels)
        noisy_volumes.gaussian{i} = imnoise(double(original_volume) / 255, 'gaussian', noise_levels(i)) * 255;
    end
    
    % Add Salt & Pepper noise
    for i = 1:length(noise_levels)
        noisy_volumes.salt_pepper{i} = imnoise(double(original_volume) / 255, 'salt & pepper', noise_levels(i)) * 255;
    end
    
    % Add Speckle noise
    for i = 1:length(noise_levels)
        noisy_volumes.speckle{i} = imnoise(double(original_volume) / 255, 'speckle', noise_levels(i)) * 255;
    end

    % Save noisy data if required
    if save_data
        save('NoisyMRIdata.mat', 'noisy_volumes');
    end
    
end
