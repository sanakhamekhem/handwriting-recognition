%Main function to recognize text from a single text image
function [ recText ] = recognizeText(handles, image,isLADA, letterArea, imageContent,cid,cursorAngle )
    %Read image
    I = imread(image);
    %Display image size in console
    size(I)
    %Get the boundary box which contains the actual text, cropping the
    %background part
    [rmin rmax cmin cmax croppedIm] = bbox(I);
    %Indicate the boundary box in the image itself
    drawLetterAreaIndicators (handles,'Yellow',rmin, rmax, cmin, cmax);
    %Pause for a second for user to view before continuing with another
    %image
    pause(1);
    recText = randseq(randi(10));
    
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
end