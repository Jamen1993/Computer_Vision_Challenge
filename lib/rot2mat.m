function R = rot2mat(phi)
    % 2D rotation matrix
    R = [cos(phi) -sin(phi)
         sin(phi)  cos(phi)];
end
