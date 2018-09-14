%% Computer Vision Challenge

envsetup;
close all;

% Groupnumber:
group_number = 25;

% Groupmembers:
members = {'Thomas Brenner', 'Simon Diehl', 'Matthias Donderer', 'Alexander Kurdas'};

% Email-Adress (from Moodle!):
mail = {'thomas.brenner@tum.de', 'simon.diehl@tum.de', 'matthias.donderer@tum.de', 'alexander.kurdas@tum.de'};

%% Load images
load_image = @(file_path) double(imread(file_path)) / 255;

scene_L1 = load_image('L1.jpg');
scene_L2 = load_image('L2.jpg');
scene_R1 = load_image('R1.jpg');
scene_R2 = load_image('R2.jpg');

%% Load precomputed calibration matrices
Ks = load('K');

%% Select transformation scaling factor
p = 0.5;

%% Free Viewpoint Rendering
tic;
scene_V1 = free_viewpoint(scene_L1, scene_R1, Ks.K1, p);
elapsed_time(1) = toc;
tic;
scene_V2 = free_viewpoint(scene_L2, scene_R2, Ks.K2, p);
elapsed_time(2) = toc;

fprintf('The function took %.0fs to execute for the first image pair and %.0fs for the second.\n', elapsed_time(1), elapsed_time(2));

%% Display Output
% Display Virtual View
% Scene 1
figure('name', 'Scene 1');

subplot(1, 3, 1);
imshow(scene_L1);
title('Left View');

subplot(1, 3, 2);
imshow(scene_V1);
title('Virtual View');

subplot(1, 3, 3);
imshow(scene_R1);
title('Right View');

% Scene 2
figure('name', 'Scene 2');

subplot(1, 3, 1);
imshow(scene_L2);
title('Left View');

subplot(1, 3, 2);
imshow(scene_V2);
title('Virtual View');

subplot(1, 3, 3);
imshow(scene_R2);
title('Right View');
