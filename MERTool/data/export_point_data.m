function export_point_data(hObject,handles)
%EXPORT_POINT_DATA

%section_path = getappdata(handles.traj_axes,'SectionPath');

%[~,fname,~] = fileparts(char(section_path));

PassPoint = getappdata(handles.traj_axes,'PassPoint');
ApmDataTable = getappdata(ancestor(hObject,'Figure'),'ApmDataTable');
[path,name,~] = fileparts(char(ApmDataTable{PassPoint(1)}.path(PassPoint(2))));
name = [name '.apm'];
t = APMReadData(fullfile(path,name));

%name = get(handles.name_disp,'String');
%surgery = get(handles.surgery_disp,'String');
%date = datestr(now,'yyyy-mm-dd_HH;MM;ss');

[sname,spath] = uiputfile([sprintf('%s',name) '.mat']);

save([spath sname],'t');

end