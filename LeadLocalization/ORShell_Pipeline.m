%% Clear environment and close figures
clear; clc; close all;

%% set the environment
UFNeuroVis_setEnv;

%% Step 0: Setups
Patient_DIR = uigetdir('','Please select the subject Folder');
if isnumeric(Patient_DIR) 
    error('No folder selected');
else
    ORShell_MRI = dir([Patient_DIR,filesep,'mr']);
    if isempty(ORShell_MRI)
        error('Incorrect Patient Directory');
    end
end
fprintf('Change directory to patient directory...');
cd(Patient_DIR);
fprintf('Done\n\n');

Processed_DIR = [Patient_DIR,filesep,'Processed'];
mkdir(Processed_DIR);

%% Step 1: Convert Knwon Image from UF VTK format to NifTi format
if exist('mr','file') && ~exist([Processed_DIR,filesep,'anat_t1.nii'],'file')
    preop_T1 = UFVTK2NifTi('mr');
	save_nii(preop_T1,[Processed_DIR,filesep,'anat_t1.nii']);
end

if exist('ct','file') && ~exist([Processed_DIR,filesep,'preop_ct.nii'],'file')
    postop_CT = UFVTK2NifTi('ct');
	save_nii(postop_CT,[Processed_DIR,filesep,'preop_ct.nii']);
end

if exist('ct.postop','file') && ~exist([Processed_DIR,filesep,'postop_ct.nii'],'file')
    postop_CT = UFVTK2NifTi('ct.postop');
	save_nii(postop_CT,[Processed_DIR,filesep,'postop_ct.nii']);
end

if exist('mr2','file') && ~exist([Processed_DIR,filesep,'anat_t2.nii'],'file')
    preop_T2 = UFVTK2NifTi('mr2');
	save_nii(preop_T2,[Processed_DIR,filesep,'anat_t2.nii']);
end

%% Load the CRW AC/PC Transformation
fid = fopen('left vim hpd.crw','r');
line = fgets(fid);
while line > 0 
    if strfind(line,'AC Point') > 0
        Valid = fgets(fid);
        AP = sscanf(fgets(fid),'%s = %f');
        LT = sscanf(fgets(fid),'%s = %f');
        AX = sscanf(fgets(fid),'%s = %f');
        AC = [LT(3), AP(3), AX(3)];
    end
    if strfind(line,'PC Point') > 0
        Valid = fgets(fid);
        AP = sscanf(fgets(fid),'%s = %f');
        LT = sscanf(fgets(fid),'%s = %f');
        AX = sscanf(fgets(fid),'%s = %f');
        PC = [LT(3), AP(3), AX(3)];
    end
    if strfind(line,'Ctrln Point') > 0
        Valid = fgets(fid);
        AP = sscanf(fgets(fid),'%s = %f');
        LT = sscanf(fgets(fid),'%s = %f');
        AX = sscanf(fgets(fid),'%s = %f');
        MC = [LT(3), AP(3), AX(3)];
    end
    line = fgets(fid);
end
fclose(fid);

Origin = (AC + PC) / 2;
temp = (MC - Origin) / rssq(MC - Origin);
J = (AC - PC) / rssq(AC - PC);
I = cross(J,temp)/rssq(cross(J,temp));
K = cross(I,J)/rssq(cross(I,J));

Old = [Origin+I,1; Origin+J,1; Origin+K,1; Origin,1];
New = [1,0,0,1; 0,1,0,1; 0,0,1,1; 0,0,0,1];

T = Old\New;
T(:,4) = round(T(:,4));
tform = affine3d(T);

%% Step 3: Transform the MRI Brain to AC-PC Coordinates
if ~isempty(dir([Processed_DIR,filesep,'rpostop_ct.nii']))
    preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);
else
    preop_T1_acpc = niftiWarp(preop_T1, tform);
    save_nii(preop_T1_acpc,[Processed_DIR,filesep,'anat_t1_acpc.nii']);
end

%% Step 4: Coregister the Post-operative CT Scan to T1 MRI in AC-PC Coordinate
if ~isempty(dir([Processed_DIR,filesep,'rpostop_ct.nii']))
    coregistered_CT = loadNifTi([Processed_DIR,filesep,'rpostop_ct.nii']);
else
    postop_CT = loadNifTi([Processed_DIR,filesep,'postop_ct.nii']);
    [coregistered_CT, tform] = coregisterMRI(preop_T1_acpc, postop_CT);
    save([Processed_DIR,filesep,'ct-t1_transformation.mat'],'tform');
    save_nii(coregistered_CT,[Processed_DIR,filesep,'rpostop_ct_matlab.nii']);
end

%% Step 5: Check coregistration.
% If the coregistration doesn't look good. Mark it and report to your
% mentor. (This is highly unlikely event unless the brain is highly
% shifted).

% If coregistration is not good, see line 26 to 29 in "coregisterMRI"
% function. Change max iteration to a larger number. 
checkCoregistration(preop_T1_acpc, coregistered_CT);

%% Step 6: Lead Localization
leadLocalization(preop_T1_acpc, coregistered_CT, Processed_DIR);

%% Step 7: Normalization (What is normalization? Never heard of it)
preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);
BovaAtlasFitter(preop_T1_acpc,Processed_DIR,NEURO_VIS_PATH);

%% Step 8: reverse normalize atlases
bovaFits = dir([Processed_DIR,filesep,'BOVAFit*']);
bovaFits.folder = [Processed_DIR,filesep];
if ~isempty(bovaFits)
    bovaFit = bovaFits(1);
    BovaTransform = load(fullfile(bovaFit.folder,bovaFit.name));
    
    % Transform Left Lead if Left Atlas Morph Exist
    if isfield(BovaTransform,'Left')
        leftLeads = dir([Processed_DIR,filesep,'LEAD_Left*.mat']);
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
        rightLeads = dir([Processed_DIR,filesep,'LEAD_Right*.mat']);
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
end
