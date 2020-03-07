function ax = showExtrinsicsMod(cameraParams, varargin)
%showExtrinsics Visualize extrinsic camera parameters.
%   showExtrinsics(cameraParams) renders a 3-D visualization of extrinsic 
%   parameters of a single calibrated camera or a calibrated stereo pair. 
%   It plots a 3-D view of the calibration patterns with respect to the 
%   camera. cameraParams can be either a cameraParameters object or a 
%   stereoParameters object returned by the estimateCameraParameters
%   function, or a fisheyeParameters object returned by the
%   estimateFisheyeParameters function.
%
%   showExtrinsics(cameraParams, view) displays visualization of 
%   the camera extrinsic parameters using the style specified by view. 
%   Values of view can be:
%
%     'CameraCentric': Use it if you kept your camera stationary while 
%                      moving the calibration pattern.
%     'PatternCentric' Use it if the pattern was stationary while you moved
%                      your camera.
%
%   ax = showExtrinsics(...) returns the plot's axes.
%
%   showExtrinsics(...,Name,Value) specifies additional name-value pair 
%   arguments described below:
%
%   'HighlightIndex' Select patterns to highlight. The index is specified
%                    as a vector.  For example, to highlight patterns 1 and 
%                    4, you would use [1, 4], which increases the opacity
%                    of these two patterns in contrast to the rest of the
%                    patterns.
%
%                    Default: []
%
%   'Parent'         Specify an output axes for displaying the visualization.
%
%   Class Support
%   -------------
%   cameraParams must be a either a cameraParameters object, a
%   stereoParameters object or a fisheyeParameters object.
%
%   Example 1 - Single camera
%   ------------------------  
%   % Create a set of calibration images.
%   images = imageDatastore(fullfile(toolboxdir('vision'), 'visiondata', ...
%     'calibration', 'webcam'));
%   imageFileNames = images.Files(1:5);
%
%   % Detect calibration pattern.
%   [imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);
%
%   % Generate world coordinates of the corners of the squares.
%   squareSide = 25; % square size in millimeters
%   worldPoints = generateCheckerboardPoints(boardSize, squareSide);
%
%   % Calibrate the camera.
%   I = readimage(images,1); 
%   imageSize = [size(I, 1), size(I, 2)];
%   cameraParams = estimateCameraParameters(imagePoints, worldPoints, ...
%                                     'ImageSize', imageSize);
%
%   % Visualize pattern locations.
%   figure
%   showExtrinsics(cameraParams);
%
%   % Visualize camera locations.
%   figure
%   showExtrinsics(cameraParams, 'patternCentric');
%
%   Example 2 - Stereo camera
%   ---------------------------------
%   % Specify calibration images
%   imageDir = fullfile(toolboxdir('vision'), 'visiondata', ...
%       'calibration', 'stereo');
%   leftImages = imageDatastore(fullfile(imageDir, 'left'));
%   rightImages = imageDatastore(fullfile(imageDir, 'right'));
% 
%   % Detect the checkerboards
%   [imagePoints, boardSize] = detectCheckerboardPoints(...
%        leftImages.Files, rightImages.Files);
% 
%   % Specify world coordinates of checkerboard keypoints
%   squareSize = 108; % millimeters
%   worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% 
%   % Calibrate the stereo camera system. Here both cameras have the same
%   % resolution.
%   I = readimage(leftImages,1); 
%   imageSize = [size(I, 1), size(I, 2)];
%   cameraParams = estimateCameraParameters(imagePoints, worldPoints, ...
%                                     'ImageSize', imageSize);
% 
%   % Visualize pattern locations
%   figure; 
%   showExtrinsics(cameraParams);
%
%   % Visualize camera locations
%   figure; 
%   showExtrinsics(cameraParams, 'patternCentric');
%
%   See also  showReprojectionErrors, cameraCalibrator, stereoCameraCalibrator,
%      estimateCameraParameters, cameraParameters, stereoParameters, 
%      extrinsics, plotCamera, fisheyeParameters

