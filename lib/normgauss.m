function ret = normgauss(A)
    % Normalise array according to mean and standard deviation.

    ret = (A - mean(A(:))) / std(A(:));
end
