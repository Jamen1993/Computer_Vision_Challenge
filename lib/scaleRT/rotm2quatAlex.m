function [q] = rotm2quatAlex(R, threshold)
%ROTM2QUATALEX konvertiert eine Rotationsmatrix zu einem Quaternion;
%   Ggf. mit threshold als Prüfgenauigkeit.
%   entspricht rotm2quat(R) aus Robotics Toolbox
%   Inputs:
%   R: Rotationsmatrix
%   Outputs: 
%   q: Quaternion

%% Input prüfen
if nargin == 1
    threshold = 0;
elseif nargin == 2
    
else
    error('rotm2quatAlex: Falsche Anzahl Eingabeparameter!')  
end
if ~(isrotm(R, threshold))
    error('rotm2quatAlex: R nicht korrekt! (3x3 & Det=1 & orthonormale Spalten)')
end
   
%% Konvertieren
q=zeros(1,4);
if (R(1,1) + R(2,2) + R(3,3)) > 0
  s = sqrt(1 + R(1,1) + R(2,2) + R(3,3)) * 2;
  q(1,1) = 0.25 * s;
  q(1,2) = (R(3,2) - R(2,3)) / s;
  q(1,3) = (R(1,3) - R(3,1)) / s; 
  q(1,4) = (R(2,1) - R(1,2)) / s; 
elseif (R(1,1) > R(2,2)) && (R(1,1) > R(3,3))
  s = sqrt(1 + R(1,1) - R(2,2) - R(3,3)) * 2;
  q(1,1) = (R(3,2) - R(2,3)) / s;
  q(1,2) = 0.25 * s;
  q(1,3) = (R(1,2) + R(2,1)) / s; 
  q(1,4) = (R(1,3) + R(3,1)) / s; 
elseif (R(2,2) > R(3,3))
  s = sqrt(1 + R(2,2) - R(1,1) - R(3,3)) * 2;
  q(1,1) = (R(1,3) - R(3,1)) / s;
  q(1,2) = (R(1,2) + R(2,1)) / s; 
  q(1,3) = 0.25 * s;
  q(1,4) = (R(2,3) + R(3,2)) / s; 
else
  s = sqrt(1 + R(3,3) - R(1,1) - R(2,2)) * 2;
  q(1,1) = (R(2,1) - R(1,2)) / s;
  q(1,2) = (R(1,3) + R(3,1)) / s;
  q(1,3) = (R(2,3) + R(3,2)) / s;
  q(1,4) = 0.25 * s;
end

q = quatnormalizeAlex(q);

end