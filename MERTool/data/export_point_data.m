function export_point_data(handles)
%EXPORT_POINT_DATA

section_path = getappdata(handles.traj_axes,'SectionPath');

[~,fname,~] = fileparts(char(section_path));

t = APMReadData(section_path);

%name = get(handles.name_disp,'String');
%surgery = get(handles.surgery_disp,'String');
%date = datestr(now,'yyyy-mm-dd_HH;MM;ss');

[sname,spath] = uiputfile([sprintf('%s',fname) '.mat']);

save([spath sname],'t');

end