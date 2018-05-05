%% Get LeadLocalization Pipeline path

%if environmental variable is already set, use it, otherwise reinitialize
if isempty(getenv('NEURO_VIS_PATH'))
    %check if the current path has 'LeadLocalization Pipeline' or if we are
    %already in that folder
    if exist(fullfile(pwd,'LeadLocalization'),'dir') == 7
        NEURO_VIS_PATH = fullfile(pwd,'LeadLocalization');
    elseif endsWith(pwd,'LeadLocalization')
        NEURO_VIS_PATH = pwd;
    else
        %prompt user to select LeadLocalization Pipeline
        NEURO_VIS_PATH = uigetdir('','Please select the LeadLocaliaztion folder');
    end

    %ensure path is correct
    if ~endsWith(NEURO_VIS_PATH,'LeadLocalization')
        msgbox('Failed to select LeadLocalization folder');
        return
    end
    
    setenv('NEURO_VIS_PATH',NEURO_VIS_PATH);
else
    NEURO_VIS_PATH=getenv('NEURO_VIS_PATH');
end

% Add Path
addpath(genpath(NEURO_VIS_PATH))