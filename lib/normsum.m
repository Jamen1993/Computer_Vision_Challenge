function A = normsum(A)
    % Normalise a vector or matrix to a sum of 1.

    A = A / sum(A(:));
end
