function [rgimg_1, rgimg_2, rectinfo] = rectify(gimg_1, gimg_2, K, R, T, correspondences)
    % Rectify two grayscale images with respect to K, R and T as described by Morvan.
    % The camera frames are parallel to the camera baseline after rectification.

    % Construct R' as described by Morvan and other sources to rotate camera 1 parallel to the baseline. R1 is eye(3) and thus equals R' after rectification.
    rx = -T';
    ry = cross([0 0 1], rx);
    rz = cross(rx, ry);

    Rp = normnorm([rx; ry; rz]);
    % Optimise rectification transformations for minimum y-axis shift between correspondences.
    % This procedure is not motivated by geometrical considerations and can even counteract the original intention of rectification (to move the epipoles towards infinity) but it always gave better results than the initial R'.
    x1 = to_hom(correspondences(1:2, :));
    x2 = to_hom(correspondences(3:4, :));

    function [H1, H2] = make_transformations(theta)
        Rpn = rot3mat(theta(1), theta(2), theta(3));

        H1 = K * Rpn     / K;
        H2 = K * Rpn / R / K;
    end

    function c = cost_function(theta)
        [H1n, H2n] = make_transformations(theta);

        x1h = from_hom(H1n * x1);
        x2h = from_hom(H2n * x2);

        % c = median((x1h(2, :) - x2h(2, :)) .^ 2);
        % c = median(abs((x1h(2, :) - x2h(2, :))));
        c = mean((x1h(2, :) - x2h(2, :)) .^ 2);
        % c = mean(abs(x1h(2, :) - x2h(2, :)));
    end
    % Initial parameter set from calculated R'
    [phix, phiy, phiz] = invrot3mat(Rp);
    theta0 = [phix(2) phiy(2) phiz(2)];

    options = optimset('Display', 'off');
    theta = fminsearch(@cost_function, theta0, options);

    [H1, H2] = make_transformations(theta);

    % Bounding boxes of both images
    bb_1 = bounding_box(gimg_1, H1);
    bb_2 = bounding_box(gimg_2, H2);
    % Find largest bounding box
    w = max([bb_1(2) bb_2(2)]);
    h = max([bb_1(1) bb_2(1)]);

    fprintf('Size of rectified images is %d x %d\n', h, w);
    assert(w <= 5e3 && h <= 5e3, sprintf('Bounding box is to large (%d x %d). The matched correspondences are probably bad. Try again!', h, w));

    miny = min([bb_1(3) bb_2(3)]);
    % Update rectifying transforms with origin shift.
    % Shift both images as far to the left as possible but keep their vertical alignment.
    T1 = [1 0 (-bb_1(4) + 1)
          0 1 -miny
          0 0   1           ];
    T2 = [1 0 (-bb_2(4) + 1)
          0 1 -miny
          0 0   1           ];

    rectinfo.s = size(gimg_1);

    rectinfo.H1 = T1 * H1;
    rectinfo.H2 = T2 * H2;

    % Positional vectors of target size
    [X, Y] = meshgrid(1:w, 1:h);
    XY = to_hom([X(:)'
                 Y(:)']);

    rectinfo.bb_1 = bounding_box(gimg_1, rectinfo.H1);
    rectinfo.bb_2 = bounding_box(gimg_2, rectinfo.H2);

    % Positional vectors of target size
    [X, Y] = meshgrid(1:w, 1:h);
    XY = to_hom([X(:)'
                 Y(:)']);

    function rgimg = backwards_warp(gimg, H)
        % Backwards warp and interpolate with gimg's intensities and rectifying transform H.

        % Backwards warp target positional vectors
        hXY = from_hom(H \ XY);
        % Interpolate intensity from source image
        s = size(gimg);

        rgimg = reshape(interp2(1:s(2), 1:s(1), gimg, hXY(1, :), hXY(2, :), 'linear', 0), h, w);
    end

    rgimg_1 = backwards_warp(gimg_1, rectinfo.H1);
    rgimg_2 = backwards_warp(gimg_2, rectinfo.H2);
end

function bb = bounding_box(gimg, H)
    % Find bounding box [h w miny minx] of image gimg with homography transform H.

    s = size(gimg);

    % Edge positional vectors [x; y] in pixel coordinates from top left to top right in mathematically positive counting
    pvs = [1   1  s(2) s(2)
           1 s(1) s(1)   1 ];
    % Forward warp to find bounding box
    pvs = from_hom(H * to_hom(pvs));
    % Find outermost coordinates in x and y directions
    minx = floor(min(pvs(1, :)));
    maxx = ceil(max(pvs(1, :)));
    miny = floor(min(pvs(2, :)));
    maxy = ceil(max(pvs(2, :)));
    % Find dimensions of warped image
    w = maxx - minx;
    h = maxy - miny;

    bb = [h w miny minx];
end
