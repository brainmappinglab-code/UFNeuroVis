function [ Nii ] = loadNifTi( nifti, varargin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if nargin == 2
    switch varargin{1}
        case 'reformat'
            Nii = nifti;
            Nii.hdr.dime.bitpix = 16;
            Nii.img = single(Nii.img);
            Nii.dimension = Nii.hdr.dime.dim(2:4);
            Nii.XRange = (0:Nii.dimension(1)-1) * Nii.hdr.dime.pixdim(2);
            Nii.YRange = (0:Nii.dimension(2)-1) * Nii.hdr.dime.pixdim(3);
            Nii.ZRange = (0:Nii.dimension(3)-1) * Nii.hdr.dime.pixdim(4);
            Nii.XRange = Nii.XRange - (Nii.hdr.hist.originator(1) - 1) * Nii.hdr.dime.pixdim(2);
            if (Nii.hdr.hist.srow_x(1)) < 0
                Nii.XRange = -Nii.XRange;
            end
            Nii.YRange = Nii.YRange - (Nii.hdr.hist.originator(2) - 1) * Nii.hdr.dime.pixdim(3);
            Nii.ZRange = Nii.ZRange - (Nii.hdr.hist.originator(3) - 1) * Nii.hdr.dime.pixdim(4);
        case 'centerZ'
            if ischar(nifti)
                Nii = load_nii(nifti);
            else
                Nii = nifti;
            end
            Nii.hdr.dime.bitpix = 16;
            Nii.img = single(Nii.img);
            Nii.dimension = Nii.hdr.dime.dim(2:4);
            Nii.XRange = (0:Nii.dimension(1)-1) * Nii.hdr.dime.pixdim(2);
            Nii.YRange = (0:Nii.dimension(2)-1) * Nii.hdr.dime.pixdim(3);
            Nii.ZRange = (0:Nii.dimension(3)-1) * Nii.hdr.dime.pixdim(4);
            Nii.XRange = Nii.XRange - (Nii.hdr.hist.originator(1) - 1) * Nii.hdr.dime.pixdim(2);
            if (Nii.hdr.hist.srow_x(1)) < 0
                Nii.XRange = -Nii.XRange;
            end
            Nii.YRange = Nii.YRange - (Nii.hdr.hist.originator(2) - 1) * Nii.hdr.dime.pixdim(3);
            Nii.ZRange = Nii.ZRange - Nii.ZRange(end) / 2;
        otherwise
            error('Incorrect Usage');
    end
else 
    try 
        Nii = load_nii(nifti);
    catch ME
       disp('loadNifTi.m: Load_nii failed, trying load_untouch_nii');
       Nii = load_untouch_nii(nifti);
    end
    Nii.hdr.dime.bitpix = 16;
    Nii.img = single(Nii.img);
    Nii.dimension = size(Nii.img);
    Nii.XRange = (0:Nii.dimension(1)-1) * Nii.hdr.dime.pixdim(2);
    Nii.YRange = (0:Nii.dimension(2)-1) * Nii.hdr.dime.pixdim(3);
    Nii.ZRange = (0:Nii.dimension(3)-1) * Nii.hdr.dime.pixdim(4);
    
    if ~isfield(Nii,'untouch')
        Nii.XRange = Nii.XRange - (Nii.hdr.hist.originator(1) - 1) * Nii.hdr.dime.pixdim(2);
        Nii.YRange = Nii.YRange - (Nii.hdr.hist.originator(2) - 1) * Nii.hdr.dime.pixdim(3);
        Nii.ZRange = Nii.ZRange - (Nii.hdr.hist.originator(3) - 1) * Nii.hdr.dime.pixdim(4);
    else
        Nii.XRange = Nii.XRange + Nii.hdr.hist.qoffset_x;
        Nii.YRange = Nii.YRange + Nii.hdr.hist.qoffset_y;
        Nii.ZRange = Nii.ZRange + Nii.hdr.hist.qoffset_z;
    end
    if (Nii.hdr.hist.srow_x(1)) < 0
        Nii.XRange = -Nii.XRange;
    end
end

if ndims(Nii.img) == 3
    Nii.intensityRange(1) = prctile(prctile(prctile(Nii.img, 0), 0), 0);
    Nii.intensityRange(2) = prctile(prctile(prctile(Nii.img, 100), 100), 100);
    %Nii.img = (Nii.img - Nii.intensityRange(1)) / Nii.intensityRange(2);
    %Nii.img(Nii.img < 0) = 0;
    %Nii.img(Nii.img > 1) = 1;
end

[Nii.MeshAxial.X, Nii.MeshAxial.Y] = meshgrid(Nii.XRange,Nii.YRange);
Nii.MeshAxial.Z = ones(size(Nii.MeshAxial.X));
[Nii.MeshCoronal.X, Nii.MeshCoronal.Z] = meshgrid(Nii.XRange,Nii.ZRange);
Nii.MeshCoronal.Y = ones(size(Nii.MeshCoronal.X));
[Nii.MeshSagittal.Y, Nii.MeshSagittal.Z] = meshgrid(Nii.YRange,Nii.ZRange);
Nii.MeshSagittal.X = ones(size(Nii.MeshSagittal.Y));

end

