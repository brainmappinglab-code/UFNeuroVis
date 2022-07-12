function coregistrationANTs(NEURO_VIS_PATH,folder,linearity) 

% ANTs_DIR = [NEURO_VIS_PATH,filesep,'dependencies',filesep,'ANTs',filesep,'bin'];
ANTs_path = '~/tmp/install/bin/antsRegistration';

Verbose = 1;
% xtrmPrefix = [folder,filesep,'ct-t1_transformation'];
% outputImage = [folder,filesep,'rpostop_ct.nii'];
% InputFixImage = [folder,filesep,'anat_t1.nii'];
% InputMoveImage = [folder,filesep,'postop_ct.nii'];
xtrmPrefix = './Processed/ct-t1_transformation';
outputImage = './Processed/rpostop_ct.nii';
InputFixImage = './Processed/anat_t1_acpc.nii';
InputMoveImage = './Processed/postop_ct.nii';

switch linearity
    case 'linear'
        Normalization_CMD = [ANTs_path,' -v ',num2str(Verbose),' -d 3 -o [',xtrmPrefix,',',outputImage,'] -n Linear -u -f 1 -w [0.005,0.095] -a 1 -r [',InputFixImage,',',InputMoveImage,',1] \', ...
                        '-t Rigid[0.25] -c [1000x500x250x0,1e-6,10] -s 4x3x2x1vox -f 12x8x4x1 -m MI[',InputFixImage,',',InputMoveImage,',1,32,Random,0.25]'];
    case 'nonlinear'
        Normalization_CMD = [ANTs_path,' -v ',num2str(Verbose),' -d 3 -o [',xtrmPrefix,',',outputImage,'] -n Linear -u -f 1 -w [0.005,0.095] -a 1 -r [',InputFixImage,',',InputMoveImage,',1] \', ...
                            '-t Rigid[0.25] -c [1000x500x250x0,1e-6,10] -s 4x3x2x1vox -f 12x8x4x1 -m MI[',InputFixImage,',',InputMoveImage,',1,32,Random,0.25] \',...
                            '-t Affine[0.15] -c [1000x500x250x0,1e-6,10] -s 4x3x2x1vox -f 8x4x2x1 -m MI[',InputFixImage,',',InputMoveImage,',1,32,Random,0.25] \',...
                            '-t Syn[0.3,4,3] -c [1000x500x250x0,1e-6,7] -s 2x2x1x1vox -f 4x4x2x1 -m MI[',InputFixImage,',',InputMoveImage,',1,32,Random,0.25]'];
    otherwise
        warning('WHAT ARE YOU DOING?');
end
[status, result] = system(['bash -c "',Normalization_CMD,'"'],'-echo');
