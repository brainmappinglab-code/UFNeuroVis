%% Clear environment and close figures
clear; clc; close all;

%% set the environment
UFNeuroVis_setEnv;

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
