%% Script for extracting all images that were created during benchmark run

close all;
clear all;
clc;

%% Load benchmark results
load('../out/benchmark_results.mat');

%% Save all images to documentation folder
path_doc = '../doc/images/virtual_views/';

for i = 1:length(p)
    
    scene_V_pair1 = virtual_views{(i-1)*2+1};
    scene_V_pair2 = virtual_views{(i-1)*2+2};
    
    p_str = replace(num2str(p(i)),'.','_');
    filename_pair1 = [path_doc 'virtual_view_p' p_str '_pair1.png'];
    filename_pair2 = [path_doc 'virtual_view_p' p_str '_pair2.png'];
    
    imwrite(scene_V_pair1,filename_pair1);
    imwrite(scene_V_pair2,filename_pair2);
    
end