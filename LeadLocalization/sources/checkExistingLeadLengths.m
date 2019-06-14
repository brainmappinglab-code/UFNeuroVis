%% Check for lead length differences
%
%  Go through a pre-existing Processed folder and check all saved Lead.mat files to see if
%  the lengths match what is expected
%

%% Load folder

processedFolder=uigetdir(pwd,'Please choose the patient Processed folder');

%% Loop through and check lengths

files=dir(fullfile(processedFolder,'LEAD_*.mat'));

for i=1:length(files)
    leadType=load(fullfile(processedFolder,files(i).name),'Type');
    expectedLength=getLeadLength(leadType.Type);
    contact=load(fullfile(processedFolder,files(i).name),'Distal','Proximal');
    estimatedLength=rssq(contact.Distal-contact.Proximal);
    
    if abs(estimatedLength-expectedLength) > 0.5
        fprintf('Warning: Lead ''%s'' is supposed to be %.1f mm, but is actually %.2f mm\n',...
            files(i).name,expectedLength,estimatedLength);
    end
end