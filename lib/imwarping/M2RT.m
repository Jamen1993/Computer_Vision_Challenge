function [R, T] = M2RT(M, threshold)
%M2RT zerlegt M in R und T; ggf. mit threshold als Prüfgenauigkeit.

%% Input prüfen
% if nargin == 1
%     threshold = 0;
% elseif nargin == 2
%     
% else
%     error('M2RT: Falsche Anzahl Eingabeparameter!')  
% end
% 
% if ~(iseukltrans(M, threshold))
%     error('M2RT: M nicht korrekt! (4x4 & [R T;0 0 0 1])')
% end

%% Zerlegung
R = M(1:3,1:3);
T = M(1:3,4);

end

