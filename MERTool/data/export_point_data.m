function export_point_data(hObject,handles)
%EXPORT_POINT_DATA

%section_path = getappdata(handles.traj_axes,'SectionPath');

%[~,fname,~] = fileparts(char(section_path));

PassPoint = getappdata(handles.traj_axes,'PassPoint');
ApmDataTable = getappdata(ancestor(hObject,'Figure'),'ApmDataTable');
[path,fname,~] = fileparts(char(ApmDataTable{PassPoint(1)}.path(PassPoint(2))));
apmname = [fname '.apm'];
t = APMReadData(fullfile(path,apmname));

%name = get(handles.name_disp,'String');
%surgery = get(handles.surgery_disp,'String');
%date = datestr(now,'yyyy-mm-dd_HH;MM;ss');

[sname,spath] = uiputfile([sprintf('%s',fname) '.mat']);

save([spath sname],'t');

wavPath = sprintf('%s\\wav\\%s_Ch1.wav',path,fname);
if exist(wavPath,'file') == 2
    % export wav file as well
    copyfile(wavPath,[spath fname '.wav']);
else
    sprintf('wav file not found')

end