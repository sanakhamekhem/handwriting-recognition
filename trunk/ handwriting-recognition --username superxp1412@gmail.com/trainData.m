function  [ hmmsParam ] = trainData(handles,folder_path,models)
    
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
    %Get the number of HMM Models to trained
    nmodels = size(models, 1);
    %Allocate the storage for training result, each HMM model separately
    training_results = cell(nmodels,1);
    for i = 1 : nmodels
        training_results{i} = zeros(nimages, models{i}.obsMatrixSize);
    end
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
        %Run the HMM Models
        observations = letterObservations();
        %{
        for j = 1 : nmodels
            %Get the observation extraction function
            oef = eval(['@' models{j}.obsExtractionFunc]);  %# Concatenate string name with '@' and evaluate
            observations = oef(img,1);
            %observations = count_segments(img,1);
            %Store the result
            training_result{j}(i,:) = observations(:);
        end
        %}
        training_results (1:nmodels) = observations;
    end
    %OBSOLETE
    %training_result = (training_result==0)+training_result
    %training_result
    hmmsParam = cell(nmodels,1);
    %Train HMM according to training results we have achieved
    for i = 1 : nmodels
        %Get models parameters M and N
        N = models{i}.N;
        M = models{i}.M;
        [ prior, transmat, obsmat ] = trainHMM (training_results, M, N);
        hmmsParam(i) = {M, N, prior, transmat, obsmat};
    end
end

