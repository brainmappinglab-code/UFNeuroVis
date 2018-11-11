function status = create_updrs_template(Headers,cellIndex,File)
%{
CREATE_UPDRS_TEMPLATE
    writes Headers.updrsHeaders starting at column A, row cellIndex
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

status = xlswrite(File.full,Headers.updrsHeaders,1,['A' num2str(cellIndex)]);
end

