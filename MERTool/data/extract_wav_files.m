function extract_wav_files(glrPath)
%EXTRACT_WAV_FILES Summary of this function goes here

%get initial file list
%if ~isfolder([glrPath '\wav'])
if exist([glrPath '\wav'],'dir')~=7
    mkdir([glrPath '\wav']);
end
tF = dir([glrPath '\wav\*.wav']);

%if no files found,
if isempty(tF)
    % look for GLR files at apmPath
    tGLR = dir([glrPath '\*.glr']);
    answer = questdlg(['No .wav files found at that location. Do you want to use data from ' tGLR.name '? (This may take a while.)'],'MER tool');
    if strcmp(answer,'No') || strcmp(answer,'Cancel')
        f = errordlg('No .wav files given');
        waitfor(f);
        return
    end
    w = waitbar(0,'Unpacking WAV data...','Name','Progress');
    
    ReadGLR_Exporter(['"' tGLR.folder '\' tGLR.name '"'],['"' tGLR.folder '\wav"'],'"wav"','"distancefromzero"');
    
    close(w);
    
    % try again for a file list
    tF = dir([glrPath 'wav\*.wav']);
end

end

