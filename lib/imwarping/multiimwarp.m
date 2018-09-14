function [varargout] = multiimwarp(Bild1,Tiefen1,Bild2,Tiefen2,M,f,K,varargin)
%MULTIIMWARP warpt ein Bild zwischen zwei gegebene Bilder mit ihren Tiefen 
%Informationen. M ist die Transformation zwischen den Bildern, f der Faktor
%für die Aufteilung. Die Kamerakalibrierungsmatrix K wird für alle Input 
%Bilder und den Output als gleich angenommen. Außerdem geht
%die Funktion davon aus, dass der Ursprung der ersten Kamera der Nullpunkt 
%ist und M die Transformation P2 = M*P1 beschreibt.
%   Inputs:
%   Bild1:      Eingabe linkes Bild in Farbe 
%   Tiefen1:    Tiefen Informationen zum ersten Bild in uint8
%   Bild2:      Eingabe rechtes Bild in Farbe 
%   Tiefen2:    Tiefen Informationen zum zweiten Bild in uint8
%   M:       	Euklidische Transformation von einem Bild zum anderen
%   f:       	Faktor für Verschiebung der Ansicht
%   K:          Kalibrierungsmatrix der Kamera
%   'debug':    True: Prüft Eingaben und zeigt Errechnete Bilder an.
%               Visualisiert die Entstehung des Bildes:
%               Keine Bildinfo=schwarz; Aus beiden Bildern=Rot;
%               Nur Bild 1=Grün; Nur Bild 2=Blau
%   'color':    Spaltenvektor für die Farbe der Nan Werte im Debug output
%   'quiet':    Falls auf true gesetzt und debug false ist, wird keinerlei
%               Ausgabe erzeugt
%   'dilRadius':Die Kanten Länge der quadratischen Blöcke bei der Dilation
%   'eroRadius':Die Kanten Länge der quadratischen Blöcke bei der Erusion
%   'depthThreshold': Threshold für die Tiefe beim Vergleich der berechneten Bilder
%                     Das Pixel im Vordergrund wird bevorzugt.
%                     Tiefenunterschied: Tiefe links - Tiefe rechts =
%                      [+/-] Threshold: Beide Bilder überlagern
%                      > Threshold: Bild rechts
%                      < -Threshold: Bild links
%   Outputs:
%   warpBild:   Virtuelle Ansicht
%   warpTiefen: Tiefen Infos der virtuellen Ansicht

%% Input prüfen
threshold = 10e-5; %Falls die Prüfungen fehlschlagen wegen Num. Ungenauigkeit!

% define parser and add arguments
iparser = inputParser;
addOptional(iparser,'debug',false,@(x)validateattributes(x,{'logical'},{'binary'}));
addOptional(iparser,'color',[255;0;0],@(x)validateattributes(x,{'numeric'},{'column'}));
addOptional(iparser,'quiet',false,@(x)validateattributes(x,{'logical'},{'binary'}));
addOptional(iparser,'dilRadius',5,@(x)validateattributes(x,{'numeric'},{'integer'}));
addOptional(iparser,'eroRadius',7,@(x)validateattributes(x,{'numeric'},{'integer'}));
addOptional(iparser,'depthThreshold',5,@(x)validateattributes(x,{'numeric'},{'>',0}));

% do parsing and store results
parse(iparser,varargin{:});
debug = iparser.Results.debug;
quiet = iparser.Results.quiet;
color = iparser.Results.color;
dilRadius = iparser.Results.dilRadius;
eroRadius = iparser.Results.eroRadius;
depthThreshold = iparser.Results.depthThreshold;

if debug
    quiet = false;
end

if debug
    if ~(isnumeric(f) && isscalar(f) && f>=0 && f<=1)
        error('ScaleRT: f nicht korrekt! (Numerisch & Skalar & [0,1])')
    end
    if ~(isnumeric(Bild1) && (size(Bild1,3) == 3 || ismatrix(Bild1)))
        error('multiimwarp: Bild1 nicht korrekt! (Numerisch & RGB | Graustufen)')
    end
    if ~(isnumeric(Tiefen1) && ismatrix(Tiefen1))
        error('multiimwarp: Tiefen1 nicht korrekt! (Numerisch & Matrix)')
    end
    if ~(size(Bild1,1)==size(Tiefen1,1) && size(Bild1,2)==size(Tiefen1,2))
        error('multiimwarp: Bild1 und Depthmap1 nicht gleich groß!')
    end