%   Copyright 2014-2017 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

[offset, wpConvexHull, extView, highlightIndex, numBoards, hAxes] = ...
    parseInputs(cameraParams, varargin{:});

% colormap for board highlighting
boardColorLookup = im2double(label2rgb(1:numBoards, 'lines','c','shuffle'));

if strcmp(extView, 'PatternCentric')
    patternCentric;
else
    cameraCentric;
end

title(hAxes, getString(message('vision:calibrate:showExtrinsicsTitle')));
setAxesProperties();

if nargout == 1
    ax = hAxes;
end

%--------------------------------------------------------------------------
    function setAxesProperties
        rotate3d(hAxes,'on');
        grid(hAxes, 'on');
        axis(hAxes, 'equal');        
    end

%--------------------------------------------------------------------------
    function [offset, wpConvHull, extView, highlightIndex, numBoards, ...
            hAxes] = parseInputs(camParams, varargin)

        validateattributes(camParams, {'cameraParameters', ...
            'stereoParameters', 'fisheyeParameters'},...
            {}, mfilename, 'cameraParams');        
                
        numBoards = camParams.NumPatterns;
        
        % Parse the P-V pairs
        parser = inputParser;
        
        parser.addOptional('View', 'CameraCentric', @checkView);
        parser.addParameter('HighlightIndex', [], @checkIndex);
        parser.addParameter('Parent', [], ...
            @vision.internal.inputValidation.validateAxesHandle);
        
        parser.parse(varargin{:});
        
        % re-parse one more time to expand partial strings
        extView = validatestring(parser.Results.View,...
            {'PatternCentric','CameraCentric'}, ...
            mfilename, 'View');
        
        if any(parser.Results.HighlightIndex > numBoards)
            error(message('vision:calibrate:invalidHighlightIndex'));
        end

        % turn the highlight index into a logical vector
        highlightIndex = false(1,numBoards);
        highlightIndex(unique(parser.Results.HighlightIndex)) = true;
        
        hAxes = newplot(parser.Results.Parent);        
        
        [wpConvHull, offset] = computeConvexHull(camParams);
    end

%--------------------------------------------------------------------------
    function r = checkView(in)
        validatestring(in, {'PatternCentric','CameraCentric'}, ...
            mfilename, 'View');
        r = true;
    end
%--------------------------------------------------------------------------
    function r = checkIndex(in)
        if ~isempty(in) % permit any kind of empty including []
            validateattributes(in, {'numeric'},{'integer','vector'});
        end
        r = true;
    end

%--------------------------------------------------------------------------
    function ret = addUnits(in)
        units = cameraParams.WorldUnits;
        ret = [in, ' (', units, ')'];
    end

%--------------------------------------------------------------------------
    function [wpConvHull, offset] = computeConvexHull(camParams)
        x = camParams.WorldPoints(:,1);
        y = camParams.WorldPoints(:,2);
        
        k = convhull(x, y, 'simplify',true);
                
        % pad with zeros so that Z = 0;
        wpConvHull = [x(k), y(k), zeros(length(k),1)]';        

        % compute the longest side of a convex hull enclosing points
        % collected from the calibration pattern
        maxDist = 0;
        for i = 1:length(k)-1
            % compute distances between all vertices of the convex hull
            d = norm(wpConvHull(1:2,i) - wpConvHull(1:2,i+1));
            if d > maxDist
                maxDist = d;
            end
        end

        % We'll use this value as a drawing unit proportional to the 
        % calibration board size. This value is picked to make the plots
        % "look good".
        offset = maxDist/6;

        % In the case of stereo, prevent the offset from being too big
        % to cause the cameras to overlap.
        isStereo = isa(camParams, 'stereoParameters');                
        if isStereo
            distBetweenCameras = sqrt(sum(camParams.TranslationOfCamera2.^2));
            offset = min(offset, 0.8 * distBetweenCameras);
        end
    end

