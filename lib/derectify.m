function [gimg_1, gimg_2] = derectify(rgimg_1, rgimg_2, rectinfo)
    % Derectify two grayscale images or depthmaps rgimg_1 and rgimg_2 according to the rectinfo of the previous rectification.

    % Positional vectors of target size
    [X, Y] = meshgrid(1:rectinfo.s(2), 1:rectinfo.s(1));
    XY = to_hom([X(:)'
                 Y(:)']);

    function gimg = forward_warp(rgimg, H)
        % Forward warp positional vectors and interpolate intensity or depth values.

        % Forward warp target positional vectors to lookup data in rectified image.
        hXY = from_hom(H * XY);
        % Interpolate data
        s = size(rgimg);

        gimg = reshape(interp2(1:s(2), 1:s(1), rgimg, hXY(1, :), hXY(2, :), 'linear', 0), rectinfo.s(1), rectinfo.s(2));
    end

    gimg_1 = forward_warp(rgimg_1, rectinfo.H1);
    gimg_2 = forward_warp(rgimg_2, rectinfo.H2);
end
