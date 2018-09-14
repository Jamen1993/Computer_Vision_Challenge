function correspondences = match_ssd(features_1, features_2, descriptors_1, descriptors_2, min_ratio)
    % Match features by ratio based sum of squared differences

    s = size(descriptors_2);
    descriptors_2 = reshape(descriptors_2, s(1), 1, s(2));
    % Rowindex is associated with features 1
    % Columnindex is associated with features 2
    SSD = squeeze(sum((descriptors_1 - descriptors_2) .^ 2, 1));
    % Forward backward matching
    [sorted_12, is_12] = sort(SSD, 2, 'ascend');
    [sorted_21, is_21] = sort(SSD, 1, 'ascend');

    ratio_12 = sorted_12(:, 2) ./ sorted_12(:, 1);
    ratio_21 = sorted_21(2, :) ./ sorted_21(1, :);

    s1 = length(features_1);
    s2 = length(features_2);
    l = min([s1 s2]);
    correspondences = zeros(4, l);

    it_c = 1;
    % for each feature 1
    for it_f = 1:l
        % Check threshold minimum ratio for feature 1
        if ratio_12(it_f) < min_ratio
            continue;
        end
        % Forward backward matching
        mf = is_12(it_f, 1);
        mb = is_21(1, mf);
        % Continue if pair is not the best match in both directions
        if it_f ~= mb
            continue;
        end
        % Check threshold minimum ratio for feature 2
        if ratio_21(mf) < min_ratio
            continue;
        end
        % Else record feature match
        correspondences(:, it_c) = [features_1(:, it_f)
                                    features_2(:, mf)];
        it_c = it_c + 1;
    end

    correspondences(:, it_c:end) = [];
end
