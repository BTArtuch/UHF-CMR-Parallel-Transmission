function create_cardiac_roi(input_path, output_path)
    % Load the previously generated synthetic data
    load(input_path, 'b1_maps', 'b0_map', 'body_mask');
    
    % Recreate the spatial grid to define the ROI coordinates
    matrix_size = size(body_mask, 1);
    fov = 0.4; % 40 cm Field of View matches our generation script
    [x, y] = meshgrid(linspace(-fov/2, fov/2, matrix_size));
    
    % Define the synthetic myocardium (left ventricle)
    % The heart is typically situated anteriorly and to the patients left
    heart_offset_x = 0.04; 
    heart_offset_y = 0.05; 
    
    % Compute the distance from every pixel to the center of our fabricated heart
    distance_from_heart = sqrt((x - heart_offset_x).^2 + (y - heart_offset_y).^2);
    
    % Define the epicardial (outer) and endocardial (inner) boundaries
    r_outer = 0.05; % 5 cm outer radius
    r_inner = 0.03; % 3 cm inner radius
    
    % Create the mask
    % The ROI is the ring between the inner and outer radius, strictly within the body
    cardiac_roi = (distance_from_heart <= r_outer) & (distance_from_heart >= r_inner) & body_mask;
    
    % Save the updated dataset
    save(output_path, 'b1_maps', 'b0_map', 'body_mask', 'cardiac_roi');
    fprintf('Cardiac ROI successfully generated and saved to %s\n', output_path);
end