%     if ~(iseukltrans(M, threshold))
%         error('multiimwarp: M nicht korrekt! (4x4 & [R T;0 0 0 1])')
%     end
    if ~(isnumeric(Bild2) && (size(Bild2,3) == 3 || ismatrix(Bild2)))
        error('multiimwarp: Bild2 nicht korrekt! (Numerisch & RGB | Graustufen)')
    end
    if ~(isnumeric(Tiefen2) && ismatrix(Tiefen2))
        error('multiimwarp: Tiefen2 nicht korrekt! (Numerisch & Matrix)')
    end
    if ~(size(Bild2,1)==size(Tiefen2,1) && size(Bild2,2)==size(Tiefen2,2))
        error('multiimwarp: Bild2 und Depthmap2 nicht gleich groß!')
    end
    if ~(size(Bild1,1)==size(Bild2,1) && size(Bild1,2)==size(Bild2,2))
        error('multiimwarp: Bild1 und Bild2 nicht gleich groß!')
    end
    if ~(isnumeric(K) && all(size(K) == [3 3]))
        error('multiimwarp: K nicht korrekt! (Numerisch & 3x3 Matrix)')
    end
end

%% Init
xs = size(Bild1,2);
ys = size(Bild1,1);
warpBild = NaN(size(Bild1));
warpTiefen = NaN(size(Tiefen1));
warpCounter = zeros(size(Tiefen1));

invwarpTiefen1 = NaN(size(Tiefen1));
invwarpTiefen2 = NaN(size(Tiefen2));

[R, T]=M2RT(M,threshold);
[M1, M2] = scaleM(f,M);

%% 1Step
if ~quiet
    fprintf('Start multi Image warping with 4 steps...\n');
    fprintf('1.Step: Performing forward warp of depth...\n');
end

warpTiefen1 = imwarpforward(Tiefen1,Tiefen1,M1,K);
warpTiefen2 = imwarpforward(Tiefen2,Tiefen2,M2,K);

%% 2Step
if dilRadius~=0
    
    if ~quiet
        fprintf('2.1 Step: Performing imdilate of depth...\n');
    end

    warpTiefen1 = imdilateAlex(warpTiefen1,dilRadius);
    warpTiefen2 = imdilateAlex(warpTiefen2,dilRadius);

    if ~quiet
        fprintf('2.2 Step: Performing imerode of depth...\n');
    end

    warpTiefen1 = imerodeAlex(warpTiefen1,eroRadius);
    warpTiefen2 = imerodeAlex(warpTiefen2,eroRadius);

end
%% 3Step Compute 3D Points from depth map
if ~quiet
    fprintf('3. Step: Compute 3D Points from depth map and...\n');
    fprintf('4.1 Step: Compute 2D Points in Images from 3D Points in one FOR...\n');
end

p1_2d = NaN(ys,xs,2); % 1.Ebene = x; 2.Ebene = y
p2_2d = NaN(ys,xs,2); % 1.Ebene = x; 2.Ebene = y
invK = inv(K);
invR = inv(R);
factor1 = invK;
factor1(abs(factor1)<=1e-6)=0;
factor2 = invR*invK;
factor2(abs(factor2)<=1e-6)=0;
M1morv = [K,zeros(3,1)]*eye(4);
M2morv = [K,zeros(3,1)]*[R,-R*T;zeros(1,3),1];

for i=1:ys %Zeilen = y-Richtung
   for j=1:xs %Spalten = x-Richtung 
        if ~isnan(warpTiefen1(i,j))
            p1_warp = [j;i;1];
            % 1.step of back projection: compute lambda
            z = factor1*p1_warp;
            lambda=warpTiefen1(i,j)/z(3);
            % 2.Step of back projection: compute real point along ray
            P1=lambda*factor1*p1_warp;%P1 echter 3D Punkt
            % 4.1 Step Compute 2D Points in Images from 3D Points
            p1=M1morv*[P1;1];% p1 ist pixel mit tiefe
            lambda1 = p1(3);% lambda1 ist tiefe
            if abs(lambda1)<1e-10 % Wegen möglicher division durch 0
                error('multiimwarp: |Lambda1| kleiner 1e-10!')
            end
            p1 = p1./lambda1; % p1 ist pixel homogen
            p1 = floor(p1(1:2)+0.5); %runden auf interger pixel indizes
            if p1(1)>0 && p1(1)<=xs && p1(2)>0 && p1(2)<=ys %Pixel nur benutzen wenn es im Bild liegt
                invwarpTiefen1(p1(2),p1(1)) = lambda1; 
                p1_2d(i,j,:) = permute(p1,[3 2 1]);
            end
        end
        if ~isnan(warpTiefen2(i,j))
            p2_warp = [j;i;1];
            % 1.step of back projection: compute lambda
            z = factor2*p2_warp;
            lambda=(warpTiefen2(i,j)-T(3))/z(3);
            % 2.Step of back projection: compute real point along ray
            P2=T+lambda*factor2*p2_warp;%P2 echter 3D Punkt
            % 4.1 Step Compute 2D Points in Images from 3D Points
            p2=M2morv*[P2;1];% p2 ist pixel mit tiefe
            lambda2 = p2(3);% lambda2 ist tiefe
            if abs(lambda2)<1e-10 % Wegen möglicher division durch 0
                error('multiimwarp: |Lambda2| kleiner 1e-10!')
            end
            p2 = p2./lambda2; % p2 ist pixel homogen
            p2 = floor(p2(1:2)+0.5); %runden auf interger pixel indizes
            if p2(1)>0 && p2(1)<=xs && p2(2)>0 && p2(2)<=ys %Pixel nur benutzen wenn es im Bild liegt
                invwarpTiefen2(p2(2),p2(1)) = lambda2; 
                p2_2d(i,j,:) = permute(p2,[3 2 1]);
            end
        end
   end
