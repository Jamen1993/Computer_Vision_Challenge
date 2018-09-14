function [Result] = isquat(q)
%ISQUAT prüft ob q ein Quaternion ist
%   0 = Keine Quaternion; 1 = Korrektes Quaternion

%% Check q
Result = isnumeric(q) && all((size(q) == [1 4]),2) && any(q);

end

