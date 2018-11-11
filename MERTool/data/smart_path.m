function smart_path(path,handles)
%{
SMART_PATH
    Attempts to predict user file selections bsaed on first choice
ARGS
    path: path of initial file selection
    handles: handles from MER_gui
RETURNS
    None
%}

% ensure path ends with '\'
if path(end) ~= '\'
    path = [path '\'];
end

fprintf('attempting smart path\n')

tF_dbs = dir([path '*.dbs']);
tF_crw = dir([path '*.crw']);
tF_apm = dir([path '*.apm']);
tF_glr = dir([path '*.glr']);

%if smart_path conditions are met,
if size(tF_dbs,1) == 1 ...
    && size(tF_crw,1) == 1 ...
    && (size(tF_glr,1) == 1 || ~isempty(tF_apm))

    fprintf('smart path conditions met\n')
    
    if strcmp(get(handles.dbs_disp,'String'),'...')
        set(handles.dbs_disp,'String',[tF_dbs.folder '\' tF_dbs.name]);
    end
    
    if strcmp(get(handles.crw_disp,'String'),'...')
        set(handles.crw_disp,'String',[tF_crw.folder '\' tF_crw.name]);
    end
    
    if strcmp(get(handles.apm_disp,'String'),'...')
        set(handles.apm_disp,'String',tF_crw.folder);
    end
    
end


end

