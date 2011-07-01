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

% Last Modified by GUIDE v2.5 01-Jul-2011 05:52:21

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

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%Set this variable to 0 if no debugging print is needed, else 1
debugModeForPrinting = 1;

%%Calls the customized open file dialog, only images are allowed and
%%multiple selection is enabled
[fileName, pathName] = uigetfile({'*.png;*.jpg;*.jpeg','Images (*.png,*.jpg)'; ...
           '*.*',        'All Files (*.*)'},'multiselect','on');

%%Control the flow according to user action

%%User did not select a file
if isequal(fileName,0)
    if debugModeForPrinting
        return;
    end;
%User selected multiple files    
elseif iscellstr(fileName)
    if debugModeForPrinting
        setStatus(handles,'Multiple files are selected');
    end;
%User selected one image file
elseif ischar(fileName)
    if debugModeForPrinting
        setStatus(handles,'Single file selected');
        %change the structure of filename to string array of size 1
        %benefit is to process the array the same as multiple files are
        %selected. Input check or different procedure is not needed.
        fileName = {fileName};
    end;    
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
    set(handles.listbox1, 'Enable', 'off');
end

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
%Update the resolution -- NOT VERY EFFICIENT ATM
tableData = get(handles.uitable1, 'Data');
%Select the axes
axes(handles.axesIm);
%Show the image
imshow(I, 'Parent', handles.axesIm);

function setStatus(handles, newStatus)
set(handles.text3, 'String', newStatus);

function appendStatus(handles, addedStatus)
oldStatus = get(handles.text3, 'String');
set(handles.text3, 'String', [oldStatus '\n' addedStatus]); 

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3
axes(hObject);
%Draw the cursor default at 90 degrees
line([0 0], [-0.7 0.7], 'LineWidth', 2.8)

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

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get the eligibility for operation
es = getappdata(handles.figure1, 'executionStatus');
if es == 2 % Check the top of document for execution status enumeration
    appendStatus(handles, 'Execution started');
end

% --- Executes on key press with focus on pushbutton1 and none of its controls.
function pushbutton1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton3


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton4


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton5


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton6


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


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%Get the new value
value = get(hObject, 'Value')
%Update the value in editbox
set(handles.edit1, 'String' , num2str(value));
%Draw the cursor at new angle
drawCursor(handles, value);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on key press with focus on slider2 and none of its controls.
function slider2_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton2


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
        rows=size(tableData,1)
        for i=1:rows
            fprintf(fid,'%s|%s\n',tableData{i,1},tableData{i,2})
        end

        fclose(fid);
    end

else
    set(hObject, 'Enable', 'off');
    set(handles.slider1, 'Enable', 'off');
end
