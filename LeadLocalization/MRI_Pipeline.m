%% Clear environment and close figures
clear; clc; close all;

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

%% Step 0: Setups
Patient_DIR = uigetdir('','Please select the subject Folder');
if isnumeric(Patient_DIR) 
    error('No folder selected');
else
    DICOM_Directory = dir([Patient_DIR,filesep,'DICOMDIR']);
    if isempty(DICOM_Directory)
        error('Incorrect Patient Directory');
    end
end
fprintf('Change directory to patient directory...');
cd(Patient_DIR);
fprintf('Done\n\n');

MRIFILTERED = false;
CTFILTERED = false;
TRANSFORMED = false;
COREGISTERED = false;

NifTi_DIR = [Patient_DIR,filesep,'NiiX'];
Processed_DIR = [Patient_DIR,filesep,'Processed'];
mkdir(NifTi_DIR);
mkdir(Processed_DIR);

%% Step 1: DICOM to NifTi Converter
% There are 3 methods at the moment. First method uses dcm2niix.exe for
% processing. The second method uses pure MATLAB. dcm2niix is very fast in
% conversion, but not all images can be converted correctly. Manual
% conversion with second method could solve some of the problem where
% images are missing slices.
% 3rd method is unix based. it has to be launched in bash.
% it will divide DICOM files in their respective folders. Then 

if exist([Processed_DIR,filesep,'anat_t1.nii'],'file')
    disp('Nifti files detected. Skipping.')
else
    switch 1
        case 1
            dcm2niftix(Patient_DIR, NifTi_DIR);
        case 2
            dcm2nifti_matlab(Patient_DIR, NifTi_DIR);
        case 3
            hjimg_dcm2nii(Patient_DIR, NifTi_DIR);
    end
    
    % Step 1.5: Move the files to processed folder
    niftiViewer(NifTi_DIR, Processed_DIR);
end

%% Step 2: Upsampling MRI and Potential Image Processing (Optional for now)
if ~isempty(dir([Processed_DIR,filesep,'anat_t1_filtered.nii']))
	preop_T1 = loadNifTi([Processed_DIR,filesep,'anat_t1_filtered.nii']);
else
	% Up Sample to Images with 0.5mm Resolution
    preop_T1 = loadNifTi([Processed_DIR,filesep,'anat_t1.nii']);
	preop_T1_upsampled = resampleNifTi(preop_T1, [0.5 0.5 1]);
	fprintf('MRI Upsampling to 0.5mm spacing complete.\n');
	
	% Spatial Filtering
	preop_T1_filtered = spatialFilter(preop_T1_upsampled, 'diffusion');
	save_nii(preop_T1_filtered,[Processed_DIR,filesep,'anat_t1_filtered.nii']);
	preop_T1 = preop_T1_filtered;
	fprintf('MRI Spatial Filter with Diffusion Filter complete.\n');
end

%% Step 3: Transform the MRI Brain to AC-PC Coordinates
if ~isempty(dir([Processed_DIR,filesep,'anat_t1_acpc.nii'])) 
    
    %if an AC-PC already exists, see what the user wants to do, either redo
    %it or just use the current one
    option1 = 'Edit AC-PC coordinates';
    option2 = 'Use existing AC-PC transform';
    option3 = 'Cancel';
    answer = questdlg('An AC-PC transformed brain for this patient already exists. What would you like to do?',...
                      'Please Respond',...
                      option1,option2,option3,option3);
    switch answer
        case option1
            [preop_T1_acpc, transformMatrix, coordinates] = transformACPC(preop_T1);
            save_nii(preop_T1_acpc,[Processed_DIR,filesep,'anat_t1_acpc.nii']);
            preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);
            save([Processed_DIR,filesep,'acpc_transformation.mat'],'transformMatrix');
        case option2
            clear preop_T1_upsampled preop_T1;
            preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);
        case option3
            return;
    end
else
    [preop_T1_acpc, transformMatrix] = transformACPC(preop_T1);
    save_nii(preop_T1_acpc,[Processed_DIR,filesep,'anat_t1_acpc.nii']);
    preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);
    save([Processed_DIR,filesep,'acpc_transformation.mat'],'transformMatrix');
end

%% Step 4: Coregister the Post-operative CT Scan to T1 MRI in AC-PC Coordinate
if ~isempty(dir([Processed_DIR,filesep,'rpostop_ct.nii']))
    coregistered_CT = loadNifTi([Processed_DIR,filesep,'rpostop_ct.nii']);