end

%% 4.2Step
if ~quiet
    fprintf('4.2 Step: Compute virtual view with 2D Inforamtion...\n');
end

for i=1:ys %Zeilen = y-Richtung
   for j=1:xs %Spalten = x-Richtung 
        if all(~isnan(p1_2d(i,j,:))) && all(~isnan(p2_2d(i,j,:)))
            tiefenvergleich = invwarpTiefen1(p1_2d(i,j,2),p1_2d(i,j,1)) - invwarpTiefen2(p2_2d(i,j,2),p2_2d(i,j,1));
            if abs(tiefenvergleich) <= depthThreshold
                warpBild(i,j,:) = (Bild2(p2_2d(i,j,2),p2_2d(i,j,1),:)+Bild1(p1_2d(i,j,2),p1_2d(i,j,1),:))./2;
                warpTiefen(i,j) = (Tiefen2(p2_2d(i,j,2),p2_2d(i,j,1))+Tiefen1(p1_2d(i,j,2),p1_2d(i,j,1)))./2;
                warpCounter(i,j)=3;
            elseif tiefenvergleich < -depthThreshold
                warpBild(i,j,:) = Bild1(p1_2d(i,j,2),p1_2d(i,j,1),:);
                warpTiefen(i,j) = Tiefen1(p1_2d(i,j,2),p1_2d(i,j,1));
                warpCounter(i,j)=1;
            elseif tiefenvergleich > depthThreshold
                warpBild(i,j,:) = Bild2(p2_2d(i,j,2),p2_2d(i,j,1),:);
                warpTiefen(i,j) = Tiefen2(p2_2d(i,j,2),p2_2d(i,j,1));
                warpCounter(i,j)=2;
            end
        elseif all(isnan(p1_2d(i,j,:))) && all(~isnan(p2_2d(i,j,:)))
            warpBild(i,j,:) = Bild2(p2_2d(i,j,2),p2_2d(i,j,1),:);
            warpTiefen(i,j) = Tiefen2(p2_2d(i,j,2),p2_2d(i,j,1));
            warpCounter(i,j)=2;
        elseif all(~isnan(p1_2d(i,j,:))) && all(isnan(p2_2d(i,j,:)))
            warpBild(i,j,:) = Bild1(p1_2d(i,j,2),p1_2d(i,j,1),:);  
            warpTiefen(i,j) = Tiefen1(p1_2d(i,j,2),p1_2d(i,j,1));
            warpCounter(i,j)=1;          
        elseif all(isnan(p1_2d(i,j,:))) && all(isnan(p2_2d(i,j,:)))
            % occlusion Algorithm
        else
            error('multiimwarp: WTF!')
        end
   end
end

%% Debug
if debug
    fprintf('Debug\n');
    
    figure();
    imshow(nan2color(warpBild,color));
    
    warpTiefendebug=uint8(warpTiefen);
    figure();
    imshow(warpTiefendebug);

    % Info in RGB erstellen (Irgendwie nicht schön, sollte aber funktionieren)
    InfoR=zeros(size(Tiefen1));
    InfoG=zeros(size(Tiefen1));
    InfoB=zeros(size(Tiefen1));
    InfoR(warpCounter==3)=255;
    InfoG(warpCounter==1)=255;
    InfoB(warpCounter==2)=255;
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
else
    error('multiimwarp: Falsche Anzahl Ausgabeparameter!') 
end

if ~quiet
    fprintf('multiimwarp DONE!\n');
end

end

