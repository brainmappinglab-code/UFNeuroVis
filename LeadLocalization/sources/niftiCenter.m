function newNifTi = niftiCenter(nii)
T = [1,0,0,0; 0,1,0,0; 0,0,1,0; 0,0,0,1];
centerSlice = round(nii.dimension/2);
center = [nii.XRange(centerSlice(1)),nii.YRange(centerSlice(2)),nii.ZRange(centerSlice(3))];
T(4,1:3) = -center;
tform = affine3d(T);
newNifTi = niftiWarp(nii, tform);