function [Ix, Iy] = scharr(gimg)
    % Qualitative Scharr filter
    %
    % gimg - double grayscale image
    %
    % Ix - Horizontal intensity gradient
    % Iy - Vertical intensity gradient

    % Add padding to gimg to avoid wrong gradient at margin
    gimg = padding_nn(gimg, 1);

    % Qualitative Scharr filter coefficient matrix for horizontal filtering (Sx' for vertical filtering)
    Sx = [ 3 0  -3
          10 0 -10
           3 0  -3];
    % Convolution of image and filter matrix gives image gradients
    Ix = conv2(gimg, Sx, 'valid');
    Iy = conv2(gimg, Sx', 'valid');
end
