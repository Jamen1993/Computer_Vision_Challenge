function [phix, phiy, phiz] = invrot3mat(R)
    % Recover euler angles from 3D rotation matrix with rotation sequence x, y, z.

    if feq(R(3, 1), 1)
        phiz = 0;
        phiy = -pi / 2;
        phix = -phiz + atan2(-R(1, 2), -R(1, 3));
    elseif feq(R(3, 1), -1)
        phiz = 0;
        phiy = pi / 2;
        phix = phiz + atan2(R(1, 2), R(1, 3));
    else
        phiy(1) = -asin(R(3, 1));
        phiy(2) = pi - phiy(1);

        phix(1) = atan2(R(3, 2) / cos(phiy(1)), R(3, 3) / cos(phiy(1)));
        phix(2) = atan2(R(3, 2) / cos(phiy(2)), R(3, 3) / cos(phiy(2)));

        phiz(1) = atan2(R(2, 1) / cos(phiy(1)), R(1, 1) / cos(phiy(1)));
        phiz(2) = atan2(R(2, 1) / cos(phiy(2)), R(1, 1) / cos(phiy(2)));
    end
end
