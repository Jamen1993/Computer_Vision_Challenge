function ret = or_reduce(A, dim)
    % Reduce a Matrix along dimension dim using logical or.

    ret = logical(sum(A, dim));
end
