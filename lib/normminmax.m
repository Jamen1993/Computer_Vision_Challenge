function ret = normminmax(A)
    % Norm matrix to min 0 and max 1.

    minA = min(A(:));
    ret = (A - minA) ./ (max(A(:)) - minA);
end
