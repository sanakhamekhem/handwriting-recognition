%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Application data stored at handles.figure1
% 1) images = [pathName fileName] - name of the directory, followed by the
% names of image file names
% 2) inputLength - length of the selected images
% 3) executionStatus -  I.   Waiting for images to be selected
%                       II.  Images selected, ready for execution
%                       III. Executing
%                       IV.  Finish executing (the same state II, might be
%                       useful later.
% 4) trainingData - extracted observations from the training data
%
% Missing functionality/Possible performance improvements
% 1) Cursor inclination change is not very optimized - too many cos and sin
% calls - redundant operations
% 2) There is no error measurement
% 3) Most radiobuttons functionality missing - ie manual letter area
% detection, only when fixed angle selected cursor angle could be modified
% 4) recognizeText can get input as a struct which would better comply to 
% later changes
% 5) The main figure showing the selected image can continue including
% ticks in x and y dimension just as before images are selected
% 6) Naming of UIComponents (textboxes, labels, buttons) can be updated -
% from listbox2 to lbStatusBox for example
% 7) Reading of execution options (radiobuttons, related editboxes) should
% be done in iteration loop, rather than pre-iteration hence if options
% change between two consecutive images, they are reflected.
% 8) Cursor drawing at the start should include the red orientation line
% and arrow
% 9) Play,rewind,forward,pause options
%   i.Sample execution button better be replaced by play button
%
% OPTIONAL
% O1) Maximized screen, check visual consistency in different resolutions
% O2) Timestamps can be added to status bar messages
% O3) When a status bar message is clicked, it may lead to corresponding
% image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = gui(varargin)
    % GUI M-file for gui.fig
    %      GUI, by itself, creates a new GUI or raises the existing
    %      singleton*.
    %
    %      H = GUI returns the handle to a new GUI or the handle to
    %      the existing singleton*.
    %
    %      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GUI.M with the given input arguments.
    %
    %      GUI('Property','Value',...) creates a new GUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before gui_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to gui_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help gui

    % Last Modified by GUIDE v2.5 24-Jul-2011 03:08:17

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end

% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to gui (see VARARGIN)

    % Choose default command line output for gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    %Set execution status
    setappdata(handles.figure1, 'executionStatus', 1);

    %Set the possible value range of slider 2 (which adjusts the fixed 
    %cursor inclination angle) to [0,180]
    set(handles.slider2, 'Min', 0);
    set(handles.slider2, 'Max', 180);
    set(handles.slider2, 'SliderStep', [5/180.0 5/180.0]);
    set(handles.slider2, 'Value', 90);
    
    setStatus(handles, {'No images selected yet'});

    % UIWAIT makes gui wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
    % hObject    handle to uipushtool1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    %%Calls the customized open file dialog, only images are allowed and
    %%multiple selection is enabled
    [fileName, pathName] = uigetfile({'*.png;*.jpg;*.jpeg','Images (*.png,*.jpg)'; ...
               '*.*',        'All Files (*.*)'},'multiselect','on');

    %%Control the flow according to user action

    %%User did not select a file
    if isequal(fileName,0)
        return;
    %User selected multiple files    
    elseif iscellstr(fileName)
        setStatus(handles,'Multiple files are selected');
    %User selected one image file
    elseif ischar(fileName)
        setStatus(handles,'Single file selected');
        %change the structure of filename to string array of size 1
        %benefit is to process the array the same as multiple files are
        %selected. Input check or different procedure is not needed.
        fileName = {fileName};
    end

    %Store filenames and path in application data
    setappdata(handles.figure1, 'images', [pathName fileName]);

    %Set the slider's properties
    inputLength = size(fileName,2);

    %Store that in application data for later use
    setappdata(handles.figure1, 'inputLength', inputLength);

    %Display the first selected image file on the GUI
    %Other images can be accessed by using the slider
    setDisplayedImage(handles,1);

    %Set execution status
    setappdata(handles.figure1, 'executionStatus', 2);

    %Fill images table
    tableData = cell(inputLength(1), 3);
    %Set the first columns as the image file names
    tableData(:,1) = transpose(fileName);
    %Set the second column (target output) as '' so it is editable later
    %If we don't do so, edited text becomes 'nan'. Weird of MATLAB
    tableData(:,2) = {''};
    set(handles.uitable1, 'Data', tableData);

    %Check if target output data is available (is text.txt available on the
    %folder)
    %strPathName = cellstr(pathName);
    oldFolder = cd(pathName);
    if ismember({'text.txt'},ls)
        %Read target data from text.txt
        [targetImages correctOutput] = textread([pathName 'text.txt'],'%s %s', 'delimiter' , '|');
        %Fetch the correct results if available
        updatedTable = keyUpdate(handles.uitable1, 1, targetImages, 2, correctOutput);
    end
    %Return back to old folder
    cd(oldFolder);

    %Set properties of the slider based on whether multiple files or single
    %file selected
    if inputLength > 1
        set(handles.slider1,'Enable', 'on');
        set(handles.slider1,'Min',1);
        set(handles.slider1,'Max',size(fileName,2));
        set(handles.slider1,'SliderStep', [1/(size(fileName,2)-1) 0]);
        set(handles.slider1,'Value',1);
    else
        set(handles.slider1, 'Enable', 'off');
    end
