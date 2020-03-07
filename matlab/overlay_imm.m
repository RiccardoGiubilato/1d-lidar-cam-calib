function overlay_imm(extr, scans, res, inliers, path, cameraParams, imagesUsedCheckerboard, imagesUsedCalib)

%% Check inputs
if size(extr, 1) ~= 1
    extr = extr';
end

%% Load images and undistort
imagefiles = dir(path);
imagefiles = imagefiles(3:end);
for i = 1:length(imagefiles)
   imageFileNames{i} = num2str([imagefiles(i).folder, '/', imagefiles(i).name]); 
end

% Select images used for calibration
imageFileNames = imageFileNames(imagesUsedCheckerboard);
imageFileNames = imageFileNames(imagesUsedCalib);

for i = 1:length(imageFileNames)
   I{i} = undistortImage(rgb2gray(imread(imageFileNames{i})), cameraParams);
end

% Pick inliers
scans = scans(inliers);
I = I(inliers);

% Generate image lidar projections
pts_cam = repmat(extr(4:6), length(I), 1) .* scans + ...
          repmat(extr(1:3), length(I), 1);
pts_im  = worldToImage(cameraParams,eye(3),[0 0 0], pts_cam);

% Plot in subplots
nplots = ceil(length(I) / 6);
for pl = 1:nplots
  figure
  for spl = 1:min([6, length(I) - (pl-1)*6])
     scan = 6*(pl-1) + spl;
     subplot(3,2,spl)
     imshow(flip(flip(I{scan}, 1), 2))
     hold on
     scatter(pts_im(scan, 1), pts_im(scan, 2), 72, 'r', 'filled')
     
     % Compute residuals
     title(num2str(['$\mathbf{d(\pi p_A)}$ \textbf{[mm]: ', num2str(abs(res(scan)), '%1.2f'), '}']), 'interpreter', 'latex', 'FontSize', 12);
  end
  %sgtitle(num2str(['Lidar-Image Overlay (', num2str(pl), '/', num2str(nplots), ')']));
end



end


