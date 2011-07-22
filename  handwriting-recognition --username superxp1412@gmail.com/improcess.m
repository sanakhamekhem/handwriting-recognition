function [bingrid, shape] = improcess(rawim)
%IMROCESS Processes the image to prepare it for an HMM

% Number of segments
NSEGR = 3;
NSEGC = 3;
% Size of the grids
NRGRID = 3;
NCGRID = 3;
% Number of grids
NGRIDR = NSEGR*NRGRID;
NGRIDC = NSEGC*NCGRID;
% The percentage of the pixels in a map that are allowed to be white
% before we count on the map as a colored one
THRESH = .35;
% Value for each pixel to be counted on as white (a piece of the shape)
THETA = .1;

% THE CODE

% % rawim = imread( im );
% % se = strel( 'disk', 1 );
% % imopened = imopen( im, se );
% % imedge = im2double( edge( im,'Canny' ) );
[~, ~, ~, ~, negative] = bbox( rawim );
imcrop = (1-negative)>THETA;
[row col] = size( imcrop );
rowdepo = mod( row, NRGRID );
coldepo = mod( col, NCGRID );
bingrid = zeros( NSEGR, NSEGC );

% Size of the maps
NRMAP = floor( row/NGRIDR );
NCMAP = floor( col/NGRIDC );
shape = zeros( NGRIDR, NGRIDC );
for i = 1:NSEGR
    roverture = rowdepo > 0; % TODO: USE IT
    rowdepo = rowdepo-1; 
    for j = 1:NSEGC
        coverture = coldepo > 0; % TODO: USE IT
        coldepo = coldepo-1;
        for k = 1:NRGRID
            for l = 1:NCGRID
                fstrow = ( ( i-1 )*NRGRID+k-1 )*NRMAP+1;
                lstrow = ( ( i-1 )*NRGRID+k )*NRMAP;
                fstcol = ( ( j-1 )*NCGRID+l-1 )*NCMAP+1;
                lstcol = ( ( j-1 )*NCGRID+l )*NCMAP;
                maparea = ( lstrow-fstrow+1 )*( lstcol-fstcol+1 );
                shape( ( i-1 )*NRGRID+k,( j-1 )*NCGRID+l ) = ...
                    ( sum( sum( imcrop( fstrow:lstrow, fstcol:lstcol ) ) )...
                    /maparea > THRESH );
                bingrid( i, j ) = bingrid( i, j )*2+...
                    shape( ( i-1 )*NRGRID+k,( j-1 )*NCGRID+l );
            end
        end
    end
end