%--------------------------------------------------------------------------
    function cameraCentric

        plotFixedCam;
                
        set(hAxes,'XAxisLocation','top','YAxisLocation',...
            'left','ZDir','reverse');
        
        [rotationMatrices, translationVectors] = ...
            getRotationAndTranslation(cameraParams);

        for boardIdx = 1:numBoards            
            R = rotationMatrices(:, :, boardIdx)';
            t = translationVectors(boardIdx, :)';
            [color, alpha] = getColor(boardIdx, boardColorLookup, highlightIndex);
            
            worldBoardCoords = bsxfun(@plus, R * wpConvexHull, t);            

            [xIdx, yIdx, zIdx] = getAxesIdx();
            
            wX = worldBoardCoords(xIdx,:);
            wY = worldBoardCoords(yIdx,:);
            wZ = worldBoardCoords(zIdx,:);

            h = patch(wX,wY,wZ, color, 'Parent', hAxes);
            %set(h,'FaceColor',color,'FaceAlpha',0.2, ...
             %        'EdgeColor',color,'LineWidth',1.0);
            h.FaceAlpha = 0.2; 
            
            %if (highlightIndex(boardIdx))
            %    tagStr = ['HighlightedExtrinsicsObj' num2str(boardIdx)];
            %else
            %    tagStr = ['ExtrinsicsObj' num2str(boardIdx)];
            %end
            
            
            
            % label each board
            ulCorner = t - 0.3*[offset; offset; 0];
            %text(ulCorner(xIdx),ulCorner(yIdx),ulCorner(zIdx),...
            %    num2str(boardIdx),'fontsize',14,'color',color, ...
            %    'Parent', hAxes);
        end        
        labelPlotAxesCameraCentric(hAxes);                
    end

%--------------------------------------------------------------------------
    function patternCentric
        
        plotPatternCentricBoard(hAxes, wpConvexHull, offset);

        % Record the current 'hold' state so that we can restore it later
        holdState = get(hAxes,'NextPlot');
        
        set(hAxes, 'NextPlot', 'add'); % hold on
        
        [rotationMatrices, translationVectors] = ...
            getRotationAndTranslation(cameraParams);

        % Draw the cameras
        for camIdx = 1:numBoards            
            rotation = rotationMatrices(:, :, camIdx)';
            translation = translationVectors(camIdx, :)';

            [camColor, alpha] = getColor(camIdx, boardColorLookup, highlightIndex);
            
            isStereo = isa(cameraParams, 'stereoParameters');
            if isStereo
                plotStereoMovingCam(camIdx, rotation, translation,...
                    camColor, alpha, highlightIndex);                
            else
                % plot the camera
                label = num2str(camIdx);
                plotMovingCam(rotation, translation, ...
                    camColor, alpha, camIdx, highlightIndex, label);
            end
        end        
        set(hAxes, 'NextPlot', holdState); % restore the hold state       
        labelPlotAxesPatternCentric(hAxes);        
    end

%--------------------------------------------------------------------------
    function plotPatternCentricBoard(hAxes, wpConvexHull, offset)
        wX = wpConvexHull(1,:);
        wY = wpConvexHull(2,:);
        wZ = wpConvexHull(3,:);
        
        % Draw a small axis in the corner of the board. BTW. Invoking plot3
        % first, sets up good default for azimuth and elevation.
        plot3(hAxes, 3*offset*[1 0 0 0 0],3*offset*[0 0 1 0 0],...
            3*offset*[0 0 0 0 1],'r-','linewidth',2);

        % The origin of the coordinate system is in upper left corner, with
        % x-axis increasing to the right and y-axis increasing in the down
        % direction; this is for the right-handed coordinate system that we
        % used for computing the extrinsics
        set(hAxes,'XAxisLocation','top','YAxisLocation',...
            'left','YDir','reverse');
        
        % Draw the board
        h = patch(wX,wY,wZ, 'Parent', hAxes);
        set(h,'FaceColor', [0.4 0.4 0.4]);
        set(h,'EdgeColor', 'black','linewidth',1);
    end        

