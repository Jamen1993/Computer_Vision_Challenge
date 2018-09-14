function [q_out] = quatmultiplyAlex(q_1,q_2)
%QUATMULTIPLYALEX multipliziert Quaternionen q_1*q_2
%   entspricht quatmultiply(q,r) aus Aerospacetoolbox
%   Inputs:
%   q_1: Linkes Quaternion
%   q_2: Rechtes Quaternion
%   Outputs:
%   q_out: (Hamilton) Produkt q_1 * q_2

%% Input prüfen
if ~(isquat(q_1))
    error('quatmultiplyAlex: q_1 nicht korrekt! (1x4 & Nicht [0 0 0 0])')
end
if ~(isquat(q_2))
    error('quatmultiplyAlex: q_2 nicht korrekt! (1x4 & Nicht [0 0 0 0])')
end

%% Produkt
q_out = zeros(1,4);
q_out(1)=(q_2(1)*q_1(1)-q_2(2)*q_1(2)-q_2(3)*q_1(3)-q_2(4)*q_1(4));
q_out(2)=(q_2(1)*q_1(2)+q_2(2)*q_1(1)-q_2(3)*q_1(4)+q_2(4)*q_1(3));
q_out(3)=(q_2(1)*q_1(3)+q_2(2)*q_1(4)+q_2(3)*q_1(1)-q_2(4)*q_1(2));
q_out(4)=(q_2(1)*q_1(4)-q_2(2)*q_1(3)+q_2(3)*q_1(2)+q_2(4)*q_1(1));

end

