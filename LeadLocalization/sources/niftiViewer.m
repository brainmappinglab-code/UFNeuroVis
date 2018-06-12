function varargout = niftiViewer(varargin)
% NIFTIVIEWER MATLAB code for niftiViewer.fig
%      NIFTIVIEWER, by itself, creates a new NIFTIVIEWER or raises the existing
%      singleton*.
%
%      H = NIFTIVIEWER returns the handle to a new NIFTIVIEWER or the handle to
%      the existing singleton*.
%
%      NIFTIVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NIFTIVIEWER.M with the given input arguments.
%
%      NIFTIVIEWER('Property','Value',...) creates a new NIFTIVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before niftiViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to niftiViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help niftiViewer

% Last Modified by GUIDE v2.5 02-Apr-2018 11:52:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @niftiViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @niftiViewer_OutputFcn, ...
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

% --- Executes just before niftiViewer is made visible.
function niftiViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to niftiViewer (see VARARGIN)

% Choose default command line output for niftiViewer
handles.output = hObject;
handles.currentFile = [];
handles.mostRecentCall = 0;

% Setup the figure to display in certain monitor
set(handles.figure1,'PaperPositionMode','auto');
p = get(0,'MonitorPositions');
monitorP = [1 1];
for n = 1:size(p,1)
    if p(n,4) > 850
        monitorP = p(n,1:2);
        break;
    end
end
Size = get(handles.figure1,'Position');
set(handles.figure1,'Position',[monitorP Size(3:4)]);

% Display all NifTi files in the folder
handles.patientDir = varargin{1};
handles.targetDir = varargin{2};
if isempty(dir([handles.targetDir]))
    mkdir(handles.targetDir);
end
if ~isempty(dir([handles.targetDir,filesep,'anat_t1*nii']))
    set(handles.T1_Selection,'enable','off')
end
if ~isempty(dir([handles.targetDir,filesep,'anat_t2*nii']))
    set(handles.T2_Selection,'enable','off')
end
if ~isempty(dir([handles.targetDir,filesep,'postop_ct*nii']))
    set(handles.CT_Selection,'enable','off')
end

handles.niftiFiles = dir([handles.patientDir,filesep,'*.nii']);
handles.fileSelection.String = {};
for n = 1:length(handles.niftiFiles)
    handles.fileSelection.String{n} = handles.niftiFiles(n).name;
end
handles.cmap = [0 1];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes niftiViewer wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = niftiViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(hObject);

% --- Executes on selection change in fileSelection.
function fileSelection_Callback(hObject, eventdata, handles)
% hObject    handle to fileSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fileSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileSelection


% --- Executes during object creation, after setting all properties.
function fileSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Display_NifTi.
function Display_NifTi_Callback(hObject, eventdata, handles)
% hObject    handle to Display_NifTi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.fileSelection,'String'));
filename = contents{get(handles.fileSelection,'Value')};
try 
    handles.NifTi = load_nii([handles.patientDir,filesep,filename]);
    handles.NifTi.dime = size(handles.NifTi.img);
    handles.NifTi.center = round(handles.NifTi.dime / 2);
    handles.cmapMax = double(max(max(max(handles.NifTi.img))));
    showNifTi(handles);
    handles.currentFile = [handles.patientDir,filesep,filename];
catch ME
    fprintf('used load untouch, consider reslicing (TODO)\n');
    try
        handles.NifTi = load_untouch_nii([handles.patientDir,filesep,filename]);
        handles.NifTi.dime = size(handles.NifTi.img);
        handles.NifTi.center = round(handles.NifTi.dime / 2);
        handles.cmapMax = double(max(max(max(handles.NifTi.img))));
        showNifTi(handles);
        handles.currentFile = [handles.patientDir,filesep,filename];
    catch ME2
        msgbox('Cannot load. Probably not the image you want.');
    end
end
guidata(hObject, handles);

