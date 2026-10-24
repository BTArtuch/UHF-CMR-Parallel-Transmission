function visualize_data(input_path, output_dir)
    % Load the synthetic data
    load(input_path, 'b1_maps', 'b0_map', 'body_mask', 'cardiac_roi');
    
    % Ensure output directory exists
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    % Create a hidden figure for headless batch execution
    fig = figure('Visible', 'off', 'Position', [100, 100, 1200, 800]);
    
    % --- Panel 1: Sum of Squares B1+ Magnitude ---
    % This simulates what the field looks like if we just combine all coils 
    % without any pTX shimming (showing the destructive interference).
    sos_b1 = sqrt(sum(abs(b1_maps).^2, 3));
    subplot(2, 3, 1);
    imagesc(sos_b1 .* body_mask);
    colormap(gca, 'hot'); colorbar;
    title('Sum of Squares B1+ Magnitude');
    axis image off;
    
    % --- Panel 2: Channel 1 B1+ Magnitude ---
    subplot(2, 3, 2);
    imagesc(abs(b1_maps(:,:,1)) .* body_mask);
    colormap(gca, 'hot'); colorbar;
    title('Ch 1 B1+ Magnitude');
    axis image off;
    
    % --- Panel 3: Channel 1 B1+ Phase ---
    subplot(2, 3, 3);
    imagesc(angle(b1_maps(:,:,1)) .* body_mask);
    colormap(gca, 'hsv'); colorbar; % HSV is best for cyclical phase data
    title('Ch 1 B1+ Phase (rad)');
    axis image off;
    
    % --- Panel 4: B0 Off-resonance Map ---
    subplot(2, 3, 4);
    imagesc(b0_map);
    colormap(gca, 'parula'); colorbar;
    title('B0 Off-resonance (Hz)');
    axis image off;
    
    % --- Panel 5: Body Mask & Cardiac ROI Overlay ---
    subplot(2, 3, 5);
    % Create an RGB image to show the body in gray and the ROI in red
    mask_vis = zeros(size(body_mask, 1), size(body_mask, 2), 3);
    mask_vis(:,:,1) = body_mask * 0.5 + cardiac_roi * 0.5; 
    mask_vis(:,:,2) = body_mask * 0.5 - cardiac_roi * 0.5; 
    mask_vis(:,:,3) = body_mask * 0.5 - cardiac_roi * 0.5; 
    imshow(mask_vis);
    title('Body Mask & Cardiac ROI (Red)');
    
    % Export the figure to the outputs directory
    out_file = fullfile(output_dir, 'synthetic_data_overview.png');
    exportgraphics(fig, out_file, 'Resolution', 300);
    fprintf('Visualization successfully saved to %s\n', out_file);
end