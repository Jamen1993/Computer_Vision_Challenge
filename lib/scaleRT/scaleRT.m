function [ varargout ] = scaleRT(f, RM, T)
%SCALERT skaliert R und T mit Faktor f;
%Statt R&T kann auch M angegeben werden; 
%Genauso kann R&T oder M ausgegeben werden;
%T wird mit f multipliziert;
%Auf R wird ein Slerp-Algorithmus angewand;
%   Inputs:
%   f:          Skalierungsfaktor zwischen 0 und 1
%   RM:         Rotationsmatrix oder Euklidische Transformationsmatrix
%   T:          Translationsvektor (Muss bei M wegelassen werden)
%   Outputs:
%   M_f:        skalierte Transformation
%   [R_f, T_f]: skalierte Rotationsmatrix & Translationsvektor

%% Input prüfen
threshold = 10e-5; %Falls die Prüfungen fehlschlagen wegen Num. Ungenauigkeit!
if nargin == 3
    if ~(isnumeric(f) && isscalar(f) && f>=0 && f<=1)
        error('ScaleRT: f nicht korrekt! (Numerisch & Skalar & [0,1])')
    end
    if ~(isrotm(RM, threshold))
        error('ScaleRT: R nicht korrekt! (3x3 & Det=1 & orthonormale Spalten)')
    end
    if ~(isnumeric(T) && all(size(T) == [3 1]))
        error('ScaleRT: T nicht korrekt! (Numerisch & 3x1)')
    end
    R=RM;
elseif nargin == 2
    if ~(isnumeric(f) && isscalar(f) && f>=0 && f<=1)
        error('ScaleRT: f nicht korrekt! (Numerisch & Skalar & [0,1])')
    end
    if ~(iseukltrans(RM, threshold))
        error('ScaleRT: M nicht korrekt! (4x4 & [R T;0 0 0 1])')
    end
    [R,T]=M2RT(RM, threshold);
else
    error('ScaleRT: Falsche Anzahl Eingabeparameter!')    
end

%% T skalieren
T_f = T.*f;

%% R skalieren
q_r = rotm2quatAlex(R, threshold);
q_0 = [1 0 0 0]; %=Nullrotation!
q_f = quatslerp(q_0,q_r,f);
R_f = quat2rotmAlex(q_f, threshold);

%% Output
if nargout == 1 || nargout == 0
    varargout{1} = RT2M(R_f, T_f, threshold);
elseif nargout == 2
    varargout{1} = R_f;
    varargout{2} = T_f;
else
    error('ScaleRT: Falsche Anzahl Ausgabeparameter!')     
end

