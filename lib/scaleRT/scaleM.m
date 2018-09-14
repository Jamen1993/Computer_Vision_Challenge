function [varargout] = scaleM(f, M)
%SCALEM skaliert M mit Faktor f. M1 ist die transformation vom ursprung aus
% M2 ist die transformation von M aus.
%T wird mit f multipliziert;
%Auf R wird ein Slerp-Algorithmus angewand;
%   Inputs:
%   f:          Skalierungsfaktor zwischen 0 und 1
%   M:          Euklidische Transformationsmatrix
%   Outputs:
%   M1:         skalierte Transformation vom Usprung aus
%   (M2):       skalierte Transformation von M aus

%% Input prüfen
threshold = 10e-5; %Falls die Prüfungen fehlschlagen wegen Num. Ungenauigkeit!
if nargin == 2
    if ~(isnumeric(f) && isscalar(f) && f>=0 && f<=1)
        error('ScaleM: f nicht korrekt! (Numerisch & Skalar & [0,1])')
    end
    if ~(iseukltrans(M, threshold))
        error('ScaleM: M nicht korrekt! (4x4 & [R T;0 0 0 1])')
    end
    [R,T]=M2RT(M, threshold);
else
    error('ScaleM: Falsche Anzahl Eingabeparameter!')    
end

%% T skalieren
T1 = T.*f;
T2 = -(T-T1); %T2 zeigt in die gegenrichtung von T1 !

%% R skalieren
q_r = rotm2quatAlex(R, threshold);
q_0 = [1 0 0 0]; %=Nullrotation!
q1 = quatslerp(q_0,q_r,f);
R1 = quat2rotmAlex(q1, threshold);
q2 = quatmultiplyAlex(q1,quatinvAlex(q_r)); %inverse rotation von q_r aus nach q1
R2 = quat2rotmAlex(q2, threshold);

%% Output
if nargout == 1 || nargout == 0
    varargout{1} = RT2M(R1, T1, threshold);
elseif nargout == 2
    varargout{1} = RT2M(R1, T1, threshold);
    varargout{2} = RT2M(R2, T2, threshold);
else
    error('ScaleM: Falsche Anzahl Ausgabeparameter!')     
end

