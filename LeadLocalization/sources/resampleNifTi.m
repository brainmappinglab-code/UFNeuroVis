function [ newNifTi ] = resampleNifTi( NifTi, dimensionResolution )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

T = [1,0,0,0; 0,1,0,0; 0,0,1,0; 0,0,0,1];
tform = affine3d(T);

NifTi_image = permute(NifTi.img,[2,1,3]);
NifTi_image(isnan(NifTi_image)) = 0;

Ref = imref3d(size(NifTi_image),NifTi.XRange([1 end]) + [-1 1] * NifTi.hdr.dime.pixdim(2) / 2,...
        NifTi.YRange([1 end]) + [-1 1] * NifTi.hdr.dime.pixdim(3) / 2,...
        NifTi.ZRange([1 end]) + [-1 1] * NifTi.hdr.dime.pixdim(4) / 2);

ImageSize(1) = NifTi.hdr.dime.pixdim(2) / dimensionResolution(1) * NifTi.hdr.dime.dim(2);
ImageSize(2) = NifTi.hdr.dime.pixdim(3) / dimensionResolution(2) * NifTi.hdr.dime.dim(3);
ImageSize(3) = NifTi.hdr.dime.pixdim(4) / dimensionResolution(3) * NifTi.hdr.dime.dim(4);
ImageSize = round(ImageSize);

outputRef = imref3d(ImageSize, NifTi.XRange([1 end]) + [-1 1] * dimensionResolution(1) / 2,...
        NifTi.YRange([1 end]) + [-1 1] * dimensionResolution(2) / 2,...
        NifTi.ZRange([1 end]) + [-1 1] * dimensionResolution(3) / 2);
    
newImage = imwarp(NifTi_image, Ref, tform, 'OutputView', outputRef, 'SmoothEdges', false );
newImage = permute(newImage, [2,1,3]);

XRange = linspace(outputRef.XWorldLimits(1) + outputRef.PixelExtentInWorldX / 2, outputRef.XWorldLimits(2) - outputRef.PixelExtentInWorldX / 2, outputRef.ImageSize(2));
YRange = linspace(outputRef.YWorldLimits(1) + outputRef.PixelExtentInWorldY / 2, outputRef.YWorldLimits(2) - outputRef.PixelExtentInWorldY / 2, outputRef.ImageSize(1));
ZRange = linspace(outputRef.ZWorldLimits(1) + outputRef.PixelExtentInWorldZ / 2, outputRef.ZWorldLimits(2) - outputRef.PixelExtentInWorldZ / 2, outputRef.ImageSize(3));

newWarp = make_nii(newImage,[outputRef.PixelExtentInWorldX outputRef.PixelExtentInWorldY outputRef.PixelExtentInWorldZ],...
                             [-(XRange(1))/mean(diff(XRange)) + 1, -(YRange(1))/mean(diff(YRange)) + 1, -(ZRange(1))/mean(diff(ZRange)) + 1],...
                             16);
                         
newNifTi = loadNifTi(newWarp, 'reformat');

end

