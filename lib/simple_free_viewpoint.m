% @TODO
% Description of input and output arguments

function scene_V = simple_free_viewpoint(scene_L, scene_R, K, correspondences, p)
    % Dummy virtual view
    scene_V = [];

    gscene_L = rgb2gray(scene_L);
    gscene_R = rgb2gray(scene_R);

    plot_correspondences(gscene_L, gscene_R, correspondences, false);

    % corr_robust = F_ransac(correspondences, 0.5, 0.99, 1, true);

    % plot_correspondences(gscene_L, gscene_R, correspondences_robust, false);

    F = eight_point(correspondences, true);
    E = K' * F * K;

    [R, T] = E2RT(E, correspondences, K);

    [rscene_L, rscene_R, TL, TR] = rectifyImages(uint8(scene_L * 255), uint8(scene_R * 255), K, R, T);

    rscene_L = double(rscene_L) / 255;
    rscene_R = double(rscene_R) / 255;

    grscene_L = rgb2gray(rscene_L);
    grscene_R = rgb2gray(rscene_R);

    % imwrite(rscene_L, 'rscene_L.png');
    % imwrite(rscene_R, 'rscene_R.png');

    %% Plot rectified images
    figure('name', 'Rectified Images');

    subplot(2, 2, 1);
    imshow(gscene_L);
    title('Scene L');

    subplot(2, 2, 2);
    imshow(grscene_L);
    title('Rectified Scene L');

    subplot(2, 2, 3);
    imshow(gscene_R);
    title('Scene R');

    subplot(2, 2, 4);
    imshow(grscene_R);
    title('Rectified Scene R');
end
