function varargout = MER_plot(varargin)
% MER_PLOT MATLAB code for MER_plot.fig
%      MER_PLOT, by itself, creates a new MER_PLOT or raises the existing
%      singleton*.
%
%      H = MER_PLOT returns the handle to a new MER_PLOT or the handle to
%      the existing singleton*.
%
%      MER_PLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MER_PLOT.M with the given input arguments.
%
%      MER_PLOT('Property','Value',...) creates a new MER_PLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MER_plot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MER_plot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MER_plot

% Last Modified by GUIDE v2.5 09-Nov-2018 12:44:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MER_plot_OpeningFcn, ...
                   'gui_OutputFcn',  @MER_plot_OutputFcn, ...
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


% --- Executes just before MER_plot is made visible.
function MER_plot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MER_plot (see VARARGIN)

% Choose default command line output for MER_plot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

CrwData = varargin{1};
DbsData = varargin{2};
glrPath = varargin{3};
dest = varargin{4};

daH = handles.disp_axes;
taH = handles.traj_axes;

% plot APM data
if exist([glrPath,filesep,'ApmDataTable.mat'],'file')==2
    ApmDataTableMat = load([glrPath,filesep,'ApmDataTable.mat']);
    ApmDataTable = ApmDataTableMat.ApmDataTable;
else
    ApmDataTable = build_apm_table(glrPath);
    ApmDataTable = repair_apm_table(ApmDataTable,'linear');
    extract_wav_files(glrPath); %TODO separate path?
    save([glrPath,filesep,'ApmDataTable.mat'],'ApmDataTable')
end

%TODO uncomment this
%{
if size(ApmDataTable,3) < size(DbsData.data1,3)
    ApmDataTable = repair_apm_table(ApmDataTable,DbsData);
end
%}

if isempty(ApmDataTable)
    close;
    MER_gui()
end

%label axes of traj_axes
xlabel(taH,'LT');
ylabel(taH,'AP');
zlabel(taH,'AX');
hold(taH,'on');

ApmDataTable = plotter1(CrwData,DbsData,ApmDataTable,taH);
grid(taH,'on');

%set the button down function of traj_axes
set(taH,'ButtonDownFcn',@mer_plot_callback);

%store all critical objects as GUI data
setappdata(hObject,'ApmDataTable',ApmDataTable);
setappdata(hObject,'apmPath',glrPath);
setappdata(hObject,'CrwData',CrwData);
setappdata(hObject,'DbsData',DbsData);
setappdata(hObject,'dest',dest);

% TODO why does this need to be here?
set(gca,'Tag','disp_axes');

%fill patient info into GUI
set(handles.name_disp,'String',[DbsData.lastname ', ' DbsData.firstname DbsData.middlename]);
set(handles.surgery_disp,'String',DbsData.surgery);
set(handles.date_disp,'String',DbsData.dos);

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes MER_plot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MER_plot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in display_style.
function display_style_Callback(hObject, eventdata, handles)
% hObject    handle to display_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns display_style contents as cell array
%        contents{get(hObject,'Value')} returns selected item from display_style

if isappdata(handles.traj_axes,'SectionPath')
    sectionPath = getappdata(handles.traj_axes,'SectionPath');
    style = get(handles.display_style,'Value');
    plot_section_data(handles.disp_axes,sectionPath,style);
end


% --- Executes during object creation, after setting all properties.
function display_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in export_button.
function export_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
export_point_data(handles);


% --- Executes on button press in play_audio_button.
function play_audio_button_Callback(hObject, eventdata, handles)
% hObject    handle to play_audio_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wavPath = getappdata(handles.traj_axes,'SectionPath');
[path,name,~] = fileparts(wavPath);
wavPath = sprintf('%s\\wav\\%s_Ch1.wav',path,name);
if isfile(wavPath)
    [y, fs] = audioread(wavPath);
    soundsc(y,fs)
end


