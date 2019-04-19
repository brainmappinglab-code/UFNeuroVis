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

% Last Modified by GUIDE v2.5 11-Apr-2019 14:16:32

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
handles.myPlayer = [];

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
    ApmDataTable = fill_apm_coordinates(CrwData,DbsData,ApmDataTable);
    ApmDataTable = fill_apm_match(ApmDataTable,DbsData);
    extract_wav_files(glrPath); %TODO separate path?
    save([glrPath,filesep,'ApmDataTable.mat'],'ApmDataTable')
end

if isempty(ApmDataTable)
    close;
    MER_gui()
end

plot_traj_data(taH,ApmDataTable,DbsData)

%store all critical objects as GUI data
setappdata(hObject,'ApmDataTable',ApmDataTable);
setappdata(hObject,'apmPath',glrPath);
setappdata(hObject,'CrwData',CrwData);
setappdata(hObject,'DbsData',DbsData);
setappdata(hObject,'dest',dest);

% TODO why does this need to be here?
set(gca,'Tag','disp_axes');

%fill patient info into GUI
name = [DbsData.lastname ', ' DbsData.firstname DbsData.middlename];
set(handles.name_disp,'String',name);
set(handles.surgery_disp,'String',DbsData.surgery);
set(handles.date_disp,'String',DbsData.dos);

set(handles.name_disp,'ButtonDownFcn',{@name_disp_callback,DbsData});

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

if isappdata(handles.traj_axes,'PassPoint')
    ApmDataTable = getappdata(ancestor(hObject,'Figure'),'ApmDataTable');
    style = get(handles.display_style,'Value');
    PassPoint = getappdata(handles.traj_axes,'PassPoint');
    plot_section_data(handles.disp_axes,ApmDataTable,style,PassPoint(1),PassPoint(2));
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

function name_disp_callback(src,event,DbsData)    %toggle hidden name
figHandle = ancestor(src, 'figure');
clickType = get(figHandle, 'SelectionType');
if strcmp(clickType, 'alt')
    if (strcmp(get(src,'String'),'Xxxxx, Xxxxx'))
        set(src,'String',[DbsData.lastname ', ' DbsData.firstname DbsData.middlename]);
    else
        set(src,'String','Xxxxx, Xxxxx');
    end
end

% --- Executes on button press in export_button.
function export_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
export_point_data(hObject,handles);

% --- Executes on button press in play_audio_button.
function play_audio_button_Callback(hObject, eventdata, handles)
% hObject    handle to play_audio_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

play(handles.myPlayer)
guidata(hObject,handles);




% --- Executes on selection change in cell_type_filter_menu.
function cell_type_filter_menu_Callback(hObject, eventdata, handles)
% hObject    handle to calling cell_type_filter_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = ancestor(hObject,'figure');
ApmDataTable = getappdata(f,'ApmDataTable');
DbsData = getappdata(f,'DbsData');
plot_traj_data(handles.traj_axes,ApmDataTable,DbsData);
% Hints: contents = cellstr(get(hObject,'String')) returns cell_type_filter_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cell_type_filter_menu


% --- Executes during object creation, after setting all properties.
function cell_type_filter_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cell_type_filter_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in duration_filter_menu.
function duration_filter_menu_Callback(hObject, eventdata, handles)
% hObject    handle to duration_filter_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = ancestor(hObject,'figure');
ApmDataTable = getappdata(f,'ApmDataTable');
DbsData = getappdata(f,'DbsData');
plot_traj_data(handles.traj_axes,ApmDataTable,DbsData);
% Hints: contents = cellstr(get(hObject,'String')) returns duration_filter_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from duration_filter_menu


% --- Executes during object creation, after setting all properties.
function duration_filter_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duration_filter_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in wave_clus_button.
function wave_clus_button_Callback(hObject, eventdata, handles)
% hObject    handle to wave_clus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = ancestor(hObject,'Figure');
[path,~,~] = fileparts(getappdata(f,'dest'))
obj_h = get(handles.disp_axes,'children');
data = get(obj_h,'YData');
sr = 48000;
current_path = pwd;
cd(path)
save('wave_clus.mat','data','sr')
cd(current_path)
wave_clus([path '\wave_clus.mat'])
cd(current_path)




% --- Executes on button press in pause_audio_button.
function pause_audio_button_Callback(hObject, eventdata, handles)
% hObject    handle to pause_audio_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (isplaying(handles.myPlayer))
    codedstring = '\u23ef'; % resume label
    decodedstring = sprintf(strrep(codedstring, '\u', '\x'));
    set(hObject,'String',decodedstring);
    
    pause(handles.myPlayer)
    
    aH = handles.disp_axes;
    lH = findobj(aH,'Type','Line');
    if (isappdata(aH,'marker'))
        marker = getappdata(aH,'marker');
        delete(marker);
    end
    n = handles.myPlayer.CurrentSample;
    x = get(lH,'Xdata');
    marker = line(aH,[x(n) x(n)],get(aH,'YLim'),'color',[1 0 0]);
    setappdata(aH,'marker',marker);
elseif (handles.myPlayer.CurrentSample ~= 1)
    codedstring = '\u23f8'; % pause label
    decodedstring = sprintf(strrep(codedstring, '\u', '\x'));
    set(hObject,'String',decodedstring);
    
    resume(handles.myPlayer);
end
guidata(hObject,handles)
