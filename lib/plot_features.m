function plot_features(gimg, features)
    figure;
    imshow(gimg);
    hold on;
    plot(features(1, :), features(2, :), 'go');
end
