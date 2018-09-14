function ret = feq(lhs, rhs, threshold)
    % Test two floats for equality.
    %
    % threshold is optional (default = 1e-6)
    if nargin == 2
        threshold = 1e-12;
    end

    ret = abs(lhs - rhs) <= threshold;
end
