function [Result] = iseukltrans(M, threshold)
%ISEUKLTRANS prüft ob M eine Euklidische Transformation ist; ggf. mit threshold 
%als Genauigkeit.
%   0 = Keine Euk. Transformation; 1 = Korrekte Euk. Transformation

%% Input prüfen
if nargin == 1
    threshold = 0;
elseif nargin == 2
    
else
    error('iseukltrans: Falsche Anzahl Eingabeparameter!')  
end

%% Check M
Result = isnumeric(M) && all(size(M) == [4 4]) && all(M(4,1:4)==[0 0 0 1]) && isrotm(M(1:3,1:3),threshold);

end

