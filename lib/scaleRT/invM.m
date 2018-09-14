function [invM] = invM(M)
%INVM gibt die inverse transformation zu M aus
%   Inputs:
%   M:          Euklidische Transformationsmatrix
%   Outputs:
%   invM:         skalierte Transformation vom Usprung aus

%% Input prüfen
threshold = 10e-5; %Falls die Prüfungen fehlschlagen wegen Num. Ungenauigkeit!
if nargin == 1
    if ~(iseukltrans(M, threshold))
        error('InvM: M nicht korrekt! (4x4 & [R T;0 0 0 1])')
    end
    [R,T]=M2RT(M, threshold);
else
    error('InvM: Falsche Anzahl Eingabeparameter!')    
end

%% T invertieren
invT = -T;

%% R invertieren
q_r = rotm2quatAlex(R, threshold);
q_inv = quatinvAlex(q_r);
invR = quat2rotmAlex(q_inv, threshold);

%% Output
if nargout == 1 || nargout == 0
    invM = RT2M(invR, invT, threshold);
else
    error('InvM: Falsche Anzahl Ausgabeparameter!')     
end

