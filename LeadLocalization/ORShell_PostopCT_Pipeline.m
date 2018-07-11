%% Weird Pipeline Style
% This is a workaround to resolve some of the bad coregistration problem. 
% The goal is to do the following:
%   1. Get T1, Preop-CT, Postop-CT
%   2. Calculate T1-ACPC Transform. This is ACPC_tform
%   3. Center Postop-CT to 0,0,0 (This is probably not neccessary)
%   4. Coregister Postop-CT(0,0,0) to Preop-CT
%   5. Obtain MR.xfrm file for MR-Preop transform. This is CTMR_tform.
%   6. Then apply ACPC_tform.
%   7. Done. Check Coregistration

%% Step 0. Setup
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

%% Step 1. Get T1, Preop-CT, Postop-CT
anat_t1 = loadNifTi([Processed_DIR,filesep,'anat_t1.nii']);
preop_ct = loadNifTi([Processed_DIR,filesep,'preop_ct.nii']);
postop_ct = loadNifTi([Processed_DIR,filesep,'postop_ct.nii']);

%% Step 2. Calculate T1-ACPC Transform. This is ACPC_tform
if ~isempty(dir([Processed_DIR,filesep,'anat_t1_filtered.nii']))
	preop_T1 = loadNifTi([Processed_DIR,filesep,'anat_t1_filtered.nii']);
    disp('MRI already upsampled and loaded.');
else
	% Up Sample to Images with 0.5mm Resolution
    preop_T1 = loadNifTi([Processed_DIR,filesep,'anat_t1.nii']);
	preop_T1_upsampled = resampleNifTi(preop_T1, [0.5 0.5 1]);
	fprintf('MRI Upsampling to 0.5mm spacing complete.\n');
	
	% Spatial Filtering
	preop_T1_filtered = spatialFilter(preop_T1_upsampled, 'none');
	save_nii(preop_T1_filtered,[Processed_DIR,filesep,'anat_t1_filtered.nii']);
	preop_T1 = preop_T1_filtered;
	fprintf('MRI Spatial Filter with Diffusion Filter complete.\n');
end

% Transform the MRI Brain to AC-PC Coordinates
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
        case option2
            clear preop_T1_upsampled preop_T1;
            preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);
            disp('Loaded AC-PC transformed T1.');
        case option3
            return;
    end
else
    [preop_T1_acpc, transformMatrix, coordinates] = transformACPC(preop_T1);
    save_nii(preop_T1_acpc,[Processed_DIR,filesep,'anat_t1_acpc.nii']);
    preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);
    save([Processed_DIR,filesep,'acpc_transformation.mat'],'transformMatrix');
    save([Processed_DIR,filesep,'acpc_coordinates.mat'],'-struct','coordinates');
end

%% Step 4: Coregister Postop-CT(0,0,0) to Preop-CT
if ~isempty(dir([Processed_DIR,filesep,'hfpostop_ct.nii']))
    hfpostop_ct = loadNifTi([Processed_DIR,filesep,'hfpostop_ct.nii']);
    disp('Loaded Postop CT in Headframe Coordinates');
else
    switch 1
        case 1
            [hfpostop_ct, tform] = coregisterMRI(preop_ct, postop_ct);
            save([Processed_DIR,filesep,'ct-hf_transformation.mat'],'tform');
            save_nii(hfpostop_ct,[Processed_DIR,filesep,'hfpostop_ct.nii']);
        case 2
            %{
                This step is going to be done in Advanced Normalization
                Tools (ANTs). 
            %}
        case 3
            % Shadow Step 4: What if DBSArch already have the transform?
            T = readFuseMatrix([Processed_DIR,filesep,'postop2ct']);
            T = inv(T);
            T(:,4) = round(T(:,4));
            POSTOPCT_tform = affine3d(T);
            hfpostop_ct = niftiWarp(postop_ct, POSTOPCT_tform);
            save_nii(hfpostop_ct,[Processed_DIR,filesep,'hfpostop_ct.nii']);
    end
end


%% Step 5. Obtain MR.xfrm file for MR-Preop transform. This is CTMR_tform.
T = readFuseMatrix([Processed_DIR,filesep,'mr.xfrm']);
T(:,4) = round(T(:,4));
CTMR_tform = affine3d(T);
rpostop_ct_raw = niftiWarp(hfpostop_ct, CTMR_tform);
rpostop_ct_raw = niftiReslice(rpostop_ct_raw, preop_T1);
save_nii(rpostop_ct_raw,[Processed_DIR,filesep,'rpostop_ct_raw.nii']);

%% Step 6. Then apply ACPC_tform.
ACPC_xfrm = load([Processed_DIR,filesep,'acpc_transformation.mat'],'transformMatrix');
ACPC_tform = affine3d(ACPC_xfrm.transformMatrix);
rpostop_ct = niftiWarp(rpostop_ct_raw, ACPC_tform);
rpostop_ct = niftiReslice(rpostop_ct, preop_T1_acpc);
save_nii(rpostop_ct,[Processed_DIR,filesep,'rpostop_ct.nii']);

%% Step 7. Done. Check Coregistration
checkCoregistration(preop_T1_acpc, rpostop_ct);
