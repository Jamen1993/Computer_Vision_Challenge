function hom = to_hom(non_hom)
    % non_hom must be a tall vector or a matrix of tall vectors

    hom = [non_hom
           ones(1, size(non_hom, 2))];
end