%--------------------------------------------------------------------------
    function plotStereoMovingCam(camIdx, rotation, translation, camColor, alpha, highlightIndex)
        % plot camera 1
        [center1, hHggroup1] = plotMovingCam(rotation, translation, ...
            camColor, alpha, camIdx, highlightIndex);
        labelStereoCamera(hHggroup1, center1, '1', camColor);
        
        % plot camera 2
        t = cameraParams.CameraParameters2.TranslationVectors(camIdx,:)';
        R = cameraParams.CameraParameters2.RotationMatrices(:,:,camIdx)';
        [center2, hHggroup2] = plotMovingCam(R , t,  ...
            camColor, alpha, camIdx, highlightIndex);
        labelStereoCamera(hHggroup2, center2, '2', camColor);
        
        % connect the two cameras with a line
        % assign the plot3 to hHggroup1
        plot3(hHggroup1, [center1(1), center2(1)], ...
            [center1(2), center2(2)], [center1(3), center2(3)], ...
            '-', 'Color', camColor, 'LineWidth', 2,'HitTest','off');
        
        % label the stereo pair
        % assign the label to hHggroup1
        midPoint = (center2 + center1) / 2 + [8; 8; 12];
        text(midPoint(1), midPoint(2), midPoint(3), num2str(camIdx), ...
            'Parent', hHggroup1, 'fontsize', 15, 'Color', camColor, 'HitTest','off');
    end

%--------------------------------------------------------------------------
    function labelPlotAxesPatternCentric(hAxes)
        xlabel(hAxes, addUnits('X'));
        ylabel(hAxes, addUnits('Y'));
        zlabel(hAxes, addUnits('Z'));
        
        % Z goes into the board. Reversing Z direction to display the
        % cameras above the board.
        set(hAxes, 'ZDir', 'reverse');
    end

%--------------------------------------------------------------------------
    function labelPlotAxesCameraCentric(hAxes)        
        xlabel(hAxes, addUnits('X'));
        
        % note that the Y and the Z axes are switched
        ylabel(hAxes, addUnits('Z'));
        zlabel(hAxes, addUnits('Y'));
    end
        
%--------------------------------------------------------------------------
    function labelStereoCamera(hHggroup, center, label, camColor)
        text(center(1), center(2), center(3), label, 'Parent', hHggroup, ...
            'Color', camColor, 'FontSize', 11, 'FontWeight','bold','HitTest','off');
    end
%--------------------------------------------------------------------------
    function [camColor, alpha] = getColor(idx, colorLookup, highlightIndex)
        camColor = squeeze(colorLookup(1, idx, :))';
        
        % transparency values for board highlighting
        normalAlpha = 0.2;
        highlightAlpha = 0.8;
        
        if highlightIndex(idx)
            alpha = highlightAlpha;
        else
            alpha = normalAlpha;
        end
    end

%--------------------------------------------------------------------------
    function [rotationMatrices, translationVectors] = ...
            getRotationAndTranslation(cameraParams)
        isStereo = isa(cameraParams, 'stereoParameters');
        if isStereo
            rotationMatrices = cameraParams.CameraParameters1.RotationMatrices;
            translationVectors = cameraParams.CameraParameters1.TranslationVectors;
        else
            rotationMatrices = cameraParams.RotationMatrices;
            translationVectors = cameraParams.TranslationVectors;
        end
    end

%--------------------------------------------------------------------------
    function [camPts, camAxis] = rotateAndShiftCam(camPts, camAxis,...
            rot, tran)        
        
        % since we swapped the camera and the board, apply the 
        % transformation backwards: first we translate, then we rotate in
        % the opposite direction (take transpose of the rotation matrix) so
        % that the relative positioning of the camera with respect to the
        % board remains the same while the board is placed at an origin
        rot = rot';
        
        camAxis = rot*bsxfun(@minus, camAxis, tran);
        camPts  = rot*bsxfun(@minus, camPts, tran);                
    end

