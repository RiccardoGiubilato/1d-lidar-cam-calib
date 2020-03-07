% Calibration camera - altimeter
% Riccardo Giubilato
% Dec 2018

close all
clear all


% Image and lidar scan path (files must be listed in the same order)
left_path = '../images/';
scan_path = '../scans/';

%% Toggles
% Use existing camera calibration (load 'cameraCalib.mat 'from workspace)
% or recalibrate
reload_camera_calib = 1;

%% Process Image
if reload_camera_calib == 1
    load('cameraCalib.mat');
    h2=figure; 
    set(h2, 'renderer', 'painters')
    showExtrinsicsMod(cameraParams, 'CameraCentric');
else 
    camera_calibration_script;
end
planes = generate_planes(cameraParams);

%% Process Lidar Altimeter
scans = read_lidar(scan_path) * 1000; % m -> mm
scans = scans(imagesUsedCheckerboard);
scans = scans(imagesUsedCalib);

% %% Synthetic dataset
% dgen_options.num_samples = 30;
% dgen_options.max_angle = 60 * pi/180;
% dgen_options.noise_range = 10; % mm
% dgen_options.dgen_type    = 'random';
% dgen_options.plot = true;
% [planes, scans, h] = synt_dataset(dgen_options);

%% Calibration
[extr, res, extr0, res0, ~, ~, inliers] = calibration(planes, scans);

%% Plot
overlay_3d(h2, extr, scans);
% overlay_imm(extr, scans, res, inliers, left_path, cameraParams,imagesUsedCheckerboard, imagesUsedCalib);
% plots(res);