function A = normnorm(A)
    % Normalise a vector or matrix A by its L2 norm.

    A = A ./ vecnorm(A);
end
