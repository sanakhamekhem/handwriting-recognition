function  [ hmmParam ] = trainData(handles,folder_path)
    %Get the source code folder
    sourceCodeDirectory = pwd;
    %Go to training data's folder
    cd(folder_path);
    %Get the image names and shrink the list so it does not include . and ..
    lsm = ls;
    trainingImages = lsm(3:size(lsm), :);
    validImages = [];
    index = 1;
    %Get the valid images among all files in the folder (ie exclude .svn
    %file etc)
    for i = 1 : size(trainingImages)
        lf = trainingImages(i,:);
        if  lf(1) == '.'
            continue;
        else
            validImages(index,:) = lf;
            index = index + 1;
        end
    end
    
    %Go back to source code directory
    cd(sourceCodeDirectory);
    
    %Get the number of images
    nimages = size(validImages,1);
    %Allocate the storage for training result
    training_result = zeros(nimages,9);
    index = 1;
    %Number of rows in the plot, there will be three different images in
    %each of them
    plotRows = ceil(nimages/3);
    %Create a new panel to draw the letter feature extraction results
    axes(handles.axesIm);
    %figure to show segmented letters
    %figure('Name', 'Segmented Letters');
    %Iterate through images
    for i = 1 : nimages
        %Read the image
        img = im2double(imread(strcat(folder_path,'\', validImages(i,:))));
        %Process the image (trim the white spaces, segment it and compute bingrid
        [bingrid, shape] = improcess(img(:, :, 1));
        subplot(plotRows,3, index,'Parent',handles.uipanel7);
        imshow(shape);
        training_result(index,:) = bingrid(:)';
        index = index+1;
    end
    training_result = (training_result==0)+training_result
    %Train HMM according to training results we have achieved
    [ M, N, prior, transmat, obsmat ] = trainHMM (training_result);
    hmmParam = {M, N, prior, transmat, obsmat};
end

