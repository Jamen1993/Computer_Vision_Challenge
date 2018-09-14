function R = rotymat(phi)
    % 3D rotation around y-axis
    R = [ cos(phi) 0 sin(phi)
             0     1    0
         -sin(phi) 0 cos(phi)];
end
