%Main function to recognize text from a single text image
function [ recText ] = recognizeText(handles, image,isLADA, letterArea, imageContent,cid,cursorAngle )

    % Indicates the letter areas in the image axes handle
    function drawLetterAreaIndicators (handles,color,rmin, rmax, cmin, cmax)
        %Get the axes of image displayer
        axes(handles.axesIm);
        %Set the size of the indicator to be drawn according to letter size
        indicatorSize = floor((rmax - rmin)/10);
        %Set a low limit so indicator does not get too small
        if indicatorSize < 3
            indicatorSize = 3;
        end
        %Draw the top left indicator
        line([cmin cmin+indicatorSize], [rmin rmin], 'LineWidth', 2.8, 'Color', color);
        line([cmin cmin], [rmin rmin+indicatorSize], 'LineWidth', 2.8, 'Color', color);
        %Draw the bottom right indicator
        line([cmax cmax-indicatorSize], [rmax rmax], 'LineWidth', 2.8, 'Color', color);
        line([cmax cmax], [rmax rmax-indicatorSize], 'LineWidth', 2.8, 'Color', color);
    end


    %Read image
    I = imread(image);
    %Convert to double
    I = im2double( I( :, :, 1 ) );
    se = strel( 'disk', 1 );
    imopened = imopen( I, se );
    
    %Get the boundary box which contains the actual text, cropping the
    %background part
    [rmin rmax cmin cmax croppedNegativeIm] = bbox(imopened);
    %Threshold the image to obtain a binary image
    binaryIm = (1-croppedNegativeIm)>.1;
    [row col] = size( binaryIm ); 
    %{
    filenr=fopen('bin.txt','w');
    for i = 1 : size(binaryIm, 1)
        fprintf(filenr,'%d ',binaryIm(i,:));
        fprintf(filenr,'\n');
    end
    fclose(filenr);
    recText = randseq(randi(10));
    return;
    %}
    %Until we reach the end of the image, continue exhaustively to detect
    %letters
    %Start searching the new letter from the leftmost column
    newLetterStartColumn = 1;
    while 1
        %Get the new letter boundary
        [rminLetter rmaxLetter cminLetter cmaxLetter] = bboxLetter(binaryIm, newLetterStartColumn);
        %If there are no letters left
        if cminLetter == -1
            break;
        end
        %Indicate the boundary box in the image itself
        drawLetterAreaIndicators (handles,'Yellow',rmin + rminLetter, rmin + rmaxLetter, cmin + cminLetter, cmin + cmaxLetter);
        %Set the search start column to where the previous letter ended
        newLetterStartColumn = cmaxLetter + 1;
        %If the previous letter ended at the right border of the image
        %Or in other words if it was the last letter in the image
        if newLetterStartColumn > cmax
            break;
        end
    end    
    recText = randseq(randi(10));
end