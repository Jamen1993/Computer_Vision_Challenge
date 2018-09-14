function [R, T] = E2RT(E, Korrespondenzen, K)
    %E2RT Berechnet aus E und Korrespondenzen die euklidische Transformation
    %Falls K nicht angegeben wird, wird von schon Kalibrierten Werten
    %ausgegangen; Korrespondenzen k�nnen als K(:,i)=(x1 y1 x2 y2)' oder schon
    %homogenisiert als K(:,i)=(x1 y1 1 x2 y2 1)' angegeben werden.
    %Statt R&T kann auch M ausgegeben werden;
    %   Inputs:
    %   E:          Essentielle Matrix
    %   Outputs:
    %   [R, T]:     Errechnete Rotationsmatrix & Translationsvektor

    %% Berechne M�gliche Rs und Ts (Hausaufgabe 4.1)
    % falls determinate -1, mit trick aus 3.4 seite 3 behandeln
    [U, S, V] = svd(E);

    if det(U) < 0
        U = U * [1 0 0; 0 1 0; 0 0 -1];
    end
    if det(V) < 0
        V = V * [1 0 0; 0 1 0; 0 0 -1];
    end

    % Erstelle Rz Hilfsmatrizen
    Rz_plus = [0 -1 0; 1 0 0; 0 0 1];
    Rz_minus = [0 1 0; -1 0 0; 0 0 1];

    % Berechne moegliche T und R
    R1 = U * Rz_plus' * V';
    R2 = U * Rz_minus' * V';
    T1 = U * Rz_plus * S * U';
    T2 = U * Rz_minus * S * U';

    % Transformiere T^s zu Ts
    T1 = invcrossmat(T1);
    T2 = invcrossmat(T2);

    %% Preparation (Hausaufgabe 4.2)

    %Anzahl Korrespondenzen ist N
    N = size(Korrespondenzen,2);

    % init T_cell
    T_cell = {T1, T2, T1, T2};

    % init R_cell
    R_cell = {R1, R1, R2, R2};

    % init d_cell
    N_2 = zeros(N, 2);
    d_cell = {N_2, N_2, N_2, N_2};

    x1 = to_hom(Korrespondenzen(1:2, :));
    x2 = to_hom(Korrespondenzen(3:4, :));

    if nargin == 3
        % xe kalibriren
        x1 = K \ x1;
        x2 = K \ x2;
    end

    %% Rekonstruktion mit M (Hausaufgabe 4.3)
    % Initialisierung Ms
    M1 = zeros(3 * N, N + 1);
    M2 = M1;

    for i = 1:4 %Jede Kombi R - T
        for j = 1:N %Jede Korrespondenz
            % Vorberechnungen
            x1_h = crossmat(x1(:, j));
            x2_h = crossmat(x2(:, j));
            start_row = j * 3 - 2;
            end_row = j * 3;

            % Aufstellen der Gleichungssysteme
            M1(start_row:end_row, j)= x2_h * R_cell{i} * x1(:, j);
            M1(start_row:end_row, end) = x2_h * T_cell{i};
            M2(start_row:end_row, j)= x1_h * R_cell{i}' * x2(:, j);
            M2(start_row:end_row, end) = -x1_h * R_cell{i}' * T_cell{i};
        end

        % Bestimme Loesung durch SVD
        [~, ~, V] = svd(M1);
        d1 = V(:, end);
        [~, ~, V] = svd(M2);
        d2 = V(:, end);

        % Normiere Vektoren d1 und d2
        d1 = d1 ./ d1(end);
        d2 = d2 ./ d2(end);

        % Speichere d1 und d2 in d_cell
        d_cell{i} = [d1(1:(end - 1)), d2(1:(end - 1))];
    end

    % Anzahl der positiven Eintr�ge in d_cell z�hlen
    Anz_pos = zeros(4,1);
    for i = 1:4
        Anz_pos(i) = nnz(d_cell{i} > 0);
    end

    % Index des Maximums bestimmen
    [~, i_max] = max(Anz_pos);

    % Beste Werte ausgeben
    T = T_cell{i_max};
    R = R_cell{i_max};
end

