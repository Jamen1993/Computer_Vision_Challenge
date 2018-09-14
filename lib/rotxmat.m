function R = rotxmat(phi)
    % 3D rotation around x-axis
    R = [1    0         0
         0 cos(phi) -sin(phi)
         0 sin(phi)  cos(phi)];
end
