function B = padding2(A, margin_width, padd_with)
    % Add padding to two dimensional matrix A with margin width (padded width). The padding method can either be nearest neighbour 'nn' or 'zeros' or 'ones'

    sA = size(A);

    switch padd_with
    case 'zeros'
        B = [zeros(sA(1), margin_width) A zeros(sA(1), margin_width)];

        sB = size(B);

        B = [zeros(margin_width, sB(2)); B; zeros(margin_width, sB(2))];
    case 'ones'
        B = [ones(sA(1), margin_width) A ones(sA(1), margin_width)];

        sB = size(B);

        B = [ones(margin_width, sB(2)); B; ones(margin_width, sB(2))];
    case 'nn'
        B = [repmat(A(:, 1, :), 1, margin_width) A repmat(A(:, end, :), 1, margin_width)];
        B = [repmat(B(1, :, :), margin_width, 1); B; repmat(B(end, :, :), margin_width, 1)];
        return;
    end
end
