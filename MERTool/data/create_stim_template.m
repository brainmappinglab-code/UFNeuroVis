function status = create_stim_template(Headers,cellIndex,File)
%{
CREATE_STIM_TEMPLATE
   writes Headers.stimTrack starting at column A, row cellIndex
ARGS
    Headers: structure, contains templates from data\Headers.mat
    cellIndex: int, the row to begin writing the stim_track_headers array
    File: structure, with fields
        path: string, path to output file destination
        name: string, name of output file
        type: string, '.xls' or '.xlsx'
        full: string, [File.path File.name File.type]
 RETURNS
    status: logical 1 on success, 0 on failure
%}

% write headers to pathName/.../fileName, checking for errors after each write
status = xlswrite(File.full,Headers.stimTrack,1,['A' num2str(cellIndex)]);
    
end