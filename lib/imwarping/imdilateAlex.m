function [img_out] = imdilateAlex(img_in,d)
%IMDILATEALEX dilation on Grayscale image, with square pattern of size dxd.

r = floor(d/2); % Radius berechnen; eigentlich nur für ungrade zahlen
rs = size(img_in,1); % Anzahl Zeilen
cs = size(img_in,2); % Anzahl Spalten
img_out = img_in; % Ausgabe mal mit den input daten beschreiben
img_work = nan(2*r+rs,2*r+cs); % Arbeits image init mit umlaufendem rand in r breite
img_work(r+1:r+rs,r+1:r+cs) = img_in; % in die mitte davon das input image setzen
for ro=1:rs % alle zeilen
    for co=1:cs % und alle spalten durchgehen
        img_out(ro,co)=max(max(img_work(ro:ro+2*r,co:co+2*r))); % Ausgabe ist das maximum des fensters um das pixel
    end
end

end

