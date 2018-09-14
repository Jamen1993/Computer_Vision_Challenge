function [Lochfrei] = antiNan(Bild,Tiefen)
%ANTINAN sucht nan werte und füllt sie mit den nächstgelegen Hintergrund pixeln

Lochfrei = Bild;
rs=size(Bild,1);
cs=size(Bild,2);
[nanRow, nanCol] = find(isnan(Bild(:,:,1)));
for i=1:size(nanRow,1)% für jedes Nan Pixel:
    next = NaN(4,4); %init next: sammelt nächste Pixel indizes
    
    [~, sameRow] = find(~isnan(Bild(nanRow(i),:,1)));%suche beschriebene pixel in der gleichen Zeile
    nextdist=sameRow-nanCol(i);%berechne Abstand zu diesen Pixeln
    
    next_right = min(nextdist(nextdist>0));%nächstes Pixel rechts hat den kleinesten positiven Abstand
    if ~isempty(next_right) %Falls überhaupt rechts noch etwas kommt
        next(1,1) = nanRow(i); %Hat die selbe zeile
        next(2,1) = nanCol(i) + next_right;% spalte ist NAN wert+Abstand
    end
    next_left = max(nextdist(nextdist<0)); %Links davon
    if ~isempty(next_left)
        next(1,2) = nanRow(i);
        next(2,2) = nanCol(i) + next_left;
    end
    
    [sameCol, ~] = find(~isnan(Bild(:,nanCol(i),1)));%Für oben/unten die Spalte untersuchen
    nextdist=sameCol-nanRow(i);
    
    next_down = min(nextdist(nextdist>0));%nächstes pixel darunter
    if ~isempty(next_down)
        next(2,3) = nanCol(i);
        next(1,3) = nanRow(i) + next_down;
    end
    next_up = max(nextdist(nextdist<0));%nächstes pixel darüber
    if ~isempty(next_up)
        next(2,4) = nanCol(i);
        next(1,4) = nanRow(i) + next_up;
    end
    
    
    for j=1:size(next,2) %Abstand der gefundenen Pixel zu dem Nan wert berechnen...
        if all(~isnan(next(1:2,j))) && all(next(1:2,j)>0) && next(1,j)<=rs && next(2,j)<=cs
            next(3,j)=norm([double(nanRow(i));double(nanCol(i))]-next(1:2,j));
            if nargin == 2 %...und ggf. Tiefenwert holen
                next(4,j)=Tiefen(next(1,j),next(2,j));
            end
        end
    end
    
    if all(isnan(next(3,:))) %Des is scheise
        error('antiNan: eine komplette Zeile und eine komplette Spalte sind Nan. Kann ich leider nicht verarbeiten.');
    end
    
    if nargin == 2 && min(next(3,:))>5 %Beim füllen von Occlusions sollen nur hintergrund pixel genommen werden...
        max_next=0.75*max(next(4,:));  %Jedoch könnten dann cracks im Vordergrund nicht verarbeitet werden...
        for j=1:size(next,2)           %Also wird bei kleinen Fehlern nicht nur mit Hintergrund gefüllt.
            if next(4,j)<max_next      %mindestens ein Pixel bleibt dabei übrig sodass immer etwas zum füllen da ist.
                next(3,j) = NaN;    
            end
        end
    end
    
    [~,pixind] = min(next(3,:)); %Aus verbleibenden Pixeln, das Pixel mit dem kleinesten Abstand auswählen
    Lochfrei(nanRow(i),nanCol(i),:) = Bild(next(1,pixind),next(2,pixind),:); %und schlieslich den wert übertragen
end

if any(any(any(isnan(Lochfrei(:,:,:))))) %Falls doch noch Nan Werte drin sein sollten:
   warning('antiNan: Leider konnten nicht alle Nan Werte beseitigt werden!?');
end

end

