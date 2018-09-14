function r = invcrossmat(A)
    % Inverse operation to crossmat
    %
    % Extracts the underlying vector which A is build from.
    r(1) = (A(3, 2) - A(2, 3)) / 2;
    r(2) = (A(1, 3) - A(3, 1)) / 2;
    r(3) = (A(2, 1) - A(1, 2)) / 2;

    r = r';
end
