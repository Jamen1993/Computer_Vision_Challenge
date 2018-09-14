function [q_out] = quatslerp(q_1,q_2,f)
%QUATSLERP interpoliert linear zwischen zwei Orientierungen, repräsentiert
%   als Quaternionen
%   entspricht quatinterp(q_1,q_2,f,'slerp') aus Aerospace Toolbox
%   Inputs:
%   q_1:   Start Orientierung als Quaternion
%   q_2:   End Orientierung als Quaternion
%   f:     Faktor zwischen 0 (entspricht q_1) und 1 (entspricht q_2)
%   Outputs: 
%   q_out: Ausgabe Orientierung als Quaternion

%% Input prüfen
if ~(isquat(q_1))
    error('quatslerp: q_1 nicht korrekt! (1x4 & Nicht [0 0 0 0])')
end
if ~(isquat(q_2))
    error('quatslerp: q_2 nicht korrekt! (1x4 & Nicht [0 0 0 0])')
end
if ~(isnumeric(f) && isscalar(f) && f>=0 && f<=1)
    error('quatslerp: f nicht korrekt! (Numerisch & Skalar & [0,1])')
end

%% Normieren falls nötig
threshold = 10e-12;
if abs(sqrt(q_1*q_1')-1)>threshold
    q_1 = quatnormalizeAlex(q_1);
    warning('quatslerp musste Eingabequaternion q_1 erst normalisieren!')
end

if abs(sqrt(q_2*q_2')-1)>threshold
    q_2 = quatnormalizeAlex(q_2);
    warning('quatslerp musste Eingabequaternion q_2 erst normalisieren!')
end

%% slerp
if q_1==q_2 %Start=Ziel => Nur den Punkt ausgeben!
    q_out = q_1;
    warning('Slerp nicht benutzt da Start und Ziel identisch sind!')
    return;
elseif f==0 %f=0 => Startwert ausgeben!
    q_out = q_1;
    return;
elseif f==1 %f=1 => Zielwert ausgeben!
    q_out = q_2;
    return;
else        %Sonst wirklich rechnen!
    
    dot_qq = q_1*q_2';      %cos(Winkel)=q_1 * q_2; da Normierte Quaternionen!
                            %Winkel zwischen 0° und 180° / dot = [1;-1]
    if dot_qq<0             %Verhindern dass der längere Weg genommen wird
        q_1 = -q_1;         %Ist eh die geleiche Rotation!
        dot_qq = -dot_qq;   %Winkel zwischen -90° und +90° / dot = [0;1]
    end  
    
    dot_th = 0.9995;        %Threshold der Winkel um 0° (=> dot ~1) ausschießt
    if dot_qq>dot_th        %Lerp wenn Winkel klein, da sin(Winkel) im Nenner
        q_out = q_1 + f.*(q_2-q_1);         %Lerp: ~Kleinwinkelnäherung
        q_out = quatnormalizeAlex(q_out);   %Normalisieren sonst stimmt's nicht genau
        return;
    end
    
    theta = acos(dot_qq);   %theta ist Winkel zwischen den Orientierungen
                            %Winkel liegt zwischen -90° und +90° ohne ~0°
    q_out = (sin((1-f)*theta)/sin(theta))*q_1 + (sin(f*theta)/sin(theta))*q_2;
                            %normale Slerp Formel
    q_out = quatnormalizeAlex(q_out); %Normalisieren wegen Numerischen Ungenauigkeiten
end

end


