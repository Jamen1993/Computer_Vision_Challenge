function [Ix, Iy] = sobel(gimg)
    % Qualitative Sobel filter
    %
    % gimg - double grayscale image
    %
    % Ix - Horizontal intensity gradient
    % Iy - Vertical intensity gradient

    % Add padding to gimg to avoid wrong gradient at margin
    gimg = padding2(gimg, 1, 'nn');

    % Qualitative Sobel filter coefficient matrix for horizontal filtering (Sx' for vertical filtering)
    % Gradient is positive towards higher intensities
    Sx = [1 0 -1
          2 0 -2
          1 0 -1];
    % Convolution of image and filter matrix gives image gradients
    Ix = convn(gimg, Sx, 'valid');
    Iy = convn(gimg, Sx', 'valid');
end
