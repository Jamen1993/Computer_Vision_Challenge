function [M] = RT2M(R, T, threshold)
%RT2M fasst R und T zu M zusammen; ggf. mit threshold als Prüfgenauigkeit.

%% Input prüfen
% if nargin == 2
%     threshold = 0;
% elseif nargin == 3
%     
% else
%     error('RT2M: Falsche Anzahl Eingabeparameter!')  
% end
% if ~(isrotm(R, threshold))
%     error('RT2M: R nicht korrekt! (3x3 & Det=1 & orthonormale Spalten)')
% end
% if ~(isnumeric(T) && all(size(T) == [3 1]))
%     error('RT2M: T nicht korrekt! (Numerisch & 3x1)')
% end

%% Zusammenbau
M = [R T;0 0 0 1];

end

