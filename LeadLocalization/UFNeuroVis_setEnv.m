%% Get LeadLocalization Pipeline path

%get current folder
[~, cwf1]=fileparts(pwd);

%if environmental variable is already set, use it, otherwise reinitialize
if isempty(getenv('NEURO_VIS_PATH'))
    %check if the current path has 'LeadLocalization Pipeline' or if we are
    %already in that folder
    if exist(fullfile(pwd,'LeadLocalization'),'dir') == 7
        NEURO_VIS_PATH = fullfile(pwd,'LeadLocalization');
    elseif  strcmp(cwf1,'LeadLocalization')
        NEURO_VIS_PATH = pwd;
    else
        %prompt user to select LeadLocalization Pipeline
        NEURO_VIS_PATH = uigetdir('','Please select the LeadLocalization folder');
        
        %check the soon to be current folder
        [~, cwf1]=fileparts(NEURO_VIS_PATH);
        
        %ensure the selected path is correct
        if ~strcmp(cwf1,'LeadLocalization')
            msgbox('Failed to select LeadLocalization folder');
            return
        end
    end
    
    setenv('NEURO_VIS_PATH',NEURO_VIS_PATH);
else
    NEURO_VIS_PATH=getenv('NEURO_VIS_PATH');
end

% Add Path
addpath(genpath(NEURO_VIS_PATH))

clear cwf1 pwd1;