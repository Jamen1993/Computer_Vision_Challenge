function non_hom = from_hom(hom)
    % hom must be a tall vector or a matrix of tall vectors

    hom = hom ./ hom(end, :);
    non_hom = hom(1:(end - 1), :);
end
