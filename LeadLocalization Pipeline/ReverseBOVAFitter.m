%% Clear environment and close figures
clear; clc; close all;

%% Get LeadLocalization Pipeline path

%if environmental variable is already set, use it, otherwise reinitialize
if isempty(getenv('NEURO_VIS_PATH'))
    %check if the current path has 'LeadLocalization Pipeline' or if we are
    %already in that folder
    if exist(fullfile(pwd,'LeadLocalization Pipeline'),'dir') == 7
        NEURO_VIS_PATH = fullfile(pwd,'LeadLocalization Pipeline');
    elseif endsWith(pwd,'LeadLocalization Pipeline')
        NEURO_VIS_PATH = pwd;
    else
        %prompt user to select LeadLocalization Pipeline
        NEURO_VIS_PATH = uigetdir('','Please select the LeadLocaliaztion Pipeline folder');
    end

    %ensure path is correct
    if ~endsWith(NEURO_VIS_PATH,'LeadLocalization Pipeline')
        msgbox('Failed to select LeadLocalization Pipeline folder');
        return
    end
    
    setenv('NEURO_VIS_PATH',NEURO_VIS_PATH);
else
    NEURO_VIS_PATH=getenv('NEURO_VIS_PATH');
end

% Add Path
addpath(genpath(NEURO_VIS_PATH))

%% Step 0: Setups
Patient_DIR = uigetdir('','Please select the subject Folder');
if isnumeric(Patient_DIR) 
    error('No folder selected');
else
    DICOM_Directory = dir([Patient_DIR,filesep,'PatientID.txt']);
    if isempty(DICOM_Directory)
        error('Incorrect Patient Directory');
    end
end
fprintf('Change directory to patient directory...');
cd(Patient_DIR);
fprintf('Done\n\n');

PatientID = importdata('PatientID.txt');

%% Load BOVA Transform and Reverse Transform Lead Location

% View Left Leads
leftLeads = dir([Processed_DIR,filesep,'Left*']);
for n = 1:length(leftLeads)
    leadInfo = load([Processed_DIR,filesep,leftLeads(n).name]);
    BovaTransform = load([Processed_DIR,filesep,'BOVAFit.mat']);
    T = computeTransformMatrix(BovaTransform.Left.Translation,BovaTransform.Left.Scale,BovaTransform.Left.Rotation);
    m = matfile([Processed_DIR,filesep,'BOVA_',leftLeads(n).name],'Writable',true);
    m.Side = leadInfo.Side;
    m.Type = leadInfo.Type;
    m.nContacts = leadInfo.nContacts;
    newDistal = [leadInfo.Distal, 1] / T;
    m.Distal = newDistal(1:3);
    newProximal = [leadInfo.Proximal, 1] / T;
    m.Proximal = newProximal(1:3);
end

% View Right Leads
rightLeads = dir([Processed_DIR,filesep,'Right*']);
for n = 1:length(rightLeads)
    leadInfo = load([Processed_DIR,filesep,rightLeads(n).name]);
    BovaTransform = load([Processed_DIR,filesep,'BOVAFit.mat']);
    T = computeTransformMatrix(BovaTransform.Right.Translation,BovaTransform.Right.Scale,BovaTransform.Right.Rotation);
    m = matfile([Processed_DIR,filesep,'BOVA_',rightLeads(n).name],'Writable',true);
    m.Side = leadInfo.Side;
    m.Type = leadInfo.Type;
    m.nContacts = leadInfo.nContacts;
    newDistal = [leadInfo.Distal, 1] / T;
    m.Distal = newDistal(1:3);
    newProximal = [leadInfo.Proximal, 1] / T;
    m.Proximal = newProximal(1:3);
end
