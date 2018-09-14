function [q_out] = quatconjAlex(q)
%QUATCONJALEX konjugiert Quaternionen q*
%   entspricht quatconj(q) aus Aerospacetoolbox
%   Inputs:
%   q:      Input Quaternion das konjugiert werden soll;
%   Outputs:
%   q_out:  konjugiertes Quaternion;

%% Input prüfen
if ~(isquat(q))
    error('quatconjAlex: q nicht korrekt! (1x4 & Nicht [0 0 0 0])')
end
   
%% Konjugieren
q_out = [q(1) -q(2) -q(3) -q(4)];

end

