function [disparity] = disp_block(leftImage,rightImage,varargin)
%DISP_BLOCK Function copied from script StereoDisparity.m
% Output: disparity map
% Inputs: Two rectified Images
% Optional Inputs: (default)/otherPossibilities
% 'debug': (false)/true: shows figure at the end (and sets quiet=false)
% 'quiet': (false)/true: no text output if true
% 'disparityRange': (400)/numeric>0 The disparity range defines how many
%                   pixels away from the block's location in the first
%                   image to search for a matching block in the other image
% 'searchDirection': ('right')/'left'/'both' directions for the use of
%                    disparityRange.
% 'blockSize': (15)/odd>2 Define the size of the blocks for block matching.
% 'skipRow': (1)/integer>0 Only every X. row is computed. The rest is linearly
%         interplolated
% 'skipCol': (1)/integer>0 Only every Y. column is computed. The rest is
%         linearly interplolated


%% Orgininal Header:
% The following code was adapted from a Mathworks example available here:
% http://www.mathworks.com/help/vision/examples/stereo-vision.html
%
% This script will compute the disparity map for the image 'right.png' by
% correlating it to 'left.png' using basic block matching and sub-pixel
% estimation. This code corresponds to sections 1 - 3 of the Mathworks
% tutorial.
%
% The main differences with the original tutorial are the following:
%   - Removed dependency on the TemplateMatcher object.
%   - Syntax and variable name changes for clarity.
%   - Extensive commenting.

% $Author: ChrisMcCormick $    $Date: 2014/01/10 22:00:00 $    $Revision: 1.0 $

% Revision notes:
%   v1.0 - 2014/01/10
%     - Initial version.

%% Input Parsing

% define parser and add arguments
iparser = inputParser;
addOptional(iparser,'debug',false,@(x)validateattributes(x,{'logical'},{'binary'}));
addOptional(iparser,'quiet',false,@(x)validateattributes(x,{'logical'},{'binary'}));
addOptional(iparser,'skipRow',1,@(x)validateattributes(x,{'numeric'},{'>', 0, 'integer'}));
addOptional(iparser,'skipCol',1,@(x)validateattributes(x,{'numeric'},{'>', 0, 'integer'}));
addOptional(iparser,'disparityRange',400,@(x)validateattributes(x,{'numeric'},{'>', 0}));
addOptional(iparser,'searchDirection','right',@(x)validateattributes(x,{'char'},{'nonempty'}));
addOptional(iparser,'blockSize',15,@(x)validateattributes(x,{'numeric'},{'>', 2, 'odd'}));

% do parsing and store results rows
parse(iparser,varargin{:});
debug = iparser.Results.debug;
quiet = iparser.Results.quiet;
skipRow = iparser.Results.skipRow;
skipCol = iparser.Results.skipCol;
disparityRange = iparser.Results.disparityRange;
searchDirection = iparser.Results.searchDirection;
blockSize = iparser.Results.blockSize;

if debug
    quiet = false;
end

%% Basic Block Matching

% Calculate the disparity using basic block matching with sub-pixel
% estimation.
% The original Mathworks example code utilized the TemplateMatcher from their
% vision toolbox; I've modified the code to work without this dependency.
nbytes(1) = fprintf(' - Row %d / ', size(leftImage, 1));
nbytes(2) = 0;

% Convert the images from RGB to grayscale by averaging the three color
% channels.
if size(leftImage,3)>1
    leftI = mean(leftImage, 3);
    rightI = mean(rightImage, 3);
else
    leftI = leftImage;
    rightI = rightImage;
end

% disparity will hold the result of the block matching.
% The values will be 'single' precision (32-bit) floating point.
disparity = zeros(size(leftI), 'single');

% Define the size of the blocks for block matching.
halfBlockSize = (blockSize - 1) /2;
%blockSize = 2 * halfBlockSize + 1; Orginal zeile

% Get the image dimensions.
[imgHeight, imgWidth] = size(leftI);

% For each row 'm' of pixels in the image...
for m = 1 : skipRow : imgHeight

	% Set min/max row bounds for the template and blocks.
	% e.g., for the first row, minr = 1 and maxr = 4
    minr = max(1, m - halfBlockSize);
    maxr = min(imgHeight, m + halfBlockSize);

    % For each column 'n' of pixels in the image...
    for n = 1 : skipCol : imgWidth

		% Set the min/max column bounds for the template.
		% e.g., for the first column, minc = 1 and maxc = 4
		minc = max(1, n - halfBlockSize);
        maxc = min(imgWidth, n + halfBlockSize);

		% Define the search boundaries as offsets from the template location.
		% Limit the search so that we don't go outside of the image.
		% 'mind' is the the maximum number of pixels we can search to the left.
		% 'maxd' is the maximum number of pixels we can search to the right.
		%
		% In the "Cones" dataset, we only need to search to the right, so mind
		% is 0.
		%
		% For other images which require searching in both directions, set mind
		% as follows:
        %   mind = max(-disparityRange, 1 - minc);