end

%There is no predefined way to update single cells in matlab
%We define our own - AND IT IS NOT TESTED AND NOT WORKING 
function updateTableCells(tableHandle, update)
    [rows columns newData] = update;
    %Get previous table data
    tableData = get(tableHandle, 'Data');
    %Get the row and column count for processing
    [rowCount columnCount] = size(tableData); 
    %Iterate through the cells
    for i = 1 : rowCount
        for j = 1 : columnCount
            %If this cell is inside the list of updated cells
            if ismember([i j], [rows columns])
                %Update to new value
                tableData{i,j} = newData;
            end
        end
    end
end

%Update the cell of a table given a search field, search value, and content
% and position of new data
function tableData = keyUpdate(tableHandle, keyIndex, keys, changedField, newData)
    tableData = get(tableHandle, 'Data');
    %Get the row count
    rowCount= size(tableData, 1);
    %Search the corresponding row in the table
    for i = 1 : rowCount
        [tf loc] = ismember(tableData{i,keyIndex},keys);
        if tf
            tableData{i, changedField} = newData{loc};
        end
    end
    %Update the table using the given handle
    set(tableHandle, 'Data', tableData);
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

    %Check if images are selected
    if getappdata(handles.figure1, 'executionStatus') ~= 1
        %Get the new index
        index = get(hObject, 'Value');
        %Change selected item in the uitable
        % NOT ALLOWED IN MATLAB
        %set(handles.listbox1, 'Value', index); 
        %Change the displayed picture
        setDisplayedImage(handles, index);
    else
        set(hObject, 'Enable', 'off');
        set(handles.uitable1, 'Enable', 'off');
    end
end

%Specify the displayed image in the GUI, input is the index of the image
%among all images read
function setDisplayedImage(handles,index)

    %Retrieve application data
    fileName = getappdata(handles.figure1,'images');
    inputLength = getappdata(handles.figure1,'inputLength');
    pathName = fileName{1};

    %Input validity check
    if inputLength==0 || index > inputLength
        fprintf('No such image\n');
    end

    I = imread([pathName,fileName{index+1}]);
    %Select the axes
    axes(handles.axesIm);
    %Show the image
    imshow(I, 'Parent', handles.axesIm);
end

function setStatus(handles, newStatus)
    set(handles.listbox2, 'String', newStatus);
end


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
end

% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to axes3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: place code in OpeningFcn to populate axes3
    axes(hObject);
    %Draw the cursor default at 90 degrees
    line([0 0], [-0.7 0.7], 'LineWidth', 2.8)