%--------------------------------------------------------------------------
    function [camPts, camAxis] = getCamPts(factor)
        
        cu = offset*factor;

        ln = cu+cu;  % cam length
        
        % back
        camPts = [0  0   cu  cu 0;...
                  0  cu  cu  0  0;...
                  0  0   0   0  0];
        % sides
        camPts = [camPts, ... 
                    [0   0  0  0  cu cu cu cu cu cu 0; ...
                     0   cu cu cu cu cu cu 0  0  0  0; ...
                     ln  ln 0  ln ln 0  ln ln 0  ln ln]]; 
              
        ro = cu/2;    % rim offset
        rm = ln+2*ro; % rim z offset (extent)
        
        % lens
        camPts = [camPts, ...
                   [ -ro  -ro     cu+ro   cu+ro  -ro; ...
                     -ro   cu+ro  cu+ro  -ro     -ro; ...
                      rm   rm     rm      rm      rm] ];
               
        % rim around the lens
        camPts = [camPts, ...
                   [0   0  -ro    0  cu  cu+ro cu cu  cu+ro cu  0 ;...
                    0   cu  cu+ro cu cu  cu+ro cu 0  -ro    0   0 ;...
                    ln  ln  rm    ln ln  rm    ln ln  rm    ln  ln] ];
        
        camPts = bsxfun(@minus, camPts, [cu/2; cu/2; cu]);
        
        % cam axis
        camAxis = 2*factor*offset*([0 1 0 0 0 0;
                                    0 0 0 1 0 0;
                                    0 0 0 0 0 1]);  
    end

