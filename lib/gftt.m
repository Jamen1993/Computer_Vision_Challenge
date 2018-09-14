% @TODO
% Description of input and output arguments

function features = harris(gimg, window_size, threshold, min_dist, tiles, features_per_tile)
    % Harris feature detector
    %
    % gimg -
    % window_size -
    % k -
    % min_dist -
    % tiles -
    % features_per_tile -
    %
    % features -

    [Ix, Iy] = sobel(gimg);

    % Harris Matrix G
    % Komponenten der Harrismatrix für jedes Pixel berechnen
    G11 = Ix .^ 2;
    G12 = Ix .* Iy;
    G22 = Iy .^ 2;
    % Gewichtung mit Hammingfenster
    index = 0:(window_size - 1);
    % Formel aus Matlab Dokumentation
    w = 0.54 - 0.46 * cos(2 * pi * index / index(end));
    w = w / sum(w);
    % Zu zweidimensionalem separablem Filter kombinieren
    W = w' * w;
    % Komponenten mit Filterfunktion falten, um sie zu glätten und mittigen Pixeln mehr Gewicht zu verleihen.
    G11 = conv2(G11, W, 'same');
    G12 = conv2(G12, W, 'same');
    G22 = conv2(G22, W, 'same');

    R = zeros(size(gimg));

    for it_x = 1:size(gimg, 2)
        for it_y = 1:size(gimg, 1)
            G = [G11(it_y, it_x) G12(it_y, it_x)
                 G12(it_y, it_x) G22(it_y, it_x)];
            R(it_y, it_x) = min(eig(G));
        end
    end

    % margin size
    margin_size = ceil(window_size / 2);
    % Maske für Rand erstellen
    mask = true(size(R));
    mask((margin_size + 1):(end - margin_size), (margin_size + 1):(end - margin_size)) = false;
    % Rand mit maske zu Null setzen
    R(mask) = 0;

    R_to_sort = [R(:) (1:numel(R))'];
    R_to_sort(R_to_sort(:, 1) <= threshold, :) = [];

    R_sorted = sortrows(R_to_sort, 'descend');

    %% Merkmalsvorbereitung
    % Rand mit Nullen um corners hinzufügen
    % Der Rand wird benötigt, damit später die Cake-Maske angewandt werden kann ohne, dass es am Rand zu Konflikten bei der Indizierung kommt.
    Mask = true(size(R) + 2 * min_dist);

    %% Akkumulatorfeld
    % Kacheln gleichverteilt über Bild
    tile_grid = zeros(tiles);
    tile_size = size(gimg) ./ tiles;
    % Nach der Verarbeitung kann es maximal N Merkmale pro Kachel geben.
    features = zeros(2, numel(tile_grid) * features_per_tile);

    %% Merkmalsbestimmung mit Mindestabstand und Maximalzahl pro Kachel
    % Cake-Maske generieren
    Cake = cake(min_dist);

    % Vektor für Indizierung bei der Maskierung mit Cake im Voraus berechnen
    min_dist_range = -min_dist:min_dist;

    % Iterator für gefundene Merkmale
    it_features = 1;
    % for each in H_sorted
    for it_R = 1:length(R_sorted)
        [Ry, Rx] = ind2sub(size(R), R_sorted(it_R, 2));
        maskx = Rx + min_dist;
        masky = Ry + min_dist;
        % Wenn das Merkmal nicht vorhanden ist, wurde es bereits ausmaskiert und ist damit ungültig -> überspringen
        if ~Mask(masky, maskx)
            continue;
        else
            % Bereich um Merkmal ausmaskieren
            mask_rangex = min_dist_range + maskx;
            mask_rangey = min_dist_range + masky;
            Mask(mask_rangey, mask_rangex) = Mask(mask_rangey, mask_rangex) & Cake;
        end

        tilex = ceil(Rx / tile_size(2));
        tiley = ceil(Ry / tile_size(1));
        % In der Kachel um das Merkmal wurden schon N stärkere Merkmale gefunden -> überspringen
        if tile_grid(tiley, tilex) >= features_per_tile
            continue;
        else
            % Akkumulator inkrementieren und Merkmal aufnehmen
            tile_grid(tiley, tilex) = tile_grid(tiley, tilex) + 1;
            features(:, it_features) = [Rx; Ry];
            it_features = it_features + 1;
            if it_features > 500
                break;
            end
        end
    end
    % Ausgabematrix auf tatsächliche Anzahl von gefundenen Merkmalen zuschneiden
    features(:, it_features:end) = [];
end
