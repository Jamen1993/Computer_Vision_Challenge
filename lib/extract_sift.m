% @TODO
% Add some comments

function [Descriptors, features] = extract_sift(gimg, features)
    % SIFT descriptor according to Features_and_Image_Matching in Literatur

    r = 8;
    % Größe des Bilds
    % Da die Merkmalspunkte in der Form [x; y] übergeben werden, muss ich die Größe des Bilds aus der Darstellung [y, x] in die Form [x; y] umwandeln.
    s = flip(size(gimg))';

    % Für die Berechnung der NCC werden Fenster um die Merkmalspunkte gelegt. Punkte die näher als die halbe Breite des Fensters am Rand des Bildes liegen können nicht richtig gefenstert werden, da das Fenster über den Bildrand hinausstehen würde, wo keine gültigen Pixel existieren. Davon betroffene Merkmalspunkte werden daher entfernt.

    % Zuerst erstelle ich eine Matrix, die für jeden Merkmalspunkt zeigt, welcher der beiden Pixelindizes die oben genannte Bedingung verletzt.
    mask = features <= r | features > s - r;
    % Dann fasse ich die beiden Zeilenvektoren zusammen, denn ein Merkmalspunkt wird dann entfernt, wenn x ODER y die Bedingung verletzen
    mask = mask(1, :) | mask(2, :);
    % Merkmalspunkte, die die oben genannte Bedingung verletzen, entfernen
    features(:, mask) = [];

    % Indices for window and sub window
    iw = -8:8;
    iwsub = 1:4;
    % Descriptor matrix
    Descriptors = zeros(128, length(features));
    % Edges for histogram
    edges = linspace(-pi, pi, 9);
    % Hamming window for weighted mean for Harris matrix construction
    h = hamming_window(17);
    H = h' * h;
    H = H / sum(H(:));

    % for each feature
    for it_f = 1:length(features)
        % Indices for window
        ix = iw + features(1, it_f);
        iy = iw + features(2, it_f);
        % Get window
        W = gimg(iy, ix);
        % Calculate main angle
        [Ix, Iy] = sobel(W);
        I = [Ix(:)'
             Iy(:)'];
        % Eigen vector to greatest eigenvalue of Harris matrix has direction of main gradient
        G11 = sum(stackmat(Ix .^  2 .* H));
        G12 = sum(stackmat(Ix .* Iy .* H));
        G22 = sum(stackmat(Iy .^  2 .* H));

        G = [G11 G12
             G12 G22];

        [V, D] = eig(G);
        [~, is] = max(diag(D));

        main_angle = atan2(V(2, is), V(1, is));
        % Rotate main gradient to angle 0 rad to make the descriptor rotation invariant
        R = rot2mat(-main_angle);
        I = R * I;

        angles = atan2(I(2, :), I(1, :));

        angles = reshape(angles, 17, 17);
        % Remove middle row and column because descriptor extraciton works on 16 x 16 windows
        angles(9, :) = [];
        angles(:, 9) = [];
        % Split window in 4x4 sub windows and save histogram for the subwindow
        % Histograms for each subwindow
        N = zeros(8, 16);
        it_N = 1;
        % for each subwindow
        for it_x = 0:3
            for it_y = 0:3
                N(:, it_N) = histcounts(angles(iwsub + 4 * it_y, iwsub + 4 * it_x), edges);
                it_N = it_N + 1;
            end
        end
        % Stack all histograms for the feature into the descriptor matrix
        Descriptors(:, it_f) = N(:);
    end
end