end

%Function to draw the cursor on display when inclination has changed
function drawCursor(handles, angle)
    %Get the axes of cursor and clear previous drawings

    axes(handles.axes3);
    cla;

    %%TODO clear the earlier cursor line

    %%TODO correct the angles
    % Cursor line will have length of 1 and middle point of it will be origin
    % Draw the cursor line in two halves
    line([cos(angle/180*pi)*0.7 0], [sin(angle/180*pi)*0.7 0], 'LineWidth', 2.8);
    line([0 -cos(angle/180*pi)*0.7], [0 -sin(angle/180*pi)*0.7], 'LineWidth', 2.8);
    % Draw the orthogonal line to cursor line to depict the reading direction
    line([0 cos(angle/180*pi - pi/2)*0.5],[0 sin(angle/180*pi - pi/2)*0.5],'LineWidth',2.1, 'Color', 'Red');
    line([cos(angle/180*pi - pi/2)*0.5 cos(angle/180*pi - pi/2 + pi/4)*0.5],[sin(angle/180*pi - pi/2)*0.5 sin(angle/180*pi - pi/2 + pi/4)*0.5],'LineWidth',2.1, 'Color', 'Red');
    line([cos(angle/180*pi - pi/2)*0.5 cos(angle/180*pi - pi/2 - pi/4)*0.5],[sin(angle/180*pi - pi/2)*0.5 sin(angle/180*pi - pi/2 - pi/4)*0.5],'LineWidth',2.1, 'Color', 'Red');
end

% --- Executes on button press in btnRecognize.
function btnRecognize_Callback(hObject, eventdata, handles)
    % hObject    handle to btnRecognize (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    %Get the eligibility for operation
    es = getappdata(handles.figure1, 'executionStatus');
    if es == 2 % Check the top of document for execution status enumeration
        set(hObject, 'UserData', 0);
        appendStatus(handles, 'Execution started');
        executionDelegate(handles);
    elseif es == 3 
        % Operation in process, user pressed the button to continue 
        % with the next image
        set(hObject, 'UserData', 1);
    elseif es == 4
        %One pass through selected images is finished and we are starting a new
        %one
        clearGUIFromPreviousData(handles);
        %Update the status bar
        appendStatus(handles, '');
        appendStatus(handles, 'Previously selected images and options retained');
        appendStatus(handles, 'Execution started');
        %Set the status back to image selected
        setappdata(handles.figure1, 'executionStatus', 2);
        executionDelegate(handles);
    end
end

function clearGUIFromPreviousData(handles)
    %Clear recognized field of the uitable
    tableData = get(handles.uitable1, 'Data');
    tableData(:,3) = {''};
    set(handles.uitable1, 'Data', tableData);
end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)

    % hObject    handle to edit1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function edit1_Callback(hObject, eventdata, handles)
    % hObject    handle to edit1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % Hints: get(hObject,'String') returns contents of edit1 as text
    %        str2double(get(hObject,'String')) returns contents of edit1 as a double

    value = str2double(get(hObject,'String'));
    %Check the validity of entered angle value - it should be in range [0,180]
    if value >= 0 && value <=180
        %Adjust the slider value
        set(handles.slider2, 'Value', value);
        %Draw the cursor
        drawCursor(handles,value);
    end
end

% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
    % hObject    handle to uitable1 (see GCBO)
    % eventdata  structure with the following fields (see UITABLE)
    %	Indices: row and column indices of the cell(s) currently selecteds
    % handles    structure with handles and user data (see GUIDATA)
    %Check if images are selected
    if getappdata(handles.figure1, 'executionStatus') ~= 1
        %Get the new index
        index = eventdata.Indices(:,1);
        %For whatever reason event is triggered twice sometimes, so we check
        %the validity of the eventdata;
        if isempty(index)
            return;
        end    
        %Set the image slider's value accordingly
        set(handles.slider1, 'Value', index);
        %Change the displayed picture
        setDisplayedImage(handles, index);
    else
        set(hObject, 'Enable', 'off');
        set(handles.slider1, 'Enable', 'off');
    end
