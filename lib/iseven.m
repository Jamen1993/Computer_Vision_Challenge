function ret = iseven(a)
    % Check if an integer is even

    ret = ~logical(mod(a, 2));
end
