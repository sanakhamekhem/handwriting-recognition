function [ observations ] = count_segments( I)
    % The number of slices
    DIV = 6;

    I = I(:, :, 1);
    size_i = size(I,2);
    
    % Extract the edges
    I = edge(I,'sobel');

    % Crop it to cover the whole canvas
    [~, ~, ~, ~, I] = bbox(1-I);
    I = 1-I;
    
    % Resize it to width that is divisible by DIV
    newwidth = size(I,2)+DIV-mod(size(I,2), DIV);
    % Resize according to newwidth, Nan indicates row number is dependent
    % on the aspect ratio
    res = imresize(I, [NaN newwidth]);
    size_res = size(res, 2);
    
    piecewidth = size_res/DIV;
    
    % Allocate storage for observations
    observations = zeros(1,DIV);
    
    % Divide it into DIV images
    for j = 1:DIV
        if(show)
            subplot(1,DIV,j);
        end
        I = res(:,(j-1)*piecewidth+1:j*piecewidth)>.1;
        observations(j) = imedgesegments(I,show);
    end