end

% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)

    % hObject    handle to uitable1 (see GCBO)
    % eventdata  structure with the following fields (see UITABLE)
    %	Indices: row and column indices of the cell(s) edited
    %	PreviousData: previous data for the cell(s) edited
    %	EditData: string(s) entered by the user
    %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
    %	Error: error string when failed to convert EditData to appropriate value for Data
    % handles    structure with handles and user data (see GUIDATA)

    %Check if data is loaded
    if getappdata(handles.figure1, 'executionStatus') ~= 1
        index = eventdata.Indices;
        %Check the edited cell, it should be correct output column that is
        %changed. 
        %ps: Actually we have already assured that by setting only the second 
        %column as editable but this may later change, hence it is better to double check 
        if index(2) == 2
            %Get the file name
            tableData = get(handles.uitable1,'Data');
            images = getappdata(handles.figure1, 'images');
            pathName = images{1};

            fid=fopen(sprintf('%s%s',pathName, 'text.txt'),'wt');
            rows=size(tableData,1);
            for i=1:rows
                fprintf(fid,'%s|%s\n',tableData{i,1},tableData{i,2})
            end

            fclose(fid);
        end

    else
        set(hObject, 'Enable', 'off');
        set(handles.slider1, 'Enable', 'off');
    end
end

%Call the recognition 
function executionDelegate(handles)
    %Get the execution mode whether it is continuous or paused between
    %images
    isContinuous = get(handles.radiobutton18,'Value');
    %is letter area detected automatically or manually set by user
    isLADA = get(handles.radiobutton7,'Value');
    letterArea = 0;
    %Get image content 1:Automatic 2:Multiple Words/Sentences 3:Single Word
    %4:Single Letter
    imageContent = 0;
    if get(handles.radiobutton6, 'Value')
        imageContent = 1;
    elseif get(handles.radiobutton5, 'Value')
        imageContent = 2;
    elseif get(handles.radiobutton4, 'Value')
        imageContent = 3;
    elseif get(handles.radiobutton3, 'Value')
        imageContent = 4;
    end
    %Cursor inclination detection 1:Automatic Detection 2:Manual 3:Fixed
    %@ an angle
    cid = 0; cursorAngle = 0;
    if get(handles.radiobutton12, 'Value')
        cid = 1;
    elseif get(handles.radiobutton11, 'Value')
        cid = 2;
        cursorAngle = getappdata(handles.figure1, 'manualCursorAngle');
    elseif get(handles.radiobutton13, 'Value')
        cid = 3;
        cursorAngle = get(handles.slider2, 'Value');
    end;
    %Should the program evaluate and update precision - recall - fscore
    %values
    isEvaluated = get(handles.radiobutton16, 'Value');
    
    %Set execution status to 'operating now'
    setappdata(handles.figure1, 'executionStatus', 3);
    inputLength = getappdata(handles.figure1, 'inputLength');
    images = getappdata(handles.figure1, 'images');
    pathName = images{1};
    %Call the main recognition function - message radiobutton selections
    %and image file name as input and collect recognized text as output
    for i = 1 : inputLength
        %Set the slider value accordingly
        set(handles.slider1, 'Value', i);
        %View the image to be recognized
        setDisplayedImage(handles, i);
        recognizedText = recognizeText(handles,[pathName,images{i+1}],isLADA, letterArea, imageContent,cid,cursorAngle);
        %Update the table @ui
        keyUpdate(handles.uitable1, 1, images(i+1), 3, {recognizedText});
        %and the status bar
        appendStatus(handles, sprintf('Image %d(%d) recognized as %s', i, inputLength, recognizedText));
        %Pause for a second for user to view before continuing with another
        %image
        pause(1);
        if isEvaluated
        end
        if ~isContinuous
            %Wait for user to press the button
            waitfor(handles.btnRecognize, 'UserData', 1);
            %Set the value back to 0 -corresponds to not pressed yet-
            set(handles.btnRecognize, 'UserData', 0);
        end
    end
    
    %Set execution status to finished 
    setappdata(handles.figure1, 'executionStatus', 4);
    %and update the status bar
    appendStatus(handles,'Recognition process completed');
