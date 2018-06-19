clc; close all; clear all;

%% set the environment
UFNeuroVis_setNormalizationEnv;

%% Step 0: Setups
Patient_DIR = uigetdir('','Please select the subject Folder');
if isnumeric(Patient_DIR) 
    error('No folder selected');
else
    if ~exist([Patient_DIR,filesep,'anat_t1.nii'],'file') || ~exist([Patient_DIR,filesep,'postop_ct.nii'],'file')
        error('Incorrect Patient Directory');
    end
end
fprintf('Change directory to patient directory...');
cd(Patient_DIR);
fprintf('Done\n\n');

%% Step 1: Load Data, Image Processing (TODO: Make a GUI)
MRI = loadNifTi('anat_t1.nii');
filteredMRI = MRI;
filteredMRI.img = imdiffusefilt(MRI.img);
save_nii(filteredMRI,[Patient_DIR,filesep,'anat_t1_aad.nii']);

%% Step 2: Call ROBEX for Skullstrip (TODO: Make a GUI)
InputFile = [Patient_DIR,filesep,'anat_t1_aad.nii'];
OutputFile = [Patient_DIR,filesep,'anat_t1_aad_brain.nii'];
ROBEX_CMD = [NEURO_VIS_NormalizationPATH,filesep,'ROBEX',filesep,'runROBEX.sh',' ',InputFile,' ',OutputFile];

system([ROBEX_CMD],'-echo');

%% Step 3: Configure Normalization Methods (TODO: Make a GUI, more customization)
ANTs_DIR = '/home/imagebuntu/Downloads/ANTs_build/bin';
MNI_DIR = '/home/imagebuntu/Desktop/Normalization/MNI_ICBM_2009b';

NUMTHREAD = 12;
system(['ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=',num2str(NUMTHREAD)]);
system('export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS');

Verbose = 1;
xtrmPrefix = [Patient_DIR,filesep,'xtrm'];
outputImage = [Patient_DIR,filesep,'glanat_t1.nii'];
InputFixImage = [MNI_DIR,'/t1.nii'];
InputMoveImage = [Patient_DIR,filesep,'anat_t1_aad.nii'];

CC = false; %Cross-correlation
MI = true; % Mutual Information

if CC
    Normalization_CMD = [ANTs_DIR,'/antsRegistration -v ',num2str(Verbose),' -d 3 -o [',xtrmPrefix,',',outputImage,'] -n Linear -u -f 1 -w [0.005,0.095] -a 1 -r [',InputFixImage,',',InputMoveImage,',1] \', ...
                            '-t Rigid[0.25] -c [1000x500x250x0,1e-5,10] -s 4x3x2x1vox -f 12x8x4x1 -m CC[',InputFixImage,',',InputMoveImage,',1,5] \',...
                            '-t Affine[0.15] -c [1000x500x250x0,1e-5,10] -s 4x3x2x1vox -f 8x4x2x1 -m CC[',InputFixImage,',',InputMoveImage,',1,5] \',...
                            '-t Syn[0.3,4,3] -c [1000x500x250x0,1e-5,7] -s 2x2x1x1vox -f 4x4x2x1 -m CC[',InputFixImage,',',InputMoveImage,',1,5]'];
elseif MI
    Normalization_CMD = [ANTs_DIR,'/antsRegistration -v ',num2str(Verbose),' -d 3 -o [',xtrmPrefix,',',outputImage,'] -n Linear -u -f 1 -w [0.005,0.095] -a 1 -r [',InputFixImage,',',InputMoveImage,',1] \', ...
                            '-t Rigid[0.25] -c [1000x500x250x0,1e-5,10] -s 4x3x2x1vox -f 12x8x4x1 -m MI[',InputFixImage,',',InputMoveImage,',1,32,Random,0.25] \',...
                            '-t Affine[0.15] -c [1000x500x250x0,1e-5,10] -s 4x3x2x1vox -f 8x4x2x1 -m MI[',InputFixImage,',',InputMoveImage,',1,32,Random,0.25] \',...
                            '-t Syn[0.3,4,3] -c [1000x500x250x0,1e-5,7] -s 2x2x1x1vox -f 4x4x2x1 -m MI[',InputFixImage,',',InputMoveImage,',1,32,Random,0.25]'];
end
%% Step 3.5: Normalization (TODO: Make a custom function)

system(['bash -c "',Normalization_CMD,'"'],'-echo');

%% Step 4: Subcortical Refinement (TODO: Make a custom function)

xtrmPrefix = [Patient_DIR,filesep,'scrt_xtrm'];
outputImage = [Patient_DIR,filesep,'glanat_t1_scrt.nii'];
InputFixImage = [MNI_DIR,'/t1.nii'];
InputMoveImage = [Patient_DIR,filesep,'glanat_t1.nii'];
subcorticalMask = [MNI_DIR,'/subcorticalMask.nii'];

SCRT_CMD = [ANTs_DIR,'/antsRegistration -v ',num2str(Verbose),' -d 3 -o [',xtrmPrefix,',',outputImage,'] -n Linear -u -f 1 -w [0.005,0.095] -a 1 -r [',InputFixImage,',',InputMoveImage,',1] \', ...
                        '-t Syn[0.3,4,3] -c [200x50x10x0,1e-6,7] -s 2x2x1x1vox -f 4x4x2x1 -l -x ',subcorticalMask,' -m CC[',InputFixImage,',',InputMoveImage,',1,5]'];
system(['bash -c "',SCRT_CMD,'"'],'-echo');
