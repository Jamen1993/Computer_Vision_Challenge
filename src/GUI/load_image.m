function img = load_image(selected_axes)

    img = [];

    [file, filepath] = uigetfile({'*.jpg;*.jpeg;*.png'});
    if file
        img = imread(strcat(filepath, file));
        img = double(img) / 255;
        axes(selected_axes);
        imshow(img);
    end

end
