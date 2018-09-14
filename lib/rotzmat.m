function R = rotzmat(phi)
    % 3D rotation around z-axis
    R = [cos(phi) -sin(phi) 0
         sin(phi)  cos(phi) 0
            0         0     1];
end
