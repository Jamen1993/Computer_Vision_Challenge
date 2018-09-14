function [q_out] = quatinvAlex(q)
%QUATINVALEX invertiert Quaternionen q^-1
%   entspricht quatinv(q) aus Aerospacetoolbox
%   Inputs:
%   q:      Input Quaternion das invertiert werden soll;
%   Outputs:
%   q_out:  invertiertes Quaternion;

%% Input prüfen
if ~(isquat(q))
    error('quatinvAlex: q nicht korrekt! (1x4 & Nicht [0 0 0 0])')
end
   
%% Invertieren
q_out = quatconjAlex(q)./(q*q');

end

