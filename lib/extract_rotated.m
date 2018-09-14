function [desriptors, features] = extract_rotated(gimg, features, window_size)
    % Extract the feature descriptors where the image windows main gradient is rotated to 0 rad to gain rotation invariance.

    % Window diagonal length
    % The windows will be rotated to normalise them with respect to their main gradient. This rotation requires larger window size than specified so that every grid position in the rotated image has a valid intensity value. Call it outer window.
    dl = ceil(sqrt(2 * window_size ^ 2));
    if iseven(dl)
        dl = dl + 1;
    end
    % Image size in form [x; y]
    imgs = flip(size(gimg))';
    % Required margin between image margin and outer features
    % Features that lie closer to the image margin than half the width of the outer window edge length can't be used because the window would extend beyond the image margin.
    m = (dl - 1) / 2;
    % Mask features that lie to close to the image margin and remove them from the list
    mask = features <= m | features > imgs - m;
    mask = or_reduce(mask, 1);
    features(:, mask) = [];
    % Number of elements in window
    nelements = window_size ^ 2;
    % Windowing indices for outer window
    iow = -m:m;
    % Windowing indices for inner window
    iiw = (window_size - 1) / 2;
    iiw = (-iiw:iiw) + m + 1;
    % Initialise descriptor matrix
    desriptors = zeros(nelements, size(features, 2));
    % for each feature
    for it = 1:length(features)
        % Translate windowing so that the feature is in the centre of the window
        ix = iow + features(1, it);
        iy = iow + features(2, it);
        % Retrieve window around feature and rotate the main gradient to 0 rad
        W = gimg(iy, ix);
        [Ix, Iy] = main_gradient(W);
        main_angle = atan2(Iy, Ix);
        W = rotimg(W, -main_angle);
        % Extract the inner window, stack it to form the feature descriptor and store it in the descriptor matrix
        desriptors(:, it) = stackmat(W(iiw, iiw));
    end
end
