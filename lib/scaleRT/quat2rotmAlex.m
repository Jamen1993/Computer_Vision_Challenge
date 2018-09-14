function [R] = quat2rotmAlex(q, threshold)
%QUAT2ROTMALEX konvertiert ein Quaternion zu einer Rotationsmatrix
%   Ggf. mit threshold als Prüfgenauigkeit.
%   Am besten ein Normiertes Quaternion benutzen; 
%   Rotationsmatrix kann verrauscht sein, trotz normiertem Quaternion!!
%   entspricht quat2rotm(q) aus Robotics Toolbox
%   Inputs:
%   q: Quaternion
%   Outputs: 
%   R: Rotationsmatrix

%% Input prüfen
if nargin == 1
    threshold = 0;
elseif nargin == 2
    
else
    error('quat2rotmAlex: Falsche Anzahl Eingabeparameter!')  
end
if ~(isquat(q))
    error('quat2rotmAlex: q nicht korrekt! (1x4 & Nicht [0 0 0 0])')
end
   
%% Konvertieren
if abs(sqrt(q*q')-1)>10e-12
    q = quatnormalizeAlex(q);
    warning('quat2rotmAlex musste Eingabequaternion erst normalisieren!')
end

R=zeros(3);
R(1,1)=1-2*q(3)*q(3)-2*q(4)*q(4);
R(1,2)=2*q(2)*q(3)-2*q(4)*q(1);
R(1,3)=2*q(2)*q(4)+2*q(3)*q(1);
R(2,1)=2*q(2)*q(3)+2*q(4)*q(1);
R(2,2)=1-2*q(2)*q(2)-2*q(4)*q(4);
R(2,3)=2*q(3)*q(4)-2*q(2)*q(1);
R(3,1)=2*q(2)*q(4)-2*q(3)*q(1);
R(3,2)=2*q(3)*q(4)+2*q(2)*q(1);
R(3,3)=1-2*q(2)*q(2)-2*q(3)*q(3);

if ~isrotm(R, threshold)
    warning('quat2rotmAlex hat eine zu ungenaue oder falsche Rotationsmatrix berechnet!')
end

end

