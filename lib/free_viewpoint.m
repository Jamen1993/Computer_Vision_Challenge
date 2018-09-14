% @TODO
% Description of input and output arguments

function scene_V = free_viewpoint(scene_L, scene_R, K, p)
    %% Shortcut for corner cases p ≈ 0 and p ≈ 1
    if p < 0.01
        scene_V = scene_L;
        return;
    elseif p > 0.99
        scene_V = scene_R;
        return;
    end

    %% Convert images to grayscale
    gscene_L = rgb2gray(scene_L);
    gscene_R = rgb2gray(scene_R);

    %% Detect features in grayscale images
    find_features = @(gimg) harris(gimg, 7, 0.01, 17, 25, 2);
    % find_features = @(gimg) gftt(gimg, 7, 0.1 , 4, 25, 2);

    fprintf('Detect features in left image');
    features_L = find_features(gscene_L);
    fprintf(' - %d features detected\n', size(features_L, 2));
    fprintf('Detect features in right image');
    features_R = find_features(gscene_R);
    fprintf(' - %d features detected\n', size(features_R, 2));

    % plot_features(gscene_L, features_L);
    % plot_features(gscene_R, features_R);

    %% Match features between images
    % extract_descriptors = @(gimg, features) extract_rotated(gimg, features, 21);
    extract_descriptors = @(gimg, features) extract_sift(gimg, features);

    fprintf('Extract descriptors in left image\n');
    [descriptors_L, features_L] = extract_descriptors(gscene_L, features_L);
    fprintf('Extract descriptors in right image\n');
    [descriptors_R, features_R] = extract_descriptors(gscene_R, features_R);

    fprintf('Match descriptors between both images');
    correspondences = match_ncc(features_L, features_R, descriptors_L, descriptors_R, 0.65);
    % correspondences = match_ssd(features_L, features_R, descriptors_L, descriptors_R, 1.1);
    fprintf(' - %d correspondences established\n', size(correspondences, 2));

    % plot_correspondences(gscene_L, gscene_R, correspondences, false);

    %% Derive robust correspondences with RanSaC method
    assert(length(correspondences) >= 8, 'Eight Point requires at least 8 correspondences');

    fprintf('Derive robust correspondences - ');
    iterations = max(150, 10 * size(correspondences, 2));
    correspondences_robust = F_ransac(correspondences, iterations, 0.1);
    fprintf('%d robust correspondences established\n', size(correspondences_robust, 2));

    % plot_correspondences(gscene_L, gscene_R, correspondences_robust, false);

    assert(length(correspondences_robust) >= 8, 'RanSaC must yield at least 8 correspondences for estimation of F');

    % F = eight_point(correspondences_robust);
    % plot_epipolar_lines(gscene_L, gscene_R, features_L, features_R, F);

    %% Estimate essential Matrix and extract relative camera pose
    E = eight_point(correspondences_robust, K);
    [R, T] = E2RT(E, correspondences_robust, K);

    %% Rectify grayscale images
    fprintf('Rectify images - ');
    [grscene_L, grscene_R, rectinfo] = rectify(gscene_L, gscene_R, K, R, T, correspondences_robust);

    % figure('name', 'Rectified Images');

    % subplot(1, 2, 1);
    % imshow(grscene_L);
    % title('Rectified Scene L');

    % subplot(1, 2, 2);
    % imshow(grscene_R);
    % title('Rectified Scene R');

    %% Stereomatching
    fprintf('Scale down rectified images to 10 %%\n');
    grscene_L = imresize(grscene_L, 0.1);
    grscene_R = imresize(grscene_R, 0.1);

    fprintf('Stereo matching right image')
    dispmap_R = disp_block(grscene_L, grscene_R, 'DisparityRange', 250, 'SearchDirection', 'right', 'BlockSize', 7);
    fprintf('Stereo matching left image')
    dispmap_L = disp_block(grscene_R, grscene_L, 'DisparityRange', 250, 'SearchDirection', 'left', 'BlockSize', 7);

    fprintf('Scale up disparity maps to original size\n');
    depthmap_L = imresize(dispmap_L, 10);
    depthmap_R = imresize(dispmap_R, 10);

    %% Derectify disparity maps
    fprintf('Derectify disparity maps\n');
    [dgimg_1, dgimg_2] = derectify(depthmap_L, depthmap_R, rectinfo);

    % figure('name', 'Derectified Disparity Maps');

    % subplot(2, 2, 1);
    % imshow(gscene_L);
    % title('Scene L');

    % subplot(2, 2, 2);
    % imshow(gscene_R);
    % title('Scene R');

    % subplot(2, 2, 3);
    % imshow(normminmax(-dgimg_1));
    % title('Derectified Disparity Map L');

    % subplot(2, 2, 4);
    % imshow(normminmax(dgimg_2));
    % title('Derectified Disparity Map R');

    %% Convert disparity to depth maps
    dgimg_1a = uint8(normminmax(abs(dgimg_1)) * 254 + 1);
    dgimg_2a = uint8(normminmax(abs(dgimg_2)) * 254 + 1);

    depth_L = disp2depth(dgimg_1a,K,T);
    depth_R = disp2depth(dgimg_2a,K,T);

    %% Render virtual view
    M = RT2M(R, T, 1e-6);
    [scene_V,depth_V] = multiimwarp(scene_L, depth_L, scene_R, depth_R, M, p, K, 'dilRadius', 7, 'eroRadius', 11, 'depthThreshold', 10, 'debug', false);

    % Occlusion filling:
    scene_V = antiNan(scene_V,depth_V);
    %scene_V = nan2color(scene_V,[255 0 0]); %Markiert Nan-Werte mit Farbe
end
