function [Result] = isrotm(R, threshold)
%ISROTM prüft ob R eine Rotationsmatrix ist; ggf. mit threshold als
%Genauigkeit.
%   0 = Keine Rotationsmatrix; 1 = Korrekte Rotationsmatrix

%% Input prüfen
if nargin == 1
    threshold = 0;
elseif nargin == 2
    
else
    error('isrotm: Falsche Anzahl Eingabeparameter!')  
end

%% Check R
Result = isnumeric(R) && all(size(R) == [3 3]) && abs(det(R)-1)<=threshold && all(all(abs((R'*R)-eye(3))<=threshold),2);

end