%--------------------------------------------------------------------------
    function [center, hHggroup] = plotMovingCam(rotationMat, translation, camColor, ...
            alpha, idx, highlightIndex, label)
        
        [camPts, camAxis] = getCamPts(0.6);
        [camPts, camAxis] = ...
            rotateAndShiftCam(camPts, camAxis, rotationMat, translation);
        
        % Create a hggroup for each camera
        if highlightIndex(idx)
            hHggroup = hggroup('Parent',hAxes,'Tag',['HighlightedExtrinsicsObj' num2str(idx)]);
        else 
            hHggroup = hggroup('Parent',hAxes,'Tag',['ExtrinsicsObj' num2str(idx)]);
        end
        
        % draw camera wire frame        
        if alpha == 0
            plot3(hHggroup, camPts(1,:),camPts(2,:),camPts(3,:),'w-','linewidth',1, 'HitTest', 'off');
        end
                        
        % color camera surfaces
        %%%%%%%%%%%%%%%%%%%%%%%%

        % cam 'lens'
        lensPatch = struct('vertices', camPts', 'faces', 17:21);
        h = patch(lensPatch, 'Parent', hHggroup);
        set(h,'FaceColor', [0 0.8 1], 'FaceAlpha', alpha, ...
            'EdgeColor', camColor, 'HitTest', 'off');
        
        % cam back
        rimPatch = struct('vertices', camPts', 'faces', 1:5);
        h = patch(rimPatch, 'Parent', hHggroup);
        set(h,'FaceColor', camColor, 'FaceAlpha', alpha, ...
            'EdgeColor', camColor, 'HitTest', 'off');

        % cam sides
        sidePatch = struct('vertices', camPts', 'faces',...
            [5 6 7 8 5; 8 9 10 11 8; 11 12 13 14 11; 14 5 6 13 14]);
        h = patch(sidePatch, 'Parent', hHggroup);
        set(h,'FaceColor', camColor, 'FaceAlpha', alpha, ...
            'EdgeColor', camColor, 'HitTest', 'off');
        
        % cam rim
        rimPatch = struct('vertices', camPts', 'faces',...
            [21 22 23 24  21; 24 25 26  27 24;...
            27 28 29 30 27; 30 31 32 21 30]);
        
        h = patch(rimPatch, 'Parent', hHggroup);
        set(h,'FaceColor', camColor, 'FaceAlpha', alpha, ...
            'EdgeColor', camColor, 'HitTest', 'off');
        
        % Add camera labels
        %%%%%%%%%%%%%%%%%%%%
        if nargin > 6
            % positions of camera labels (offset from the camera axis)
            camLabelLoc = [camAxis(1,2), camAxis(2,4), ...
                2*camAxis(3,1)-camAxis(3,6) + offset/5];
            
            
            % label each camera with a number
            text(camLabelLoc(1),camLabelLoc(2),camLabelLoc(3),label,...
                'FontSize',11,'Color',camColor,'FontWeight','bold', ...
                'Parent', hHggroup, 'HitTest', 'off');
        end
        center = camAxis(:, 1);
        
    end

%--------------------------------------------------------------------------
    function plotFixedCam

        [camPts, camAxis] = getCamPts(1);
        isStereo = isa(cameraParams, 'stereoParameters');
                
        if isStereo
            color1 = 'b';
            plotOneFixedCamera(camPts, color1);
            plotFixedCameraAxis(hAxes, camAxis);
            labelFixedCamera(hAxes, camPts, '1', color1);
            
            t = cameraParams.TranslationOfCamera2;
            R = cameraParams.RotationOfCamera2;
            camPts2 = bsxfun(@minus, camPts', t);
            camPts2 = (camPts2 * R')';
            
            holdState = get(hAxes,'NextPlot');
            set(hAxes, 'NextPlot', 'add');
            color2 = 'r';
            plotOneFixedCamera(camPts2, color2);
            labelFixedCamera(hAxes, camPts2, '2', color2);
            set(hAxes, 'NextPlot', holdState); % restore the state
        else
            plotOneFixedCamera(camPts, 'b');
            plotFixedCameraAxis(hAxes, camAxis);
        end
    end
        
%--------------------------------------------------------------------------
    function plotOneFixedCamera(camPts, color)    
        [xIdx, yIdx, zIdx] = getAxesIdx();
        
        % plot the body
        plot3(hAxes, camPts(xIdx,:),camPts(yIdx,:),camPts(zIdx,:),...
            [color, '-'],'linewidth',1.5);
    end

%--------------------------------------------------------------------------
    function labelFixedCamera(hAxes, camPts, label, color)
        [xIdx, yIdx, zIdx] = getAxesIdx();

        % label the camera
        textIdx = 20;
        textOffset = 0.1 * offset;
        text(camPts(xIdx, textIdx)+textOffset, camPts(yIdx, textIdx)-textOffset, ...
            camPts(zIdx, textIdx), label, 'fontsize',14,...
            'Parent', hAxes, 'Color', color);
    end

%--------------------------------------------------------------------------
    function plotFixedCameraAxis(hAxes, camAxis)
        [xIdx, yIdx, zIdx] = getAxesIdx();

        % plot the x/y/z axis
        holdState = get(hAxes,'NextPlot');
        set(hAxes, 'NextPlot', 'add');
        plot3(hAxes, camAxis(xIdx,:),camAxis(yIdx,:),camAxis(zIdx,:),'k-',...
            'linewidth',1.5);
        set(hAxes, 'NextPlot', holdState); % restore the state
        
        % label camera axis
        d = 2.4*offset;
        text( d, 0, 0,'X_c', 'Parent', hAxes);
        text( 0, d, 0,'Z_c', 'Parent', hAxes);
        text( 0, 0, d,'Y_c', 'Parent', hAxes);
    end

%--------------------------------------------------------------------------
    function [xIdx, yIdx, zIdx] = getAxesIdx()
        % We are going to swap y and z coordinates because the 3-d plot
        % rotates around the MATLAB's z-axis by default. Thus the
        % camera can be displayed horizontally and the 3-d plot will
        % rotate conveniently around the newly defined vertical y-axis.
        xIdx = 1; yIdx = 3; zIdx = 2;
    end
end


