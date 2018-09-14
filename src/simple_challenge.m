%% Computer Vision Challenge

envsetup;
close all;

% Groupnumber:
group_number = 25;

% Groupmembers:
% members = {'Max Mustermann', 'Johannes Daten'};
members = {'Thomas Brenner', 'Simon Diehl', 'Matthias Donderer', 'Alexander Kurdas'};

% Email-Adress (from Moodle!):
% mail = {'ga99abc@tum.de', 'daten.hannes@tum.de'};
mail = {'thomas.brenner@tum.de', 'simon.diehl@tum.de', 'matthias.donderer@tum.de', 'alexander.kurdas@tum.de'};

%% Load images
load_image = @(file_path) double(imread(file_path)) / 255;

scene_L1 = load_image('images/L1.jpg');
scene_L2 = load_image('images/L2.jpg');
scene_R1 = load_image('images/R1.jpg');
scene_R2 = load_image('images/R2.jpg');

% Load prepared correspondences and camera parameters
data_1 = load('Pair_1');
data_2 = load('Pair_2');

%% Free Viewpoint Rendering
tic;
scene_V1 = simple_free_viewpoint(scene_L1, scene_R1, data_1.K, data_1.correspondences, 0.5);
elapsed_time = toc;

tic;
scene_V2 = simple_free_viewpoint(scene_L2, scene_R2, data_2.K, data_2.correspondences, 0.5);
elapsed_time = [elapsed_time toc];

elapsed_time = mean(elapsed_time);

%% Display Output
% Display Virtual View
% Scene 1
% figure('name', 'Scene 1');

% subplot(1, 3, 1);
% imshow(scene_L1);
% title('Left View');

% subplot(1, 3, 2);
% imshow(scene_V1);
% title('Virtual View');

% subplot(1, 3, 3);
% imshow(scene_R1);
% title('Right View');

% figure('name', 'Virtual View 1');
% imshow(scene_V1);

% Scene 2
% figure('name', 'Scene 2');

% subplot(1, 3, 1);
% imshow(scene_L2);
% title('Left View');

% subplot(1, 3, 2);
% imshow(scene_V2);
% title('Virtual View');

% subplot(1, 3, 3);
% imshow(scene_R2);
% title('Right View');

% figure('name', 'Virtual View 2');
% imshow(scene_V2);
