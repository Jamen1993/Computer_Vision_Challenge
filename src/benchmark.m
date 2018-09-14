%% Execution Time Benchmark
% This script can be used to run a benchmark regarding execution time of
% the free_viewpoint function

envsetup;
close all;

%% Parameters
% Enter your settings here
CPU = 'Intel Core i5-4590 4 x 3.3 GHz';    % Your CPU type. Be as precise as possible, e.g. 'Intel Core i5 - 4 x 2,6 GHz'
RAM = '8 GB 2133 MHz DDR3';    % Your RAM size and type, e.g. '8 GB 1600 MHz DDR3'
OS = 'Windows 10 1803 17134.228';     % Your operating system, e.g. 'Windows 95 - Service Pack 4 nightly build'

%% Load images
load_image = @(file_path) double(imread(file_path)) / 255;

scene_L1 = load_image('L1.jpg');
scene_L2 = load_image('L2.jpg');
scene_R1 = load_image('R1.jpg');
scene_R2 = load_image('R2.jpg');

%% Load precomputed calibration matrices
Ks = load('K');

%% Benchmark
p = [0.2, 0.45, 0.7, 1];
iterations = 5;

elapsed_time = zeros(1, 2 * iterations * length(p));
virtual_views = cell(1, 40);
exceptions = cell(1, 40);

it = 1;

for i = 1:iterations
    for j = 1:length(p)
        fprintf('Running free_viewpoint %d of %d.\n', it, 2 * iterations * length(p));
        try
            tic;
            scene_V = free_viewpoint(scene_L1, scene_R1, Ks.K1, p(j));
            elapsed_time(it) = toc;
            virtual_views{it} = scene_V;
        catch ME
            exceptions{it} = ME.message;
        end
        it = it + 1;

        fprintf('Running free_viewpoint %d of %d.\n', it, 2 * iterations * length(p));
        try
            tic;
            scene_V = free_viewpoint(scene_L2, scene_R2, Ks.K2, p(j));
            elapsed_time(it) = toc;
            virtual_views{it} = scene_V;
        catch ME
            exceptions{it} = ME.message;
        end
        it = it + 1;
    end
end

mean_elapsed_time = mean(elapsed_time);
std_elapsed_time = std(elapsed_time);

%% Save Benchmark results

save('../out/benchmark_results.mat','CPU','RAM','OS','p','iterations','elapsed_time','mean_elapsed_time','std_elapsed_time', 'virtual_views', 'exceptions');
