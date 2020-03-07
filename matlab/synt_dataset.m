function [planesT, ranges, fighandle] = synt_dataset(dgen_options)

%% Check input
gen_type = dgen_options.dgen_type;
num_samples = dgen_options.num_samples;

if isfield(dgen_options, 'noise_range')
    noise_range = dgen_options.noise_range;
else
    noise_range = 0;
end

if isfield(dgen_options, 'plot')
    plot = dgen_options.plot;
else
    plot = false;
end 

if isfield(dgen_options, 'max_angle')
    angle_scaling = dgen_options.max_angle;
else
    angle_scaling = 1; % equivalent to max 1 radians
end
    
if strcmp(gen_type, 'ortho') && strcmp(gen_type, 'random')
    error('gen_type must be equal to [ortho] or [random]')
end

if num_samples < 6
    error('num_samples must be >= 6')
end

fprintf('Generating dataset with numSamples: %d, rangenoise: %1.2f\n [mm]', num_samples, noise_range);

%% Generate samples

% Altimeter is coincident with optical center and parallel to z axis
alti = [0 0 0 0 0 1];

switch gen_type
    case 'ortho'
        error('ortho not implemented..!')
    case 'random'   
        
        % Generate planes
        x_offset = 0.2;
        origins = [x_offset * ones(1,num_samples); ...
                   zeros(1,num_samples);    ...
                   2 * rand(1, num_samples) + ones(1, num_samples)];
        origins = 1000 * origins; % Units are [m]!
        alphas = 2 * angle_scaling * (rand(1, num_samples) - 0.5*ones(1, num_samples));
        betas  = 2 * angle_scaling * (rand(1, num_samples) - 0.5*ones(1, num_samples));
        orientations = - [sin(alphas); sin(betas); cos(alphas)];
        orientations = orientations / norm(orientations);
        
        % Generate intersections
        % Orientations columns are normal vectors for each plane
        % Compute d
        dvec = - sum(orientations.*origins, 1);
        
        % "Altimeter" set to origin with direction along z.
        % Distance is also z of the intersection point with z axis, while
        % other axis coordinates are null
        ranges_clean = - dvec ./ orientations(3, :);
        
        % Add noise
        if noise_range ~= 0
           ranges = ranges_clean + normrnd(0, noise_range, size(ranges_clean, 1), size(ranges_clean, 2)); 
        else
           ranges = ranges_clean;
           warning('No noise added to range')
        end
        
        % Return fake matrices for planes
        planesT = repmat(eye(4,4), [1, 1, num_samples]);
        for i=1:num_samples
            planesT(1:3, 3, i) = orientations(:,i);
            v1 = cross([1 0 0], orientations(:,i)); v1 = v1 / norm(v1);
            v2 = cross(v1, orientations(:,i));      v2 = v2 / norm(v2);
            planesT(1:3, 1, i) = v1;
            planesT(1:3, 2, i) = v2;
            
            planesT(1:3, 4, i) = origins(:,i);
        end
        
        ranges = ranges';
        
        if plot
            % Plot planes
            fighandle = figure;
%             hn = quiver3(origins(1,:), origins(3,:), origins(2,:), ...
%                     orientations(1,:), orientations(3,:), orientations(2,:), ...
%                     'LineWidth', 1.5);
              
            hold on  
            
            hl = 500;
            edges = [ hl  hl 0 1; ...
                     -hl  hl 0 1; ...
                     -hl -hl 0 1; ...
                      hl -hl 0 1; ...
                      hl  hl 0 1;]'; 
            for i=1:num_samples         
                planerot = planesT(:,:,i) * edges;
                plot3(planerot(1,:), planerot(3,:), planerot(2,:), 'Color', [0.3 0.3 0.3]);
                h_plane = fill3(planerot(1,:), planerot(3,:), planerot(2,:), 'k', 'FaceAlpha', 0.05);
            end
            
            % Plot altimeter thruth
            h_line = plot3([0 0], [0, max(ranges)], [0 0], '--r', 'LineWidth', 1.5);
            hr = scatter3(x_offset * ones(1, num_samples), ranges_clean, zeros(1, num_samples), ...
                'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 1]);
            
            h_alti = scatter3(0, 0, 0, 108, 'k', 'filled');
            
            fs = 14;
            
            xlabel('x [mm]', 'FontSize', fs, 'Interpreter', 'latex')
            ylabel('z [mm]', 'FontSize', fs, 'Interpreter', 'latex')
            zlabel('y [mm]', 'FontSize', fs, 'Interpreter', 'latex')
            set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', fs)
            axis equal
            view([90, 0])
            axis([-300 800 0 3600 -600 600])
            ax = gca;
            ax.ZDir = 'reverse';
            set(gcf, 'renderer', 'painters')
            legend([h_alti, h_plane, hr], '$O_A$', '$\pi_i$', '$P_A$', 'NumColumns', 3, 'interpreter', 'latex', 'FontSize', fs)
            %Plot2LaTeX(fighandle, 'test')
            print('./synth.svg', '-dsvg');
        else
            fighandle = false; 
        end
end



end