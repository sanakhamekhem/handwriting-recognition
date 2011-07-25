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

    %Saves binary image to txt file, 0s are written as space character and
    %1s are written as 8s.
    function saveMatrixToFile(matrix)
        filenr=fopen('bin.txt','w');
        for i = 1 : size(binaryIm, 1)
            for j = 1 : size(binaryIm, 2)
                if binaryIm(i,j) == 1
                    fprintf(filenr,'8',binaryIm(i,:));
                else
                    fprintf(filenr,' ',binaryIm(i,:));
                end
            end
            fprintf(filenr,'\n');
        end
        fclose(filenr);
    end

    %Read image
    img = imread(image);
    %Convert to double
    img = im2double( img( :, :, 1 ) );
    
    %Get the boundary box which contains the actual text, cropping the
    %background part
    [rmin rmax cmin cmax croppedNegativeIm] = bbox(img);
    %Threshold the image to obtain a binary image
    binaryIm = (1-croppedNegativeIm)>.1;
    [row col] = size( binaryIm ); 
    
    %Write the binary image to a file to check the column numbers manually
    %ie where the letters start and end, is there any overlap in neighbor
    %letters
    %saveMatrixToFile(binaryIm);
    
    %Until we reach the end of the image, continue exhaustively to detect
    %letters
    %Start searching the new letter from the leftmost column
    newLetterStartColumn = 1;
    %Count the letter index starting from 1 and ending is indefinite atm
    index = 1;
    recText = '';
    while 1
        %Get the new letter boundary
        [rminLetter, rmaxLetter, cminLetter, cmaxLetter, cropped] = bboxLetter(binaryIm, newLetterStartColumn);
        %If there are no letters left
        if cminLetter == -1
            break;
        end
        %Indicate the boundary box in the image itself
        drawLetterAreaIndicators (handles,'Yellow',rmin + rminLetter, rmin + rmaxLetter, cmin + cminLetter, cmin + cmaxLetter);
        %OBSOLETE Method to extract observation
        %Extract observations from the test image
        %[bingrid, ~] = improcess(img((rmin+rminLetter) : (rmin+rmaxLetter), (cmin+cminLetter):(cmin+cmaxLetter)));
        %bingrid(:)'
        observations = count_segments(img((rmin+rminLetter) : (rmin+rmaxLetter), (cmin+cminLetter):(cmin+cmaxLetter)),0);
        %Get hmm parameters for each model
        trainingData = getappdata(handles.figure1, 'trainingData');
        %Check the likelihood of each HMM model
        for i = 1 : size(trainingData, 1)
            hmmParams = trainingData{i,4};
            loglik(i) = dhmm_logprob(observations, hmmParams{3}, hmmParams{4}, hmmParams{5});
            appendStatus(handles, sprintf('Log likelihood letter is %c : %.2f', trainingData{i,3}, loglik(i)));
        end
        %Find which letter was most probable
        [C,I] = max(loglik);
        %If most probable candidate has -Inf likelihood then recognition
        %yielded no results
        if C == -Inf
            recText = [recText '-'];
            appendStatus(handles,sprintf('No suitable letter found for letter candidate %d',index));
        else
            recText = [recText trainingData{I,3}];
            appendStatus(handles,sprintf('Possible candidate for letter #%d is %c', index, trainingData{I,3}));
        end
        
        pause(0.5);
        
        %Set the search start column to where the previous letter ended
        newLetterStartColumn = cmaxLetter + 1;
        %Increment the letter count
        index = index + 1;
        %If the previous letter ended at the right border of the image
        %Or in other words if it was the last letter in the image
        if newLetterStartColumn > cmax
            break;
        end
    end
end