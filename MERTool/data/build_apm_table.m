function ApmDataTable = build_apm_table(glrPath)
%BUILD_APM_TABLE
%{
    Starts ApmDataTable by reading files and filling depth and path
    columns. If no APM files are found in the folder, will attempt to find
    GLR file at that path and extract APM files from it. x,y,z fields are
    filled by plotter1 function
ARGS
    apmPath: path to folder containing glr file or extracted apm files
RETURNS
    ApmDataTable: cell array with entries defined below:

            ApmDataTable{pass}."field"(point)
                               depth
                               path
                               x
                               y
                               z
%}

if ~nargin
    glrPath = uigetdir('C:\','APM Folder');
end

%get initial file list
tF = dir([glrPath '\*.apm']);

%if no files found,
if isempty(tF)
    % look for GLR files at apmPath
    tGLR = dir([glrPath '\*.glr']);
    answer = questdlg(['No .apm files found at that location. Do you want to use data from ' tGLR.name '? (This may take a while.)'],'MER tool');
    if strcmp(answer,'No') || strcmp(answer,'Cancel')
        ApmDataTable = [];
        f = errordlg('No .apm files given');
        waitfor(f);
        return
    end
    w = waitbar(0,'Unpacking GLR file...','Name','Progress');
    
    ReadGLR_Exporter(['"' tGLR.folder '\' tGLR.name '"'],['"' tGLR.folder '"'],'"apm"','"distancefromzero"');
    
    close(w);
    
    % try again for a file list
    tF = dir([glrPath '\*.apm']);
end

if verLessThan('matlab','9.4') % older than 2018a
    depth = zeros(12,1);
    path = strings(12,1);
    x = zeros(12,1);
    y = zeros(12,1);
    z = zeros(12,1);
    talloc = table(depth,path,x,y,z);
else
    talloc = table('Size',[12 5],'VariableTypes',{'double', 'string', 'double', 'double', 'double'},'VariableName',{'depth','path','x','y','z'});
end
ApmDataTable = {};
sprintf('%s',tF.name)

iPass = 1;
expr = sprintf('(?<=^|.apm)[A-Za-z-_]+ [A-Za-z]+_Pass %d_[A-Za-z0-9]+_Snapshot - 3600.0 sec [0-9]+_.[0-9.]*apm',iPass);
filename = regexp([tF.name],expr,'match');

while ~isempty(filename)
    temp = talloc;
    
    filename = natsort(filename);
    
    N = size(filename,2);

    % initialise very informative progress bar
    w = waitbar(0,sprintf('Extracting APM data (1/%d)',N),'Name','Progress');
    % remove any unintended formatting in progress bar text
    myString = findall(w,'String','Starting Conversion');
    set(myString,'Interpreter','none');

    for i = 1:N
        waitbar(i/N,w,sprintf('Extracting APM data (%d/%d)',i,N));
        path = string(strcat(glrPath,'\',filename(i)));
        t = APMReadData(path);
        dist = t.drive_data.depth;
        if i > size(temp,1)
            temp = [temp;talloc];
        end
        temp.path(i) = path; %path
        % if depth is empty, skip them
        if ~isempty(dist)
            temp.depth(i) = dist(2)/1000; %depth
        end
    end
    
    if size(ApmDataTable,2) == 0
        ApmDataTable = {temp};
    else
        ApmDataTable = [ApmDataTable {temp}];
    end
    iPass = iPass + 1;
    expr = sprintf('(?<=^|.apm)[A-Za-z-_]+ [A-Za-z]+_Pass %d_[A-Za-z0-9]+_Snapshot - 3600.0 sec [0-9]+_.[0-9.]*apm',iPass);
    filename = regexp([tF.name],expr,'match');

    close(w)
end

