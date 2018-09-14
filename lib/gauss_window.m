function w = gauss_window(n)
    x = linspace(-1.7, 1.7, n);
    w = exp(-(x .^ 2) / 2);
end
