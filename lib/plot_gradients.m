function plot_gradients(gimg)
    % Plot gradient (blue) for each pixel of a grayscale image, center-weighted main gradient (red) and gradient for each pixel inversely rotated by main gradients angle (yellow).

    [Ix, Iy] = sobel(gimg);

    % Image
    figure('name', 'Gradients');
    imshow(gimg, 'InitialMagnification', 'fit');

    % Gradients
    I = [Ix(:)'
         Iy(:)'];

    Ix = reshape(I(1, :), size(Ix));
    Iy = reshape(I(2, :), size(Iy));

    l = length(gimg);
    [X, Y] = meshgrid(1:l, 1:l);

    hold on;
    % Important: imshow inverts y-axis (down positive, up negative) which needs to be considered in quiver plots!
    quiver(X, Y, Ix, Iy, 0.5);

    w = hamming_window(l);
    W = w' * w;
    W = W / sum(W(:));

    G11 = sum(stackmat(Ix .^  2 .* W));
    G12 = sum(stackmat(Ix .* Iy .* W));
    G22 = sum(stackmat(Iy .^  2 .* W));

    G = [G11 G12
         G12 G22];

    [V, D] = eig(G);
    [~, is] = max(diag(D));

    V = V(:, is);

    quiver((l + 1) / 2, (l + 1) / 2, V(1), V(2), 0.5, 'LineWidth', 2);

    % Gradients rotated by main angle
    main_angle = atan2(V(2), V(1));

    R = rot2mat(-main_angle);
    I = R * I;

    Ix = reshape(I(1, :), size(Ix));
    Iy = reshape(I(2, :), size(Iy));

    quiver(X, Y, Ix, Iy, 0.5);
end
