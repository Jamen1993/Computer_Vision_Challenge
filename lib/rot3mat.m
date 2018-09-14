function R = rot3mat(phix, phiy, phiz)
    % 3D rotation around all axis in sequence x, y, z.
    R = rotzmat(phiz) * rotymat(phiy) * rotxmat(phix);
end
