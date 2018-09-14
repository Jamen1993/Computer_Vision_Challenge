function [Farbbild] = nan2color(Bild,color)
%NAN2COLOR ersetzt im Bild Nan werte durch die Farbe [R G B]
    Farbbild=Bild;
    [nanRow, nanCol] = find(isnan(Farbbild(:,:,1)));
    if size(Farbbild,3)==3
        if size(color,1)==3
            per_color = permute(color,[3 2 1]);
        else
            per_color = permute(color,[3 1 2]);
        end
        for i=1:size(nanRow,1)
            Farbbild(nanRow(i),nanCol(i),:) = per_color;
        end
    elseif size(Farbbild,3)==1
        for i=1:size(nanRow,1)
            Farbbild(nanRow(i),nanCol(i)) = color(1);
        end
    end
end

