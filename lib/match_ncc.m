% @TODO:
% Could be improved by forward backward matching and ratio based threshold as with SSD matching

function correspondences = match_ncc(features_1, features_2, descriptors_1, descriptors_2, min_corr)
    % Jetzt wird die NCC der verschiedenen Bildausschnitte untereinander berechnet. Diese Metrik zeigt, wie sehr sich zwei Bildausschnitte ähneln. Der Wertebereich ist -1 .. 1 wobei die Bedeutung der Werte dieselbe ist wie bei der Auto- oder Kreuzkorrelation.

    % Normalise descriptors
    normalise = @(descriptors) (descriptors - mean(descriptors, 1)) ./ std(descriptors, 1);

    descriptors_1 = normalise(descriptors_1);
    descriptors_2 = normalise(descriptors_2);

    % Berechnung der Korrelationsmatrix mit erwartungstreuer Normierung (N - 1) über die Anzahl der Einträge im descriptor; die Matrix mit den Indizes m, n zeigt, wie stark das m-te Merkmal aus Bild 1 mit dem n-ten Merkmal aus Bild 2 korreliert.
    CC = (descriptors_2' * descriptors_1) / (size(descriptors_1, 1) - 1);
    % Als nächstes sollen die Punktpaare entsprechend ihrer Korrelation absteigend sortiert werden. Dafür erstelle ich zuerst eine Tabelle, die die vektorisierte NCC-Matrix und die zugehörigen linearen Indizes der Elemente enthält.
    CC_sorted = [CC(:), (1:numel(CC))'];
    % Nur Punkte mit hoher NCC sind Kandidaten für Korrespondierende Punkte, daher werden alle Einträge mit geringer Korrelation entsprechend Schwellwert eliminiert.
    CC_sorted(CC_sorted(:, 1) < min_corr, :) = [];
    % Einträge entsprechend Korrelation sortieren
    CC_sorted = sortrows(CC_sorted, 'descend');

    %% Korrespondenz
    % Nachdem Punkte Merkmalspunkte mit hoher Korrelation gefunden wurden, können diese zu korrespondierenden Paaren zusammengestellt werden. Wichtig ist dabei, dass jeder Merkmalspunkt nur in einem Paar enthalten sein und nicht gleichzeitig mit zwei Merkmalspunkten aus dem anderen Bild korrespondieren kann.

    % In dieser Matrix werden die korrespondierenden Paare in der Form [x1; y1; x2; y2] spaltenweise abgelegt.
    correspondences = zeros(4, length(CC_sorted));
    % Iterator für eingetragene korrespondierende Punkte
    it_correspondences = 1;

    % for each in S
    for it_CC = 1:length(CC_sorted)
        % Matrixindex aus Vektorindex rekonstruieren
        [CCy, CCx] = ind2sub(size(CC), CC_sorted(it_CC, 2));
        % Prüfen, ob einer der beiden Merkmalspunkte schon für ein paar verwendet wurde
        if ~CC(CCy, CCx)
            % Falls ja, überspringen
            continue;
        end
        % Paar als korrespondierend eintragen
        correspondences(:, it_correspondences) = [features_1(:, CCx); features_2(:, CCy)];
        it_correspondences = it_correspondences + 1;
        % Punkte als verwendet eintragen
        % Mark both features as used by nulling the associated row and column of NCC
        CC(:, CCx) = 0;
        CC(CCy, :) = 0;
    end

    % Nicht gefüllte Spalten entfernen
    correspondences(:, it_correspondences:end) = [];
end
