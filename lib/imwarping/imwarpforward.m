function [varargout] = imwarpforward(Bild,Tiefen,M,K,varargin)
%IMWARPFORWARD warpt ein Bild zu einem virtuellen Bild mit einem forward 
%Algorithmus. Dazu werden die Tiefen Informationen des Ausgangsbildes 
%benötigt. Die Kamerakalibrierungsmatrix K der echten Kamera wird auch 
%benötigt und für die virtuelle Ansicht ebenfalls angenommen. Außerdem geht
%die Funktion davon aus, dass der Ursprung der echten Kamera der Nullpunkt 
%ist und M die Transformation ZU der virtuellen Anicht beschreibt.
%   Inputs:
%   Bild:       Eingabe Bild in Farbe 
%   Tiefen:     Tiefen Informationen zu dem Bild in uint8 
%   M:       	Euklidische Transformation von der Kamera ZU der virtuellen
%               Ansicht
%   K:          Kalibrierungsmatrix der Kamera
%   'debug':    True: Prüft Eingaben und zeigt Errechnete Bilder an.
%               Visualisiert den WarpCounter:
%               Verdeckt=Rot; Optimal=Grün; Mehrdeutig=Blau
%   'color':    Spaltenvektor für die Farbe der Nan Werte
%   Outputs:
%   warpBild:   Virtuelle Ansicht
%   warpTiefen: Tiefen Infos der virtuellen Ansicht
%   warpCounter:Zählt wie oft ein Pixel beschrieben wurde.
%               0=Verdeckt; 1=Optimal;  >1=Mehrdeutig

%% Input prüfen
threshold = 10e-5; %Falls die Prüfungen fehlschlagen wegen Num. Ungenauigkeit!

% define parser and add arguments
iparser = inputParser;
addOptional(iparser,'debug',false,@(x)validateattributes(x,{'logical'},{'binary'}));
addOptional(iparser,'color',[255;0;0],@(x)validateattributes(x,{'numeric'},{'column'}));

% do parsing and store results
parse(iparser,varargin{:});
debug = iparser.Results.debug;
color = iparser.Results.color;

if debug
    if ~(isnumeric(Bild) && (size(Bild,3) == 3 || ismatrix(Bild)))
        error('imwarpforward: Bild nicht korrekt! (Numerisch & RGB | Graustufen)')
    end
    if ~(isnumeric(Tiefen) && ismatrix(Tiefen))
        error('imwarpforward: Tiefen nicht korrekt! (Numerisch & Matrix)')
    end
    if ~(size(Bild,1)==size(Tiefen,1) && size(Bild,2)==size(Tiefen,2))
        error('imwarpforward: Bild und Depthmap nicht gleich groß!')
    end
    if ~(isnumeric(K) && all(size(K) == [3 3]))
        error('imwarpforward: K nicht korrekt! (Numerisch & 3x3 Matrix)')
    end
%     if ~(iseukltrans(M, threshold))
%         error('imwarpforward: M nicht korrekt! (4x4 & [R T;0 0 0 1])')
%     end
end

%% Init
xs = size(Bild,2);
ys = size(Bild,1);
warpBild = NaN(size(Bild));
warpTiefen = NaN(size(Tiefen));
warpCounter = zeros(size(Tiefen));
[R,T] = M2RT(M,threshold);
factor1 = K*R*inv(K);
factor1(abs(factor1)<=1e-6)=0;
factor2 = K*R*T;
factor2(abs(factor2)<=1e-6)=0;

%% Berechnung für jedes Pixel des alten Bildes
for i=1:ys %Zeilen = y-Richtung
   for j=1:xs %Spalten = x-Richtung 
       newP = factor1*double(Tiefen(i,j))*[j;i;1] - factor2;%Warp Formel
       newlambda = newP(3);
       if abs(newlambda)<1e-10 % Wegen möglicher division durch 0
           error('imwarpforward: |Lambda| kleiner 1e-10! Größere Änderung in z wählen!')
       end
       newP = newP./newlambda;
       indP = floor(newP(1:2)+0.5); %runden auf interger pixel indizes
       if all(indP>0) && indP(2)<=ys && indP(1)<=xs % nur werte die im Bild liegen
           warpBild(indP(2),indP(1),:) = Bild(i,j,:);
           warpTiefen(indP(2),indP(1)) = newlambda; 
           warpCounter(indP(2),indP(1)) = warpCounter(indP(2),indP(1))+1;
       end
   end
end

%% Debug
if debug
    figure();
    imshow(nan2color(warpBild,color));
    
    warpTiefendebug=warpTiefen;
    warpTiefendebug=(warpTiefendebug./max(max(warpTiefendebug)))*255;
    figure();
    imshow(uint8(warpTiefendebug));

    % Info in RGB erstellen (Irgendwie nicht schön, sollte aber funktionieren)
    InfoR=zeros(size(Tiefen));
    InfoG=zeros(size(Tiefen));
    InfoB=zeros(size(Tiefen));
    InfoR(warpCounter==0)=255;
    InfoG(warpCounter==1)=255;
    InfoB(warpCounter>1)=255;
    warpRGB = cat(3,InfoR,InfoG,InfoB);
    warpRGB=uint8(warpRGB);
    
    figure();
    imshow(warpRGB);
end

%% Output
if nargout == 1 || nargout == 0
    varargout{1} = warpBild;
elseif nargout == 2
    varargout{1} = warpBild;
    varargout{2} = warpTiefen;
elseif nargout == 3
    varargout{1} = warpBild;
    varargout{2} = warpTiefen;
    varargout{3} = warpCounter;
else
    error('imwarpforward: Falsche Anzahl Ausgabeparameter!') 
end

end

