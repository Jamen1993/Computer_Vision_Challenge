function plot_epipolar_lines(gimg_1, gimg_2, features_1, features_2, F)
    % Plot features and their epipolar lines in the other image

    % Number of features to plot epipolar lines for
    nfeatures = 6;
    % Select a random subset of the features
    features_1 = features_1(:, randperm(size(features_1, 2), nfeatures));
    features_2 = features_2(:, randperm(size(features_2, 2), nfeatures));
    % Epipolar lines
    % li can be interpreted as parameters [a b c] for a straight line equation in homogenous form a * x + b * y + c = 0 and points on this line can be computed accordingly.
    l1 = F' * to_hom(features_2);
    l2 = F * to_hom(features_1);

    s = size(gimg_1);

    % Compute outmost left and right points on li
    x = [0; s(2)];
    y1 = (-l1(1, :) .* x - l1(3, :)) ./ l1(2, :);
    y2 = (-l2(1, :) .* x - l2(3, :)) ./ l2(2, :);
    % Style options for plots
    style = ["g", "r", "c", "m", "y", "w"];
    % Build one big image for better axes occupancy
    gimg = [gimg_1 gimg_2];

    figure('name', 'Image 1');
    imshow(gimg);
    hold on;
    for it = 1:nfeatures
        plot(features_1(1, it), features_1(2, it), style(it) + "o");
        plot(x + s(2), y2(:, it), style(it));
    end
    hold off;
    title('Features and associated Epipolar Lines left to right');

    figure('name', 'Image 2');
    imshow(gimg);
    hold on;
    for it = 1:nfeatures
        plot(features_2(1, it) + s(2), features_2(2, it), style(it) + "o");
        plot(x, y1(:, it), style(it));
    end
    hold off;
    title('Features and associated Epipolar Lines right to left');
end
