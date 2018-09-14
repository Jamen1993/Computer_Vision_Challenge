function sd = sampson_dist(FE, x1, x2, K)
    % Calculate Sampson distance between x1 and x2 using a fundamental or essential matrix FE and calibration matrix K. x1 and x2 must be calibrated beforehand if K is given.

    K_given = (nargin == 4);

    % Crossproduct matrix to third base vector e3 = [0 0 1]
    E3_hat = crossmat([0 0 1]);
    % Numerator
    num = diag(x2' * FE * x1) .^ 2;
    % Nenner der Sampson-Distanz
    if K_given
        % Denominator
        % Left term
        denlt = sum((E3_hat * (K' \ FE) * x1) .^ 2, 1);
        % Right term
        denrt = sum((x2' * FE * (K \ E3_hat)) .^ 2, 2);
    else
        denlt = sum((E3_hat * FE * x1) .^ 2, 1);
        denrt = sum((x2' * FE * E3_hat) .^ 2, 2);
    end
    % Combine
    den = denlt' + denrt;
    % Sampson distance
    sd = (num ./ den)';
end
