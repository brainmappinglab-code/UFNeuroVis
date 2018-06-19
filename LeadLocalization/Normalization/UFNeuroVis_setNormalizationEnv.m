%% Get LeadLocalization Pipeline path

%get current folder
[~, cwf1]=fileparts(pwd);

%if environmental variable is already set, use it, otherwise reinitialize
if isempty(getenv('NEURO_VIS_NormalizationPATH'))
    %check if the current path has 'LeadLocalization Pipeline' or if we are
    %already in that folder
    if exist(fullfile(pwd,'Normalization'),'dir') == 7
        NEURO_VIS_NormalizationPATH = fullfile(pwd,'Normalization');
    elseif  strcmp(cwf1,'Normalization')
        NEURO_VIS_NormalizationPATH = pwd;
    else
        %prompt user to select LeadLocalization Pipeline
        NEURO_VIS_NormalizationPATH = uigetdir('','Please select the Normalization folder');
        
        %check the soon to be current folder
        [~, cwf1]=fileparts(NEURO_VIS_NormalizationPATH);
        
        %ensure the selected path is correct
        if ~strcmp(cwf1,'Normalization')
            msgbox('Failed to select Normalization folder');
            return
        end
    end
    
    setenv('NEURO_VIS_NormalizationPATH',NEURO_VIS_NormalizationPATH);
else
    NEURO_VIS_NormalizationPATH=getenv('NEURO_VIS_NormalizationPATH');
end

% Add Path
addpath(genpath(NEURO_VIS_NormalizationPATH))

clear cwf1 pwd1;