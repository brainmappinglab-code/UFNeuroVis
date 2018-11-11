function [status,comment] = trs_to_xls(Headers,DbsData,CrwData,File)
%{
TRS_TO_XLS converts MER TRS 'Data' into a .xls named
           'File.name'.'File.type' located at 'File.path'
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
    
    comment = '';
    
    % initialise very informative progress bar
    w = waitbar(0,'Starting Conversion','Name','Progress');
    % remove any unintended formatting in progress bar text
    myString = findall(w,'String','Starting Conversion');
    set(myString,'Interpreter','none');

    % create template file at destination
    status = create_trs_template(Headers,1,File);
    if ~status
        comment = [File.name ': trs_to_xls create_trs_template failed'];
        close(w);
        return
    end
    
    waitbar(.125,w,'Filling Patient Info');
   
    % fill patient information
    status = fill_patient_info(DbsData,File);
    if ~status
        comment = [File.name ': trs_to_xls fill_patient_info failed'];
        close(w);
        return
    end
    
    waitbar(.25,w,'Filling .crw Data');
    
    % fill crw information
    status = fill_crw_info(CrwData,File);
    if ~status
        comment = [File.name ': trs_to_xls fill_crw_info failed'];
        close(w);
        return
    end
    
    waitbar(.375,w,'Filling Baseline Data');

    % fill baseline, post-micro, post-lead
    status = fill_trs_info(DbsData,File);
    if ~status
        comment = [File.name ': trs_to_xls fill_trs_info failed'];
        close(w);
        return
    end
    
    waitbar(.5,w,'Filling Recording Pass Data');
    
    % first empty cell in template
    cellIndex = 79;

    % for each pass, create and fill template, then increment cell_index
    for iTrack = 1:size(DbsData.data1,3)
        status = create_track_template(Headers,cellIndex,File);
        if ~status
            comment = [File.name ': trs_to_xls create_track_template ' iTrack '  failed'];
            close(w);
            return
        end
        status = fill_recording_track(DbsData,cellIndex,iTrack,File);
        if ~status
            comment = [File.name ': trs_to_xls fill_recording_track ' iTrack ' failed'];
            close(w);
            return
        end
        cellIndex = cellIndex + size(DbsData.data1,1) + 8;
        status = create_post_template(Headers,cellIndex,File);
        if ~status
            comment = [File.name ': trs_to_xls create_post_template ' iTrack ' failed'];
            close(w);
            return
        end
        if size(DbsData.data21,3) >= iTrack
            if ~isempty(DbsData.data21(1,1,iTrack))
                status = fill_post_template(DbsData,cellIndex,iTrack,File);
                if ~status
                    comment = [File.name ': trs_to_xls fill_post_template ' iTrack ' failed'];
                    close(w);
                    return
                end
                cellIndex = cellIndex + size(DbsData.data21,1);
            end
        end
        cellIndex = cellIndex + 2;
    end
    
    waitbar(.75,w,'Filling Stimulation Pass Data');
    
    % for each pass, create and fill template, then increment cell_index
    for iTrack = 1:size(DbsData.data31,3)
        status = create_stim_template(Headers,cellIndex,File);
        if ~status
            comment = [File.name ': trs_to_xls create_stim_template ' iTrack '  failed'];
            close(w);
            return
        end
        status = fill_stim_track(DbsData,cellIndex,iTrack,File);
        if ~status
            comment = [File.name ': trs_to_xls fill_stim_track ' iTrack ' failed'];
            close(w);
            return
        end
        cellIndex = cellIndex + size(DbsData.data31,1) + 11;
    end    
     
    % close the progress bar
    close(w);

end

