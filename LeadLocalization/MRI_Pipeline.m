%% Clear environment and close figures
clear; clc; close all;

%% set the environment
UFNeuroVis_setEnv;

%#ok<*NASGU>
COREGISTER_METHOD = 1; % 1 - MATLAB
USING_CLINICAL_IMAGES = true;

%% Step 0: Setups
Patient_DIR = uigetdir('','Please select the subject Folder');
if isnumeric(Patient_DIR) 
    error('No folder selected');
else
    DICOM_Directory = dir([Patient_DIR,filesep,'DICOMDIR']);
    if isempty(DICOM_Directory) && ~exist(fullfile(Patient_DIR,'Processed'),'dir')
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
NEW_ACPC_COORDINATES=false;

NifTi_DIR = [Patient_DIR,filesep,'NiiX'];
Processed_DIR = [Patient_DIR,filesep,'Processed'];
DBSArch_DIR = fullfile(Patient_DIR,'DBSArch');
[~,~]=mkdir(NifTi_DIR);
[~,~]=mkdir(Processed_DIR);

%% Step 1: DICOM to NifTi Converter
% There are 3 methods at the moment. First method uses dcm2niix.exe for
% processing. The second method uses pure MATLAB. dcm2niix is very fast in
% conversion, but not all images can be converted correctly. Manual
% conversion with second method could solve some of the problem where
% images are missing slices.
% 3rd method is unix based. it has to be launched in bash.
% it will divide DICOM files in their respective folders. Then 

if exist([Processed_DIR,filesep,'anat_t1.nii'],'file')
    disp('Nifti files detected. Skipping.');
    preop_T1 = loadNifTi([Processed_DIR,filesep,'anat_t1.nii']);
elseif exist(DBSArch_DIR,'dir') ~= 0 && (exist(fullfile(DBSArch_DIR,'mr'),'file') ~= 0 || exist(fullfile(DBSArch_DIR,'ct.postop'),'file') ~= 0)
    USING_CLINICAL_IMAGES = true;
    
    if exist(fullfile(DBSArch_DIR,'mr'),'file') ~= 0
        preop_T1 = UFVTK2NifTi(fullfile(DBSArch_DIR,'mr'));
        save_nii(preop_T1,[Processed_DIR,filesep,'anat_t1.nii']);
    end
    
    if exist(fullfile(DBSArch_DIR,'ct.postop'),'file') ~= 0
        postop_ct = UFVTK2NifTi(fullfile(DBSArch_DIR,'ct.postop'));
        save_nii(postop_ct,[Processed_DIR,filesep,'postop_ct.nii']);
    end
else
    switch 6
        case 1
            dcm2niftix(Patient_DIR, NifTi_DIR);
        case 2
            dcm2nifti_matlab(Patient_DIR, NifTi_DIR);
        case 3
            disp('!! Note, must run installation before using hjimg_dc2nii. See dependencies/unixDCMtoNIFTI/README')
            hjimg_dcm2nii(fullfile(Patient_DIR,'IMAGES'), NifTi_DIR);
        case 4
            disp('Try to coregister before doing AC-PC, then apply AC-PC transform to CT scan.');
        case 5
            disp('Do it in Slicer 4.8 Please');
        case 6
            dcm2niix_matlab(Patient_DIR,NifTi_DIR); % Same as dcm2niftix, except updated to the most recent release as of 2020_10_28
    end
    
    % Step 1.5: Move the files to processed folder
    niftiViewer([],NifTi_DIR, Processed_DIR);
end

%% Step 2: Upsampling MRI and Potential Image Processing (Optional for now)
% if ~isempty(dir([Processed_DIR,filesep,'anat_t1_filtered.nii']))
% 	preop_T1 = loadNifTi([Processed_DIR,filesep,'anat_t1_filtered.nii']);
%     disp('MRI already upsampled and loaded.');
%     MRIFILTERED=true;
% else
% 	% Up Sample to Images with 0.5mm Resolution
%     preop_T1 = loadNifTi([Processed_DIR,filesep,'anat_t1.nii']);
% 	preop_T1_upsampled = resampleNifTi(preop_T1, [0.5 0.5 1]);
% 	fprintf('MRI Upsampling to 0.5mm spacing complete.\n');
% 	
% 	% Spatial Filtering
% % 	preop_T1_filtered = spatialFilter(preop_T1_upsampled, 'diffusion');
% % 	save_nii(preop_T1_filtered,[Processed_DIR,filesep,'anat_t1_filtered.nii']);
% % 	preop_T1 = preop_T1_filtered;
% % 	fprintf('MRI Spatial Filter with Diffusion Filter complete.\n');
% %     MRIFILTERED=true;
% end

