function plot_correspondences(gimg_1, gimg_2, correspondences, overlayed)
    figure;

    s = size(gimg_1);

    if overlayed
        % Beide Graustufenbilder mit 50 % Alpha übereinanderlegen
        img = zeros(s(1), s(2), 3);
        img(:, :, 1) =  gimg_1;
        img(:, :, 3) =  0.1;
        h1 = imshow(img);
        h1.AlphaData = 0.5;
        hold on;
        img(:, :, 1) = 0;
        img(:, :, 2) =  gimg_2;
        h2 = imshow(img);
        h2.AlphaData = 0.5;
        % Korrespondierende Punkte markieren
        plot(correspondences(1, :), correspondences(2, :), 'or');
        plot(correspondences(3, :), correspondences(4, :), 'og');
        % Korrespondierende Punkte mit Linien verbinden
        plot(correspondences([1, 3], :), correspondences([2, 4], :), 'w');
        hold off;
    else
        img = [gimg_1 gimg_2];
        imshow(img);
        hold on;
        correspondences(3, :) = correspondences(3, :) + s(2);
        plot(correspondences(1, :), correspondences(2, :), 'or');
        plot(correspondences(3, :), correspondences(4, :), 'og');
        % Korrespondierende Punkte mit Linien verbinden
        plot(correspondences([1, 3], :), correspondences([2, 4], :), ':w');
        hold off;
    end
    % Beschriftung
    title('Corresponding Features')
    legend('Features from image 1', 'Features from image 2', 'Correspondences');
end
