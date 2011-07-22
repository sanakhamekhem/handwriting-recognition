function supervise
%The runnable file. Reads an image, gets the size, extracts the edges,
%   finds the bounding box by cropping to the minimum possible square,
%   divides the image into several equisized parts.



%   TODO: to move the sizes and numbers of the segements from 'improcess'
%   to this file
close all;
clear all;
start = 'a';
finish = 'z';
index = 0;
for i = start:finish
    % Prepare the image s
    img = im2double(imread(strcat('Q', i, '.jpg')));
    [bingrid, shape] = improcess(img(:, :, 1));
    index = index+1;
    subplot(4, 7, index);
    imshow(shape);
end