elseif isempty(dir([Processed_DIR,filesep,'postop_ct.nii']))
    %if there is no postopCT, ask if user wants to do it just based on MRI
    %This would be the case if we only have a postoperative MRI available
    option1 = 'Use Postoperative MRI';
    option2 = 'Cancel';
    answer = questdlg('There is no postop_ct.nii, only an anat_t1.nii. What would you like to do?',...
                      'Please Respond',...
                      option1,option2,option2);
    switch answer
        case option1
            coregistered_CT = preop_T1_acpc;
        case option2
            return;
    end
else
    postop_CT = loadNifTi([Processed_DIR,filesep,'postop_ct.nii']);
    [coregistered_CT, tform] = coregisterMRI(preop_T1_acpc, postop_CT);
    save([Processed_DIR,filesep,'ct-t1_transformation.mat'],'tform');
    save_nii(coregistered_CT,[Processed_DIR,filesep,'rpostop_ct.nii']);
end

%% Step 4.5: Repeat the same process for T2 MRI as well (Optional)
if ~isempty(dir([Processed_DIR,filesep,'anat_t2_acpc.nii']))
    preop_T2_acpc = loadNifTi([Processed_DIR,filesep,'anat_t2_acpc.nii']);
else
    preop_T2 = loadNifTi([Processed_DIR,filesep,'anat_t2.nii']);
    [preop_T2_acpc, tform] = coregisterMRI(preop_T1_acpc, preop_T2);
    save([Processed_DIR,filesep,'t2-t1_transformation.mat'],'tform');
    save_nii(preop_T2_acpc,[Processed_DIR,filesep,'anat_t2_acpc.nii']);
end

% Data Check. t2-t1 transformation matrix should look identical (or at
% least very very similar to acpc transformation matrix

%% Step 5: Check coregistration.
% If the coregistration doesn't look good. Mark it and report to your
% mentor. (This is highly unlikely event unless the brain is highly
% shifted).

% If coregistration is not good, see line 26 to 29 in "coregisterMRI"
% function. Change max iteration to a larger number. 
checkCoregistration(preop_T1_acpc, coregistered_CT);

%% Step 6: Lead Localization
leadLocalization(preop_T1_acpc, coregistered_CT, Processed_DIR);

%% Step 7: Normalization based on patient morph
preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);
BovaAtlasFitter(preop_T1_acpc,Processed_DIR);

%% Step 8: Get BOVA Atlas Transformation Matrix
Patient_BOVA_DIR = uigetdir('\\gunduz-lab.bme.ufl.edu\Data\DBSArch','Please select the subject Folder');
if isnumeric(Patient_BOVA_DIR) 
    error('No folder selected');
else
    FMRISAVEDATA = dir([Patient_BOVA_DIR,filesep,'fmrisavedata.mat']);
    if isempty(FMRISAVEDATA)
        error('Cannot find BOVA Transform Data');
    end
end

FMRISAVEDATA = load([Patient_BOVA_DIR,filesep,'fmrisavedata.mat']);
m = matfile([Processed_DIR,filesep,'BOVAFit.mat'], 'Writable', true);
if isfield(FMRISAVEDATA.savestruct,'rotationleft')
    Left.Rotation = FMRISAVEDATA.savestruct.rotationleft;
    Left.Translation = FMRISAVEDATA.savestruct.mvmtleft;
    Left.Scale = FMRISAVEDATA.savestruct.scaleleft;
    m.Left = Left;
end
if isfield(FMRISAVEDATA.savestruct,'rotationright')
    Right.Rotation = FMRISAVEDATA.savestruct.rotationright;
    Right.Translation = FMRISAVEDATA.savestruct.mvmtright;
    Right.Scale = FMRISAVEDATA.savestruct.scaleright;
    m.Right = Right;
end
clear Left Right;

BovaTransform = load([Processed_DIR,filesep,'BOVAFit.mat']);

% Transform Left Lead if Left Atlas Morph Exist
if isfield(BovaTransform,'Left')
    leftLeads = dir([Processed_DIR,filesep,'Left*']);
    for n = 1:length(leftLeads)
        leadInfo = load([Processed_DIR,filesep,leftLeads(n).name]);
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
end

% Transform Right Lead if Right Atlas Morph Exist
if isfield(BovaTransform,'Right')
    rightLeads = dir([Processed_DIR,filesep,'Right*']);
    for n = 1:length(rightLeads)
        leadInfo = load([Processed_DIR,filesep,rightLeads(n).name]);
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
end