end
    
% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
    % hObject    handle to slider2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

    %Get the new value
    value = get(hObject, 'Value');
    %Update the value in editbox
    set(handles.edit1, 'String' , num2str(value));
    %Draw the cursor at new angle
    drawCursor(handles, value);
end

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to listbox2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    end
end 


% --- Executes on key press with focus on btnRecognize and none of its controls.
function btnRecognize_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to btnRecognize (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
end


% --- Executes on button press in btnTrain.
function btnTrain_Callback(hObject, eventdata, handles)
    % hObject    handle to btnTrain (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %Store the source codes directory as we are going to navigate to
    %training data directories
    sourceCodeDirectory = pwd;
    %Open dialog for user to select the training data location
    folder_name = uigetdir(pwd,'Select training data folders');
    %Navigate to that folder
    cd(folder_name);
    %Get the training data folder names and trim the result because it
    %always contains . and .. for each listing
    lsm = ls;
    trainingDataFolders = lsm(3:size(lsm), :);
    validFolders = [];
    index = 1;
    %Check the validity of folder names, they should be single letter for
    %capital letters and _x for lowercase letters.
    for i = 1 : size(trainingDataFolders)
        lf = trainingDataFolders(i,:);
        if size(lf) > 2
            continue;
        elseif ~(isletter(lf(1)) || lf(1) == '_')
            continue;
        else
            validFolders(index,:) = lf;
            index = index + 1;
        end
    end
    
    %number of different letters to be trained
    nletter = size(validFolders);
    %training data consists of folder path, number of images in the folder,
    %actual letter, training results, 
    trainingData = cell(nletter, 4);
    %Hide the axes for test images and show the uipanel for subplot of
    %training images
    set(handles.axesIm, 'Visible', 'off');
    set(handles.uipanel7, 'Visible', 'on');
    for i = 1 : nletter
        %Concatenate the master folder path with the current folders name
        folder_path = strcat(folder_name,'\', validFolders(i,:));
        trainingData {i,1} = folder_path;
        
        %Go to that folder
        cd(folder_path);
        %Get the number of images in the folder
        trainingData {i,2} = size(ls,1)-2;
        
        %Get the specific letter whose data we are training atm
        %capital letters have folders named as A, B, C
        %lowercase letters have folders named as _a, _b due to case
        %insensitive nature of operating systems
        letter_folder_name = validFolders(i,:);
        if letter_folder_name(1) == '_'
            letter = letter_folder_name(1,2);
        else
            letter = letter_folder_name(1);
        end
        trainingData {i,3} = letter;
        
        %Go back to source code directory so that it can call other
        %functions
        cd(sourceCodeDirectory);
        
        %Train the data
        trainingData {i,4} = trainData(handles,folder_path);
        
        %Pause for users to view
        pause(0.5);
        %Then clear the axes
        %set(handles.uipanel7, 'Children', []);
        
    end
    %Back to source code directory
    cd(sourceCodeDirectory);
    %Display the axes for test images which was hidden before and hide the
    %uipanel7 which was used to show training data segmentation results
    set(handles.axesIm, 'Visible', 'on');
    set(handles.uipanel7, 'Visible', 'off');
    
    %Store the training data observations for later use in HMM
    setappdata(handles.figure1, 'trainingData', trainingData);
    
end

% --- Executes on button press in btnClearTrn.
function btnClearTrn_Callback(hObject, eventdata, handles)
    % hObject    handle to btnClearTrn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    %Clear the training data
    setappdata(handles.figure1, 'trainingData', []);

end
