function [correspondences_robust] = F_ransac(correspondences, iterations, max_dist)
    % Use random sample consensus method based on fundamental matrix estimation and following sampson distance evaluation on all correspondence pairs. The number of iterations and the allowed Sampson distance have to be set.

    % Pixelkoordinaten aus Korrespondenzen extrahieren und in homogene Darstellung umwandeln
    x1 = to_hom(correspondences(1:2, :));
    x2 = to_hom(correspondences(3:4, :));

    %% RanSaC Algorithmus Vorbereitung
    % Anzahl der Korresponzenzen im größten bisher gefundenen Consensus-Set (largest_set)
    largest_set_size = 0;
    % Sampson-Distanz von largest_set
    largest_set_dist = Inf;
    % Indizes des größten Konsensus-Sets
    largest_set = [];

    nbytes = zeros(1, 2);

    nbytes(1) = fprintf('Iteration %d / ', iterations);

    %% RanSaC Algorithmus Durchführung
    for it = 1:iterations
        % Delete line in command line
        fprintf(repmat('\b', 1, nbytes(2)));
        nbytes(2) = fprintf('%d', it);
        % 1. Fundamentalmatrix mit Achtpunktalgorithmus und k zufällig ausgesuchten Korrespondenzpunktpaaren schätzen
        ind_rand = randperm(length(correspondences), 8);
        F = eight_point(correspondences(:, ind_rand));
        % 2. Sampson-Distanz für alle Korrespondenzpunktpaare bezogen auf die geschätzte Fundamentalmatrix berechnen
        sd = sampson_dist(F, x1, x2);
        % 3. Geeignete Korrespondenzpunktpaare entsprechend tolerance auswählen und ins aktuelle Consensus-Set aufnehmen
        % Ich arbeite hier nur mit den Indizes, damit ich nicht dauernd große Arrays kopieren muss
        consensus_set = find(sd <= max_dist);
        % 4. Für das Consensus-Set die Anzahl der Paare und die absolute Set-Distanz als Summe über die Sampson-Distanzen des Sets ermitteln.
        set_size = length(consensus_set);
        set_dist = sum(sd(consensus_set));
        % 5. & 6. Das Consensus-Set mit dem größten (bezüglich Anzahl der Paare) bisher gefundenen vergleichen: Ist das aktuelle größer, wird dieses übernommen; sind beide gleich groß, wird das mit der kleineren absoluten Set-Distanz übernommen; ansonsten ändert sich nichts.
        if set_size > largest_set_size || set_size == largest_set_size && set_dist < largest_set_dist
            largest_set = consensus_set;
            largest_set_size = set_size;
            largest_set_dist = set_dist;
        end
    end
    % Korrespondenzpunktpaare des besten Consensus-Sets auswählen
    correspondences_robust = correspondences(:, largest_set);

    fprintf(repmat('\b', 1, sum(nbytes)));
end
