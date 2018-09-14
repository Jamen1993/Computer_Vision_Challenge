%% Script for testing of image rectification

close all
clear all
clc

%% Load images
load_image = @(file_path) double(imread(file_path)) / 255;
IL = load_image('../images/L1.jpg');
IR = load_image('../images/R1.jpg');
ILgray = rgb2gray(IL);
IRgray = rgb2gray(IR);

%% load E and F matrices
%load('../../EF_pair_2.mat');

%% Load camera matrix (intrinsic camera parameters)
load('../../calibration/K.mat');

%% Estimate transformation between camera frames
% (rotation R and translation T)

addpath('../lib/'); % challenge lib
addpath('../lib/rectification/'); % challenge lib

% Find feature points and calculate E matrix and extrinsic camera
% parameters R and T

find_features = @(gimg) harris(gimg, 7, 0.03, 0.01, 4, 25, 2);
% find_features = @(gimg) gftt(gimg, 7, 0.1 , 4, 25, 2);

features_L = find_features(ILgray);
features_R = find_features(IRgray);

% plot_features(gscene_L, features_L);
% plot_features(gscene_R, features_R);

% [descriptors_L, features_L] = extract_normalised(gscene_L, features_L, 21);
% [descriptors_R, features_R] = extract_normalised(gscene_R, features_R, 21);

[descriptors_L, features_L] = extract_sift(ILgray, features_L);
[descriptors_R, features_R] = extract_sift(IRgray, features_R);

% correspondences = match_cc(features_L, features_R, descriptors_L, descriptors_R, 0.95);
correspondences = match_ncc(features_L, features_R, descriptors_L, descriptors_R, 0.65);

% plot_correspondences(gscene_L, gscene_R, correspondences, false);

assert(length(correspondences) >= 8, 'Eight Point requires at least 8 correspondences');

correspondences_robust = F_ransac(correspondences, 100, 0.99);

% plot_correspondences(ILgray, IRgray, correspondences_robust, false);

assert(length(correspondences_robust) >= 8, 'RanSaC must yield at least 8 correspondences for estimation of F');

F = eight_point(correspondences_robust);
E = eight_point(correspondences_robust, K);

[R, T] = E2RT(E, correspondences_robust, K);

%% Rectify images
[JL, JR, TL, TR] = rectifyImages( IL, IR, K, R, T );

%% Plot images before and after rectification

% number of features that are plotted. Must not be bigger than the total
% number of features
numFeatures = 4;

% find the smallest bb containining both images
bb = mcbb(size(IL),size(IR), TL, TR);
% Calculate bbL
[~,bbL,~] = imwarp(IL(:,:,1), TL, 'bilinear', bb);

figure;
% plot left view
subplot(2,2,1);
image(IL);
axis image
title('Left image');
hold on
plot(correspondences(1,1:numFeatures), correspondences(2,1:numFeatures),'w+','MarkerSize',12);
hold off

% plot right view
subplot(2,2,2);
image(IR);
axis image
title('Right image');
% plot epipolar lines
x1 =0;
x2 = size(IR,2);
hold on
for i =1:numFeatures
    liner = F * [correspondences(1:2,i) ; 1];
    plotseg(liner,x1,x2);
end
hold off

% warp matched points
correspondences(1:2,:) = p2t(TL,correspondences(1:2,:));
correspondences(3:4,:) = p2t(TL,correspondences(3:4,:));

% plot left view after rectification
subplot(2,2,3)
image(JL);
axis image
title('Rectified left image');
x2 = size(JL,2);
hold on
for i =1:numFeatures
    plot (correspondences(1,i)-bbL(1), correspondences(2,i)-bbL(2),'w+','MarkerSize',12);
end
hold off

% plot right view after rectification
subplot(2,2,4)
image(JR);
axis image
title('Rectified right image')
x2 = size(JR,2);
hold on
for i =1:numFeatures
    liner = star([1 0 0])  * [correspondences(1:2,i) - bbL(1:2) ;  1];
    plotseg(liner,x1,x2);
end
hold off