%% Step 3: Coregister the Post-operative CT Scan to T1 MRI
if ~isempty(dir([Processed_DIR,filesep,'rpostop_ct.nii']))
    coregistered_CT = loadNifTi([Processed_DIR,filesep,'rpostop_ct.nii']);
    disp('Loaded coregistered CT');
    COREGISTERED=true;
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
    switch COREGISTER_METHOD
        case 1
            postop_CT = loadNifTi([Processed_DIR,filesep,'postop_ct.nii']);
            [coregistered_CT, tform] = coregisterMRI(preop_T1, postop_CT);
            save([Processed_DIR,filesep,'ct-t1_transformation.mat'],'tform');
            save_nii(coregistered_CT,[Processed_DIR,filesep,'rpostop_ct.nii']);
            COREGISTERED=true;
        case 2
            coregistrationANTs(NEURO_VIS_PATH,Processed_DIR,'linear');
            coregistered_CT = loadNifTi([Processed_DIR,filesep,'rpostop_ct.nii']);
            disp('Done with coregstration ANTs!');
            COREGISTERED=true;
        case 3
            coregistrationANTs(NEURO_VIS_PATH,Processed_DIR,'nonlinear');
            coregistered_CT = loadNifTi([Processed_DIR,filesep,'rpostop_ct.nii']);
            disp('Done with coregstration ANTs!');
            COREGISTERED=true;
    end
    
    [preop_T1,coregistered_CT]=removePaddedZeroes(Processed_DIR,preop_T1,coregistered_CT);
end

%% Step 4: Check coregistration
% If the coregistration doesn't look good. Mark it and report to your
% mentor. (This is highly unlikely event unless the brain is highly
% shifted).

% If coregistration is not good, see line 26 to 29 in "coregisterMRI"
% function. Change max iteration to a larger number. 
if COREGISTERED==true
    checkCoregistration(preop_T1, coregistered_CT);
end

%% Step 5: Transform the MRI Brain to AC-PC Coordinates
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
            [preop_T1_acpc, transformMatrix, coordinates] = transformACPC(preop_T1,[Processed_DIR,filesep,'acpc_coordinates.mat']); %add existing transformation matrix as an argument
            save_nii(preop_T1_acpc,[Processed_DIR,filesep,'anat_t1_acpc.nii']);
            preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);
            save([Processed_DIR,filesep,'acpc_transformation.mat'],'transformMatrix'); %save updated transform matrix
            save([Processed_DIR,filesep,'acpc_coordinates.mat'],'-struct','coordinates'); %save updated coordinates
            NEW_ACPC_COORDINATES=true;
            TRANSFORMED=true;
        case option2
            clear preop_T1_upsampled preop_T1;
            preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);
            coregistered_CT_acpc = loadNifTi([Processed_DIR,filesep,'rpostop_ct_acpc.nii']);
            disp('Loaded AC-PC transformed T1.');
            NEW_ACPC_COORDINATES=false;
            TRANSFORMED=true;
        case option3
            return;
    end
elseif USING_CLINICAL_IMAGES
    file_crw = dir(fullfile(DBSArch_DIR,'*VIM*'));
    
    if length(file_crw) == 1
        tform = LoadDBSArchACPC(fullfile(file_crw.folder,file_crw.name));
    else
        for i=1:length(file_crw)
            fprintf('%d: %s\n',i,file_crw(i).name);
        end
        
        answer=input('Multiple VIM CRW files discovered; choose one: ','s');
        
        val=str2double(answer);
        
        if val > 0 && val <= length(file_crw)
            tform = LoadDBSArchACPC(fullfile(file_crw(val).folder,file_crw(val).name));
        end
    end
    
    preop_T1_acpc = niftiWarp(preop_T1, tform);
    save_nii(preop_T1_acpc,[Processed_DIR,filesep,'anat_t1_acpc.nii']);
    
    coregistered_CT_acpc = niftiWarp(coregistered_CT, tform);
    save_nii(coregistered_CT_acpc,[Processed_DIR,filesep,'rpostop_ct_acpc.nii']);
    
    NEW_ACPC_COORDINATES=true;
    TRANSFORMED=true;
else
    [preop_T1_acpc, transformMatrix, coordinates] = transformACPC(preop_T1);
    tform = affine3d(transformMatrix);
    coregistered_CT_acpc = niftiWarp(coregistered_CT, tform);
    save_nii(preop_T1_acpc,[Processed_DIR,filesep,'anat_t1_acpc.nii']);
    save_nii(coregistered_CT_acpc,[Processed_DIR,filesep,'rpostop_ct_acpc.nii']);
    
    preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);
    coregistered_CT_acpc = loadNifTi([Processed_DIR,filesep,'rpostop_ct_acpc.nii']);
    save([Processed_DIR,filesep,'acpc_transformation.mat'],'transformMatrix');
    save([Processed_DIR,filesep,'acpc_coordinates.mat'],'-struct','coordinates');
    NEW_ACPC_COORDINATES=true;
    TRANSFORMED=true;
end

%% Step 6: Lead Localization
if COREGISTERED==true
    leadLocalization(preop_T1_acpc, coregistered_CT_acpc, Processed_DIR);
end

%% Step 7: Normalization based on patient morph

if ~isfield(preop_T1_acpc,'original')
    preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);
end

BovaAtlasFitter(preop_T1_acpc,Processed_DIR,NEURO_VIS_PATH);

%% Step 8: reverse transform each patient
% ONLY RUN THIS STEP IF A BOVA FIT WAS DONE FOR THIS PATIENT

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


%% Step 8: Consider, for each patient, to obtain volume information for analyses down the line
% http://volbrain.upv.es/index.php

