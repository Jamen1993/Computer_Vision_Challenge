function rgimg = rotimg(gimg, phi)
    % Rotate a grayscale image gimg around the angle phi around its centre.
    % The image must be square and with an uneven edge length.

    % Edge length
    l = size(gimg, 1);
    % Indices for edge with centre at zero
    il = -((l - 1) / 2):((l - 1) / 2);

    %% Backward rotation of target grid
    % Pixel position vector grid
    [X, Y] = meshgrid(il);
    ps = [X(:)'
    Y(:)'];
    % Rotate position vectors according to phi
    ps = rot2mat(-phi) * ps;
    % Rebuild position vector grid
    rX = reshape(ps(1, :), l, l);
    rY = reshape(ps(2, :), l, l);
    % Interpolate target grid based on source grid
    rgimg = interp2(X, Y, gimg, rX, rY, 'linear', 0);

    %{

    %% Backward rotation of target grid with extrapolation to fill empty spots
    % Pixel position vector grid
    [rX, rY] = meshgrid(il);
    ps = [rX(:)'
    rY(:)'];
    % Rotate position vectors according to phi
    ps = rot2mat(-phi) * ps;
    % Rebuild position vector grid
    rX = reshape(ps(1, :), l, l);
    rY = reshape(ps(2, :), l, l);
    % Pad image for nearest neighbour extrapolation
    % Image diagonal length
    d = norm(size(gimg));
    pgimg = padding_nn(gimg, ceil((d - l) / 2));
    s = size(pgimg, 1);
    ip = -((s - 1) / 2):((s - 1) / 2);
    [pX, pY] = meshgrid(ip);
    % Interpolate target grid based on source grid
    rgimg = interp2(pX, pY, pgimg, rX, rY, 'linear');

    %}
end

