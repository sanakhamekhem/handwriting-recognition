function [bingrid, shape] = improcess_m(rawim)
%IMROCESS Processes the image to prepare it for an HMM

% Number of segments
NSEGR = 3;
NSEGC = 3;
% Size of the grids
NRGRIDCELL = 3;
NCGRIDCELL = 3;
% Number of grids
NRWHOLEGRID = NSEGR*NRGRIDCELL;
NCWHOLEGRID = NSEGC*NCGRIDCELL;
% Value for each pixel to be counted on as white (a piece of the shape)
THETA = .1;

% THE CODE

%Crop to text area
[~, ~, ~, ~, negative] = bbox( rawim );
%Resize the image to size of NRWHOLEGRID to NCWHOLEGRID (size of the shape)
%imresize does the pixel interpolation automatically, so there are no
%leftover cells
resized = imresize(negative, [NRWHOLEGRID NCWHOLEGRID])
%Threshold and achieve binary image
shape = (1-resized)>THETA;

bingrid = zeros( NSEGR, NSEGC );

for i = 1 : NRWHOLEGRID
    binI = floor((i-1)/NRGRIDCELL)+1;
    for j = 1 : NCWHOLEGRID
        binJ = floor((j-1)/NCGRIDCELL)+1;
        bingrid(binI, binJ) = bingrid(binI, binJ) * 2 + shape(i,j);
    end
end