%% Setup
clear; clc; close all;
UFNeuroVis_setEnv;
Processed_DIR = ['\\gunduz-lab.bme.ufl.edu\Data\ET CL Wearable Sensors\-------------',filesep,'Processed'];

%% Load Preop-CT and Postop-CT

if exist('ct','file') && ~exist([Processed_DIR,filesep,'preop_ct.nii'],'file')
    preop_ct = UFVTK2NifTi('ct');
	save_nii(preop_ct,[Processed_DIR,filesep,'preop_ct.nii']);
else
    preop_ct = loadNifTi([Processed_DIR,filesep,'preop_ct.nii']);
end

if exist('ct.postop','file') && ~exist([Processed_DIR,filesep,'postop_ct.nii'],'file')
    postop_CT = UFVTK2NifTi('ct.postop');
	save_nii(postop_CT,[Processed_DIR,filesep,'postop_ct.nii']);
else
    postop_CT = loadNifTi([Processed_DIR,filesep,'postop_ct.nii']);
end

%% Coregister Postop-CT to Preop-CT

T = readFuseMatrix([Processed_DIR,filesep,'postop2ct']);
T = inv(T);
T(:,4) = round(T(:,4));
POSTOPCT_tform = affine3d(T);
hfpostop_ct = niftiWarp(postop_CT, POSTOPCT_tform);
save_nii(hfpostop_ct,[Processed_DIR,filesep,'hfpostop_ct.nii']);

%% Transform both Postop-CT and Preop-CT to ACPC Coordinate

% Rename the filename to whatever CRW you will be using
[AC, PC, MC] = importCRW('Left VIM_SC.crw');

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
transformMatrix = T;

rpostop_ct_acpc = niftiWarp(hfpostop_ct, tform);
save_nii(rpostop_ct_acpc,[Processed_DIR,filesep,'rpostop_ct_acpc.nii']);
preop_ct_acpc = niftiWarp(preop_ct, tform);
save_nii(preop_ct_acpc,[Processed_DIR,filesep,'preop_ct_acpc.nii']);

%% BOVAFitter
preop_ct_acpc = loadNifTi([Processed_DIR,filesep,'preop_ct_acpc.nii']);
BovaAtlasFitter(preop_ct_acpc,Processed_DIR,NEURO_VIS_PATH);