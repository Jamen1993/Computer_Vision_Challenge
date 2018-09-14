% @TODO
% Description of input and output arguments
% Revise comments

function FE = eight_point(correspondences, K)
    % Estimate fundamental matrix from correspondence pairs using the linear eight point algorithm with nonlinear refinement step. Estimate essential matrix if K is given.

    % Check wether K is given
    estimate_E = (nargin == 2);

    lc = length(correspondences);

    function x = prepare_correspondences(x)
        % Prepare correspondence points by converting them into homogenous presentation and calibrating the correspondence position vectors.

        x = to_hom(x);

        if estimate_E
            x = K \ x;
        end
    end

    x1 = prepare_correspondences(correspondences(1:2, :));
    x2 = prepare_correspondences(correspondences(3:4, :));

    % Build coefficient matrix for eight point algorithm
    A = kron(x1, x2);
    % K contains all possible Kronecker products between x1 and x2. Only Kronecker products between x1i and x2i are required though.
    is = (0:(lc - 1)) * lc + (1:lc);
    A = A(:, is)';
    % Calculate first estimate of FE
    [~, ~, V] = svd(A);
    FE = V(:, end);
    FE = reshape(FE, 3, 3);
    % Project FE on space of fundamental or essential matrices
    [U, S, V] = svd(FE);

    if estimate_E
        S = diag([1 1 0]);
    else
        S(3, 3) = 0;
    end

    FE = U * S * V';

    %% Nonlinear refinement according to course book p. 392
    % Determine epipoles from nullspace of FE
    [U, ~, V] = svd(FE);
    e1 = V(:, 3);
    e2 = U(:, 3);
    % Normalise epipoles to -1 in third component
    fh = @(e) e / -e(3);
    e1 = fh(e1);
    e2 = fh(e2);
    % Initial parameters for parameter vector
    % Θ = [f1, f2, α1, β1, f4, f5, α2, β2]
    theta_0 = [FE(1, 1), FE(2, 1), FE(1, 2), FE(2, 2), e1(1), e1(2), e2(1), e2(2)];

    function FE = make_FE(theta)
        f3 = theta(7) * theta(1) + theta(8) * theta(2);
        f6 = theta(7) * theta(3) + theta(8) * theta(4);
        f7 = theta(5) * theta(1) + theta(6) * theta(3);
        f8 = theta(5) * theta(2) + theta(6) * theta(4);
        f9 = theta(5) * theta(7) * theta(1) + theta(5) * theta(8) * theta(2) + theta(7) * theta(6) * theta(3) + theta(6) * theta(8) * theta(4);

        FE = reshape([theta(1) theta(2) f3 theta(3) theta(4) f6 f7 f8 f9], 3, 3);
    end

    function c = cost_function(theta)
        myFE = make_FE(theta);

        if estimate_E
            d = sampson_dist(myFE, x1, x2, K);
        else
            d = sampson_dist(myFE, x1, x2);
        end

        c = sum(d .^ 2);
    end

    options = optimset('Display', 'off');
    theta = fminsearch(@cost_function, theta_0, options);

    FE = make_FE(theta);
end
