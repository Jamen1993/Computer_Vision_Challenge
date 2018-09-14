function ret = vecnorm2(A)
    % Column-wise squared L2-norm of matrix.

    ret = sum(A .^ 2, 1);
end
