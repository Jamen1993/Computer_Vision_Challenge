function features = harris(gimg, window_size, threshold, min_dist, tiles, features_per_tile)
    % Run Harris feature detector on grayscale image gimg with filtering window edge length window_size and Harris metric threshold. The selected features have a minimum distance of min_dist. gimg is divided into a number of tiles and no more than features_per_tile features will be selected within a tile. The image is divided into a grid of tiles x tiles tiles.

    [Ix, Iy] = sobel(gimg);

    % Harris Matrix G
    % Komponenten der Harrismatrix für jedes Pixel berechnen
    G11 = Ix .^ 2;
    G12 = Ix .* Iy;
    G22 = Iy .^ 2;
    % Gewichtung mit Hammingfenster
    w = normsum(hamming_window(window_size));
    % Zu zweidimensionalem Filter kombinieren
    W = w' * w;
    % Komponenten mit Filterfunktion falten, um sie zu glätten und mittigen Pixeln mehr Gewicht zu verleihen.
    G11 = conv2(G11, W, 'same');
    G12 = conv2(G12, W, 'same');
    G22 = conv2(G22, W, 'same');

    %% Merkmalsextraktion über die Harrismessung
    H = G11 .* G22 - G12 .^ 2 - 0.03 * (G11 + G22) .^ 2;
    % Am Rand ist die Harrismetrik aufgrund von Unregelmäßigkeiten bei der Interpolation im vorherigen Abschnitt groß. Das führt bei der Intepretation der Metrik fälschlicherweise zur Detektion von Kanten. Der Rand muss also als ungültig erklärt werden, was durch Ersatz mit 0 möglich ist.
    % margin size
    margin_size = ceil(window_size / 2);
    % Maske für Rand erstellen
    mask = true(size(H));
    mask((margin_size + 1):(end - margin_size), (margin_size + 1):(end - margin_size)) = false;
    % Rand mit maske zu Null setzen
    H(mask) = 0;

    H_to_sort = [H(:) (1:numel(H))'];
    H_to_sort(H_to_sort(:, 1) <= threshold, :) = [];

    H_sorted = sortrows(H_to_sort, 'descend');

    %% Merkmalsvorbereitung
    % Rand mit Nullen um corners hinzufügen
    % Der Rand wird benötigt, damit später die Cake-Maske angewandt werden kann ohne, dass es am Rand zu Konflikten bei der Indizierung kommt.
    Mask = true(size(H) + 2 * min_dist);

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
    for it_H = 1:length(H_sorted)
        [Hy, Hx] = ind2sub(size(H), H_sorted(it_H, 2));
        maskx = Hx + min_dist;
        masky = Hy + min_dist;
        % Wenn das Merkmal nicht vorhanden ist, wurde es bereits ausmaskiert und ist damit ungültig -> überspringen
        if ~Mask(masky, maskx)
            continue;
        else
            % Bereich um Merkmal ausmaskieren
            mask_rangex = min_dist_range + maskx;
            mask_rangey = min_dist_range + masky;
            Mask(mask_rangey, mask_rangex) = Mask(mask_rangey, mask_rangex) & Cake;
        end

        tilex = ceil(Hx / tile_size(2));
        tiley = ceil(Hy / tile_size(1));
        % In der Kachel um das Merkmal wurden schon N stärkere Merkmale gefunden -> überspringen
        if tile_grid(tiley, tilex) >= features_per_tile
            continue;
        else
            % Akkumulator inkrementieren und Merkmal aufnehmen
            tile_grid(tiley, tilex) = tile_grid(tiley, tilex) + 1;
            features(:, it_features) = [Hx; Hy];
            it_features = it_features + 1;
            if it_features > 500
                break;
            end
        end
    end
    % Ausgabematrix auf tatsächliche Anzahl von gefundenen Merkmalen zuschneiden
    features(:, it_features:end) = [];
end
