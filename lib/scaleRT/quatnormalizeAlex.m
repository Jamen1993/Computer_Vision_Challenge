function [q_out] = quatnormalizeAlex(q)
%QUATNORMALIZEALEX normalisiert Quaternionen
%   entspricht quatnormalize(q) aus Aerospacetoolbox
%   Inputs:
%   q:      Input Quaternion das normalisiert werden soll;
%   Outputs:
%   q_out:  Normaliesiertes Quaternion; |q| = 1;

%% Input prüfen
if ~(isquat(q))
    error('quatnormalizeAlex: q nicht korrekt! (1x4 & Nicht [0 0 0 0])')
end
   
%% Normalisieren
q_out = q./sqrt(q*q');

end

