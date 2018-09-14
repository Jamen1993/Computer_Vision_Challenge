function w = hamming_window(n)
    x = linspace(0, n, n);
    w = 0.54 - 0.46 * cos(2 * pi * x / n);
end
