function correspondences = manual_correspondences(gimg_1, gimg_2, npoints)
    % Manual selection of corresponding points in two grayscale images.
    %
    % gimg_1 and gimg_2 - grayscale images 1 and 2
    % npoints - Number of correspondences that you want to select
    close all;

    % Now alternately the left and the right image are shown, where you first
    % have to click on a point in the left image and then the corresponding
    % point in the right image. Use left mouse button to select points

    correspondences = zeros(4, npoints);

    for it = 1:npoints
        % Pick point in left image
        imshow(gimg_1);
        % Plot previously selected points
        if it > 1
            hold on;
            plot(correspondences(1, :), correspondences(2, :), 'ro');
        end

        title(['Left image point ', num2str(it), ' of ', num2str(npoints)]);
        button = 0;
        while button ~= 1
            [xl,yl,button] = ginput(1);
        end
        close all;

        % Pick point in right image
        imshow(gimg_2);
        % Plot previously selected points
        if it > 1
            hold on;
            plot(correspondences(3, :), correspondences(4, :), 'ro');
        end

        title(['Right image point ', num2str(it), ' of ', num2str(npoints)]);
        button = 0;
        while button ~= 1
            [xr,yr,button] = ginput(1);
        end
        close all;

        % Save points in correspondence matrix
        correspondences(:, it) = [xl; yl; xr; yr];
    end

    correspondences = round(correspondences); % points have to be integers
end
