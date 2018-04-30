function [atlasSTL, atlasInfo] = atlas2STL(atlasDir, tform)
if ~exist('atlasDir','var')
    atlasDir = uigetdir('','Please select the Atlas Folder');
end

if ~exist('tform','var')
    T = [1,0,0,0;0,1,0,0;0,0,1,0;0,0,0,1];
    tform = affine3d(T);
end

atlasThreshold = 0.4;
atlasInfo = dir([atlasDir,filesep,'*.nii']);
for n = 1:length(atlasInfo)
    atlas = loadNifTi([atlasDir,filesep,atlasInfo(n).name]);
    atlas = niftiWarp(atlas, tform);
    [atlasSTL(n).faces ,atlasSTL(n).vertices] = CONVERT_voxels_to_stl(atlas.img > diff(atlas.intensityRange)*atlasThreshold + atlas.intensityRange(1), atlas.XRange, atlas.YRange, atlas.ZRange);
end