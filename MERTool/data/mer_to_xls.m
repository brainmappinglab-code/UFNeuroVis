function [status,comment] = mer_to_xls(Headers,DbsData,CrwData,File)
%{
MER_TO_XLS deletes any files named named 'File.name'.'File.type' located at
 'File.path', then passes args to functions specific to type of MER data
ARGS
    Headers: structure, contains templates from data\Headers.mat
    DbsData: structure, contains data from .dbs file
    CrwData: structure, created by extract_crw_data()
    File: structure, with fields
        path: string, path to output file destination
        name: string, name of output file
        type: string, '.xls' or '.xlsx'
        full: string, [File.path File.name File.type]
RETURNS
    status: logical 1 on success, 0 on failure
    comment: string, error messages
%}

    % replace file
    if exist(File.full,'file')
        delete(File.full);
        if exist(File.full,'file')
            status = 0;
            comment = ['Could not replace ' File.name File.type '. Is it open?'];
            return
        end
    end

    % check type of MER data
    if ~isfield(DbsData,'baseline')
        status = 0;
        comment = [File.name ': unrecognizable data format'];
        return
    elseif ~isempty(DbsData.TRSbaseline)
        [status,comment] = trs_to_xls(Headers,DbsData,CrwData,File);
    elseif ~isempty(DbsData.baseline)
        [status,comment] = updrs_to_xls(Headers,DbsData,CrwData,File);
    else
        status = 0;
        comment = [File.name ': unrecognizable data format'];
        return
    end

end