% --- The standard function for plotting
function showNifTi(handles)
handles.Coronal_Img = imagesc(handles.Coronal_Slice,squeeze(handles.NifTi.img(:,:,handles.NifTi.center(3)))');
handles.Sagittal_Img = imagesc(handles.Sagittal_Slice,squeeze(handles.NifTi.img(:,handles.NifTi.center(2),:))');
handles.Axial_Img = imagesc(handles.Axial_Slice,squeeze(handles.NifTi.img(handles.NifTi.center(1),:,:))');
axis(handles.Coronal_Slice,'xy');
axis(handles.Sagittal_Slice,'xy');
axis(handles.Axial_Slice,'xy');
colormap(handles.Coronal_Slice,'gray');
colormap(handles.Sagittal_Slice,'gray');
colormap(handles.Axial_Slice,'gray');
caxis(handles.Coronal_Slice,handles.cmap*handles.cmapMax);
caxis(handles.Sagittal_Slice,handles.cmap*handles.cmapMax);
caxis(handles.Axial_Slice,handles.cmap*handles.cmapMax);
pixdim = handles.NifTi.hdr.dime.pixdim(2:4);
pbaspect(handles.Coronal_Slice,[pixdim(1)*handles.NifTi.dime(1) pixdim(2)*handles.NifTi.dime(2) 1]);
pbaspect(handles.Sagittal_Slice,[pixdim(1)*handles.NifTi.dime(1) pixdim(3)*handles.NifTi.dime(3) 1]);
pbaspect(handles.Axial_Slice,[pixdim(2)*handles.NifTi.dime(2) pixdim(3)*handles.NifTi.dime(3) 1]);
set(handles.Coronal_Slice,'XTick',[],'YTick',[]);
set(handles.Sagittal_Slice,'XTick',[],'YTick',[]);
set(handles.Axial_Slice,'XTick',[],'YTick',[]);
if isempty(get(handles.Coronal_Img,'ButtonDownFcn'))
    set(handles.Coronal_Img, 'ButtonDownFcn', @(hObject,eventdata)niftiViewer('Coronal_Slice_ButtonDownFcn',hObject,eventdata,guidata(hObject)));
    set(handles.Sagittal_Img, 'ButtonDownFcn', @(hObject,eventdata)niftiViewer('Sagittal_Slice_ButtonDownFcn',hObject,eventdata,guidata(hObject)));
    set(handles.Axial_Img, 'ButtonDownFcn', @(hObject,eventdata)niftiViewer('Axial_Slice_ButtonDownFcn',hObject,eventdata,guidata(hObject)));
end

% --- Executes on mouse press over axes background.
function Coronal_Slice_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Coronal_Slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NifTi.center([1 2]) = round(eventdata.IntersectionPoint(1:2))';
handles.mostRecentCall = 3;
showNifTi(handles);
guidata(handles.figure1, handles);

% --- Executes on mouse press over axes background.
function Sagittal_Slice_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Coronal_Slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NifTi.center([1 3]) = round(eventdata.IntersectionPoint(1:2))';
handles.mostRecentCall = 2;
showNifTi(handles);
guidata(handles.figure1, handles);

% --- Executes on mouse press over axes background.
function Axial_Slice_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Coronal_Slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NifTi.center([2 3]) = round(eventdata.IntersectionPoint(1:2))';
handles.mostRecentCall = 1;
showNifTi(handles);
guidata(handles.figure1, handles);

% --- Executes on button press in T1_Selection.
function T1_Selection_Callback(hObject, eventdata, handles)
% hObject    handle to T1_Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(dir([handles.targetDir,filesep,'anat_t1*nii']))
    copyfile(handles.currentFile, [handles.targetDir,filesep,'anat_t1.nii']);
    set(handles.T1_Selection,'enable','off')
else
    x = length(dir([handles.targetDir,filesep,'anat_t1.nii']));
    copyfile(handles.currentFile, [handles.targetDir,filesep,'anat_t1',x+1,'.nii']);
end

% --- Executes on button press in T2_Selection.
function T2_Selection_Callback(hObject, eventdata, handles)
% hObject    handle to T2_Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(dir([handles.targetDir,filesep,'anat_t2*nii']))
    copyfile(handles.currentFile, [handles.targetDir,filesep,'anat_t2.nii']);
    set(handles.T2_Selection,'enable','off')
else
    x = length(dir([handles.targetDir,filesep,'anat_t2.nii']));
    copyfile(handles.currentFile, [handles.targetDir,filesep,'anat_t2',x+1,'.nii']);
end


% --- Executes on button press in CT_Selection.
function CT_Selection_Callback(hObject, eventdata, handles)
% hObject    handle to CT_Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(dir([handles.targetDir,filesep,'postop_ct*nii']))
    copyfile(handles.currentFile, [handles.targetDir,filesep,'postop_ct.nii']);
    set(handles.CT_Selection,'enable','off')
else
    x = length(dir([handles.targetDir,filesep,'postop_ct.nii']));
    copyfile(handles.currentFile, [handles.targetDir,filesep,'postop_ct',x+1,'.nii']);
end


% --- Executes on slider movement.
function minSlide_Callback(hObject, eventdata, handles)
% hObject    handle to minSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cmap(1) = get(hObject,'Value');
if handles.cmap(1) > handles.cmap(2)
    handles.cmap(1) = handles.cmap(2)-0.001;
end
showNifTi(handles);
guidata(hObject, handles);

% --- Executes on slider movement.
function maxSlide_Callback(hObject, eventdata, handles)
% hObject    handle to maxSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cmap(2) = get(hObject,'Value');
if handles.cmap(2) < handles.cmap(1)
    handles.cmap(2) = handles.cmap(1)+0.001;
end
showNifTi(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function maxSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function minSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume;


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(eventdata.Key,'downarrow')
    if handles.mostRecentCall ~= 0
        if handles.NifTi.center(handles.mostRecentCall) > 1
            handles.NifTi.center(handles.mostRecentCall) = handles.NifTi.center(handles.mostRecentCall) - 1;
            showNifTi(handles);
        end
    end
elseif strcmpi(eventdata.Key,'uparrow')
    if handles.mostRecentCall ~= 0
        if handles.NifTi.center(handles.mostRecentCall) < handles.NifTi.dime(handles.mostRecentCall)
            handles.NifTi.center(handles.mostRecentCall) = handles.NifTi.center(handles.mostRecentCall) + 1;
            showNifTi(handles);
        end
    end
end
guidata(hObject, handles);