% 		mind = 0;
%       maxd = min(disparityRange, imgWidth - maxc);
        mind = 0;
        maxd = 0;
        switch searchDirection
              case 'right'
                 mind = 0;
                 maxd = min(disparityRange, imgWidth - maxc);
              case 'left'
                 mind = max(-disparityRange, 1 - minc);
                 maxd = 0;
              case 'both'
                 mind = max(-disparityRange, 1 - minc);
                 maxd = min(disparityRange, imgWidth - maxc);
            otherwise
                 error('disp_block: searchDirection wrong/not defined!!');
        end

		% Select the block from the right image to use as the template.
        template = rightI(minr:maxr, minc:maxc);

		% Get the number of blocks in this search.
		numBlocks = maxd - mind + 1;

		% Create a vector to hold the block differences.
		blockDiffs = zeros(numBlocks, 1);

		% Calculate the difference between the template and each of the blocks.
		for i = mind : maxd

			% Select the block from the left image at the distance 'i'.
			block = leftI(minr:maxr, (minc + i):(maxc + i));

			% Compute the 1-based index of this block into the 'blockDiffs' vector.
			blockIndex = i - mind + 1;

			% Take the sum of absolute differences (SAD) between the template
			% and the block and store the resulting value.
			blockDiffs(blockIndex, 1) = sum(sum(abs(template - block)));
		end

		% Sort the SAD values to find the closest match (smallest difference).
		% Discard the sorted vector (the "~" notation), we just want the list
		% of indices.
		[~, sortedIndeces] = sort(blockDiffs);

		% Get the 1-based index of the closest-matching block.
		bestMatchIndex = sortedIndeces(1, 1);

		% Convert the 1-based index of this block back into an offset.
		% This is the final disparity value produced by basic block matching.
		d = bestMatchIndex + mind - 1;

		% Calculate a sub-pixel estimate of the disparity by interpolating.
		% Sub-pixel estimation requires a block to the left and right, so we
		% skip it if the best matching block is at either edge of the search
		% window.
		if ((bestMatchIndex == 1) || (bestMatchIndex == numBlocks))
			% Skip sub-pixel estimation and store the initial disparity value.
			disparity(m, n) = d;
		else
			% Grab the SAD values at the closest matching block (C2) and it's
			% immediate neighbors (C1 and C3).
			C1 = blockDiffs(bestMatchIndex - 1);
			C2 = blockDiffs(bestMatchIndex);
			C3 = blockDiffs(bestMatchIndex + 1);

			% Adjust the disparity by some fraction.
			% We're estimating the subpixel location of the true best match.
			disparity(m, n) = d - (0.5 * (C3 - C1) / (C1 - (2*C2) + C3));
		end
    end

    delete_bytes(nbytes(2));
    nbytes(2) = fprintf('%d', m);
end

delete_bytes(sum(nbytes));
fprintf('\n');

% Interpolation of values if map is not dense (added by Alex)
if skipRow~=1 || skipCol~=1
    [X_comp, Y_comp] = meshgrid(1 : skipCol : imgWidth,1 : skipRow : imgHeight);
    [X_all, Y_all] = meshgrid(1:imgWidth,1:imgHeight);
    disparity = interp2(X_comp,Y_comp,disparity(1 : skipRow : imgHeight,1 : skipCol : imgWidth),X_all,Y_all);
end

% =========================================
%        Visualize Disparity Map
% =========================================
if debug
    fprintf('Displaying disparity map...\n');


    % Switch to figure 1.
    figure(1);

    % Clear the current figure window.
    clf;

    % Display the disparity map.
    % Passing an empty matrix as the second argument tells imshow to take the
    % minimum and maximum values of the data and map the data range to the
    % display colors.
    image(disparity,'CDataMapping','scaled');

    % Configure the axes to properly display an image.
    axis image;

    % Use the 'jet' color map.
    % You might also consider removing this line to view the disparity map in
    % grayscale.
    colormap('jet');

    % Display the color map legend.
    colorbar;

    % Specify the minimum and maximum values in the disparity map so that the
    % values can be properly mapped into the full range of colors.
    % If you have negative disparity values, this will clip them to 0.
    %caxis([0 disparityRange]);

    % Set the title to display.
    title(strcat('Basic block matching, Sub-px acc., Search right, Block size = ', num2str(blockSize)));
end

end

