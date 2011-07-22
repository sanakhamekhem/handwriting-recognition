function improcess
%IMROCESS Processes the image to prepare it for an HMM

clear all;
close all;

% Number of segments
NRSEG = 3;
NCSEG = 2;
NSEG = NRSEG*NCSEG;
% Size of the grids
NRGRID = 3;
NCGRID = 3;
% Number of grids
NGRIDR = NRSEG*NRGRID;
NGRIDC = NCSEG*NCGRID;
% The percentage of the pixels in a map that are allowed to be white
% before we count on the map as a colored one
THRESH = .35;

% TODO: change numbers above and find the optimal resolution

% THE CODE

rawim = imread( 'T.jpg' ); %figure(900), imshow(rawimg);
im = im2double( rawim( :, :, 1 ) );
figure( 1000 ), imshow( im );
se = strel( 'disk', 1 );
imopened = imopen( im, se );  figure( 2500 ), imshow( imopened );
imedge = im2double( edge( im,'Canny' ) ); figure( 2000 ), imshow( imedge );
% % % imedge = [0 0 0 1 1;0 0 0 1 1;0 1 1 1 1; 0 1 1 1 1;0 1 1 1 1;0 1 1 1 1
% % % ;0 0 0 0 0]
[~, ~, ~, ~, negative] = bbox( imopened );
figure( 3000 ), imshow( negative );
imcrop = (1-negative)>.1;
figure( 4000 ), imshow( imcrop );
[row col] = size( imcrop )
% % % c = CD-mod(C,CD);
% % % size(imedge)
% % % imedge = [imedge ones(R, c)];
% % % r = RD-mod(R, RD);
% % % impad = [imedge; ones(r, C+c)];
% % % [R C] = size(impad);
rowdepo = mod( row, NRGRID )
coldepo = mod( col, NCGRID )
% % % imseg = zeros( NRSEG, NCSEG, NSEG );
bingrid = zeros( NRSEG, NCSEG );

% Size of the maps
NRMAP = floor( row/NGRIDR );
NCMAP = floor( col/NGRIDC );
% % % figure;
index = 0;
shape = zeros( 1, 1 );

for i = 1:NRSEG
    roverture = rowdepo > 0; % TODO: USE IT
    rowdepo = rowdepo-1;
    for j = 1:NCSEG
        coverture = coldepo > 0; % TODO: USE IT
        coldepo = coldepo-1;
        for k = 1:NRGRID
            for l = 1:NCGRID
%disp('----------------')
                A = bingrid( i, j );
                fstrow = ( ( i-1 )*NRGRID+k-1 )*NRMAP+1;
                lstrow = ( ( i-1 )*NRGRID+k )*NRMAP;
                fstcol = ( ( j-1 )*NCGRID+l-1 )*NCMAP+1;
                lstcol = ( ( j-1 )*NCGRID+l )*NCMAP;
                %imcrop( fstrow:lstrow, fstcol:lstcol );
                imshow(imcrop(fstrow:lstrow, fstcol:lstcol ));
                summa = sum( sum( imcrop( fstrow:lstrow, fstcol:lstcol ) ) );
                maparea = ( lstrow-fstrow+1 )*( lstcol-fstcol+1 );
% % %                 F = imcrop( ( ( i-1 )*NRGRID+k-1 )*NRMAP+1:...
% % %                     ( ( i-1 )*NRGRID+k )*NRMAP,...
% % %                     ( ( j-1 )*NCGRID+l-1 )*NCMAP+1:...
% % %                     ( ( j-1 )*NCGRID+l )*NCMAP)
                bingrid( i, j ) = bingrid( i, j )*2+...
                    ( sum( sum( imcrop( fstrow:lstrow, fstcol:lstcol ) ) )...
                    /maparea > THRESH );
%                 ( i-1 )*NRGRID+k
%                 ( i-1 )*NRGRID+k
%                 ( j-1 )*NCGRID+l-1
%                 ( j-1 )*NCGRID+l
   % % %                 index = index+1;
% % %                 pause(2)
% % %                 subplot(9,6,index), imshow(imcrop( fstrow:lstrow, fstcol:lstcol ) );
            end
        end
    end
    %bingrid
                %dec2bin(bingrid)
end
close all
bingrid
%dec2bin(bingrid)

% TODO: fix the representation