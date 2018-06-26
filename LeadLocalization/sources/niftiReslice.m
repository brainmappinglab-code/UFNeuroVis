function transformedNii = niftiReslice(nii, refNii)

img = permute(nii.img,[2,1,3]);
img(isnan(img)) = 0;

newImageSize = size(refNii.img);
newImageSize = newImageSize([2 1 3]);

tform = affine3d([1     0     0     0
                  0     1     0     0
                  0     0     1     0
                  0     0     0     1]);

Ref = imref3d(size(img),nii.XRange([1 end]) + [-1 1] * nii.hdr.dime.pixdim(2) / 2,...
        nii.YRange([1 end]) + [-1 1] * nii.hdr.dime.pixdim(3) / 2,...
        nii.ZRange([1 end]) + [-1 1] * nii.hdr.dime.pixdim(4) / 2);

refWarp = imref3d(newImageSize,refNii.XRange([1 end]) + [-1 1] * refNii.hdr.dime.pixdim(2) / 2,...
        refNii.YRange([1 end]) + [-1 1] * refNii.hdr.dime.pixdim(3) / 2,...
        refNii.ZRange([1 end]) + [-1 1] * refNii.hdr.dime.pixdim(4) / 2);
    
[warpImage,refWarp] = imwarp(img, Ref, tform, 'OutputView', refWarp);
warpImage = permute(warpImage,[2,1,3]);

XRange = linspace(refWarp.XWorldLimits(1) + refWarp.PixelExtentInWorldX / 2, refWarp.XWorldLimits(2) - refWarp.PixelExtentInWorldX / 2, refWarp.ImageSize(2));
YRange = linspace(refWarp.YWorldLimits(1) + refWarp.PixelExtentInWorldY / 2, refWarp.YWorldLimits(2) - refWarp.PixelExtentInWorldY / 2, refWarp.ImageSize(1));
ZRange = linspace(refWarp.ZWorldLimits(1) + refWarp.PixelExtentInWorldZ / 2, refWarp.ZWorldLimits(2) - refWarp.PixelExtentInWorldZ / 2, refWarp.ImageSize(3));
newWarp = make_nii(warpImage,[refWarp.PixelExtentInWorldX refWarp.PixelExtentInWorldY refWarp.PixelExtentInWorldZ],...
                             [-(XRange(1))/mean(diff(XRange)) + 1, -(YRange(1))/mean(diff(YRange)) + 1, -(ZRange(1))/mean(diff(ZRange)) + 1],...
                             16);

transformedNii = loadNifTi(newWarp, 'reformat');