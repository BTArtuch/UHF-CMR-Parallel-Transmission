function generate_synthetic_b1(output_path)
    % Grid and Phantom Parameters
    matrix_size = 128;
    fov = 0.4; % 40 cm Field of View
    [x, y] = meshgrid(linspace(-fov/2, fov/2, matrix_size));
    
    % Elliptical body mask approximating a human torso
    body_mask = (x.^2 / 0.18^2) + (y.^2 / 0.12^2) <= 1;
    
    % 7T Tissue Physics Approximations (298 MHz)
    % The high dielectric constant of tissue shrinks the RF wavelength
    wavelength = 0.13; % ~13 cm in cardiac tissue
    k = 2 * pi / wavelength; % Wave number driving phase accumulation
    attenuation = 15; % Exponential decay factor in lossy tissue
    
    % 8-Channel Coil Array Setup
    num_coils = 8;
    coil_radius = 0.22; % 22 cm radius for the transmit coil former
    b1_maps = zeros(matrix_size, matrix_size, num_coils);
    
    for i = 1:num_coils
        % Position each coil element in a ring
        theta = (i - 1) * (2 * pi / num_coils);
        cx = coil_radius * cos(theta);
        cy = coil_radius * sin(theta);
        
        % Compute distance from the current coil to every pixel
        d = sqrt((x - cx).^2 + (y - cy).^2);
        
        % Synthetic B1+ field calculation
        % Amplitude decays with distance and tissue absorption
        amplitude = (1 ./ (d + 0.05)) .* exp(-attenuation * d);
        
        % Phase oscillates rapidly due to the short wavelength
        phase = exp(-1i * k * d);
        
        % Apply body mask and store the complex map
        b1_maps(:, :, i) = amplitude .* phase .* body_mask;
    end
    
    % Create an artificial B0 off-resonance map (Hz)
    % Includes a spatial gradient and Gaussian noise
    b0_map = (50 * x + 20 * y + 10 * randn(matrix_size)) .* body_mask;
    
    % Save Outputs
    [out_dir, ~, ~] = fileparts(output_path);
    if ~exist(out_dir, 'dir') && ~isempty(out_dir)
        mkdir(out_dir);
    end
    
    save(output_path, 'b1_maps', 'b0_map', 'body_mask');
    fprintf('Synthetic complex B1+ maps successfully saved to %s\n', output_path);
end