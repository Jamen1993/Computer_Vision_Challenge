function R = crossmat(a)
    % Matrix equivalent to cross product operator.
    %
    % cross(a, b) becomes crossmat(a) * b where b is a tall vector.
    R = [ 0    -a(3)  a(2)
          a(3)  0    -a(1)
         -a(2)  a(1)  0   ];
end
