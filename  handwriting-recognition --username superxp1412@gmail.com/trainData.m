function  [training_result] = trainData(folder_path )

%Go to training data's folder
cd(folder_path);
%Get the image names and shrink the list so it does not include . and ..
lsm = ls;
trainingImages = lsm(3:size(lsm), :);
%Get the number of images
nimages = size(trainingImages,1);
%Allocate the storage for training result
training_result = zeros(nimages,9)
%Iterate through images
for i = 1 : nimages
    %Read the image
    img = im2double(imread(strcat(folder_path,'\', trainingImages(i,:))));
    %Process the image (trim the white spaces, segment it and compute bingrid
    [bingrid, shape] = improcess_m(img(:, :, 1));
    index = index+1;
    subplot(3,2, index);
    imshow(shape);
    training_result(index,:) = bingrid(:)';
end
training_result = (training_result==0)+training_result;
%{
%data1 represent the test data
 data1=[1,219,4,1,360,294,66,1,411]
hmm
%}

end

