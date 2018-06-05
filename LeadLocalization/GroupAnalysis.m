%group analysis

clc; close all; clear all;

%% set the environment
UFNeuroVis_setEnv;

%teee
%% Step 0: Setups
Patient_DIR = uigetdir('','Please select a folder with multiple patients');

%%
dirc = dir(Patient_DIR);

patients = [];
patientCount = 0; %in the beginniing, we have 0 patients
for i=1:length(dirc)
    
    thisPatientFolder = [dirc(i).folder,filesep,dirc(i).name];
    patient.Name = dirc(i).name;
    
    thisPatientFolderProcessed = [thisPatientFolder,filesep,'Processed'];
    
    leadsR = dir([thisPatientFolderProcessed,filesep,'LEAD_Right_*']);
    leadsL = dir([thisPatientFolderProcessed,filesep,'LEAD_Left_*']);
    fits = dir([thisPatientFolderProcessed,filesep,'BOVAFit_*']);
    
 
    if length(fits) > 0
  
        %find a potential left and right fit
        leftFit = NaN;
        rightFit = NaN;
        for j=1:length(fits)
           thisFit = load(fullfile(fits(j).folder,fits(j).name));
           if isfield(thisFit,'Left')
               patient.LeftFit = thisFit.Left;
           end
           if isfield(thisFit,'Right')
               patient.RightFit = thisFit.Right;
           end
        end
        
        if length(leadsL) > 0 && isfield(patient,'LeftFit')
            patient.LeftLead = load(fullfile(leadsL(1).folder,leadsL(1).name));
        end
        if length(leadsR) > 0 && isfield(patient,'RightFit')
            patient.RightLead = load(fullfile(leadsR(1).folder,leadsR(1).name));
        end
    end
    
    if isfield(patient,'LeftLead') || isfield(patient,'RightLead')
        patientCount = patientCount + 1;
        patients{patientCount} = patient;
    end
  
    clear patient;
end


%%


