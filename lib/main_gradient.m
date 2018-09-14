function [Ix, Iy] = main_gradient(gimg, Ix, Iy)
    % Calculate main gradient for a quadratic grayscale image.

    if nargin == 1
        [Ix, Iy] = sobel(gimg);
    end

    % Hamming window
    h = hamming_window(length(gimg));
    H = normsum(h' * h);
    % Eigen vector to greatest eigenvalue of Harris matrix has direction of main gradient
    G11 = sum(stackmat(Ix .^  2 .* H));
    G12 = sum(stackmat(Ix .* Iy .* H));
    G22 = sum(stackmat(Iy .^  2 .* H));

    G = [G11 G12
         G12 G22];

    [V, D] = eig(G);
    [~, is] = max(diag(D));

    Ix = V(1, is);
    Iy = V(2, is);
end
