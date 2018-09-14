function [depth] = disp2depth(disparity,K,T)
%DISP2DEPTH diese Function konvertiert eine disparity map in eine depth map
%Dazu werden noch die Kameramatrix (Brennweite) und die Translation (in
%x-Richtung, weil rektiviziert) benötigt. Dann wird depth = f * Tx / disp
%auf jedes Pixel angewand.

f = (K(1,1) + K(2,2))/2;
Tx = abs(T(1));             %absolut wert weil sonst kann die tiefe negativ werden
depth = f * Tx ./ disparity;

end

