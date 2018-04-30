function [ coregisteredImage, transformMatrix ] = coregisterMRI( referenceImage, movingImage, varargin )
%coregisterMRI will try to coregister two NifTi images using MATLAB
%   coregisteredImage = coregisterMRI( referenceImage, movingImage )
%           Output Arguments:  
%               coregisteredImage: NifTi of coregistered Image
%               transformMatrix: The transformation matrix for
%                   coregistration -> affine3d object [4x4]
%           Input Arguments:
%               referenceImage: NifTi of the reference image, usually the
%                   T1 MRI of the patient.
%               movingImage: NifTi of the image to be registered, usually
%                   the Post-operative CT Scan or T2 or DTI Image
%
%   J. Cagle, 2018

disp 'Beginning coregistration...'
moveImage = movingImage.img;
movePixelDimensions = movingImage.hdr.dime.pixdim;
fixImage = referenceImage.img;
fixPixelDimensions = referenceImage.hdr.dime.pixdim;
Rfixed  = imref3d(size(fixImage),fixPixelDimensions(3),fixPixelDimensions(2),fixPixelDimensions(4));
Rmoving = imref3d(size(moveImage),movePixelDimensions(3),movePixelDimensions(2),movePixelDimensions(4));

if nargin == 2
    [optimizer,metric] = imregconfig('multimodal');
    optimizer.InitialRadius = 0.002;
    optimizer.Epsilon = 1.5e-4;
    optimizer.GrowthFactor = 1.5;
    optimizer.MaximumIterations = 300;
    transformMatrix = imregtform(moveImage, Rmoving, fixImage, Rfixed, 'rigid', optimizer, metric);
else
    transformMatrix = varargin{1};
end

coregisteredImage = referenceImage;
coregisteredImage.img = imwarp(moveImage, Rmoving, transformMatrix, 'bicubic', 'OutputView', Rfixed);
coregisteredImage = loadNifTi(coregisteredImage,'reformat');
disp 'Done'
end

