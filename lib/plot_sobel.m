function plot_sobel(gimg)
    % Plot edge image of grayscale image gimg.

    [Ix, Iy] = sobel(gimg);
    % Combine horizontal and vertical gradient as common gradient metric
    Ixy = Ix + Iy;
    % Normalise Ixy to 0 to 1 with zero gradient at 0.5
    Ixy(Ixy >= 0) = normminmax(Ixy(Ixy >= 0)) / 2 + 0.5;
    Ixy(Ixy <= 0) = normminmax(Ixy(Ixy <= 0)) / 2;

    figure('name', 'Edge Image');
    imshow(Ixy, 'InitialMagnification', 'fit');
end
