function NifTi2UFVTK(filename)
% Convert the NifTi format to UF VTK format

if ~exist(filename,'file')
    error('No such NifTi file, check your file path');
end

Nii = loadNifTi(filename);
xdim = size(Nii.img,1);
ydim = size(Nii.img,2);
zdim = size(Nii.img,3);
xoffset = round((512-xdim)/2);
yoffset = round((512-ydim)/2);
slice = single(zeros(512,512,zdim));
for k = 1:zdim
    slice(xoffset:xoffset+xdim-1,yoffset:yoffset+ydim-1,k) = Nii.img(:,:,k);
end
rawData = reshape(slice,[1, 512*512*zdim]);
rawBytes = swapbytes(int16(rawData));

Originator = [Nii.hdr.hist.qoffset_x,Nii.hdr.hist.qoffset_y,Nii.hdr.hist.qoffset_z];

% Headers
header.magic = int8([83 86 84 75]); % 'SVTK'
header.xdim = typecast(swapbytes(int32(512)),'int8');
header.ydim = typecast(swapbytes(int32(512)),'int8');
header.zdim = typecast(swapbytes(int32(zdim)),'int8');
header.pdim = typecast(swapbytes(single(Nii.hdr.dime.pixdim(2:4))),'int8');
header.pixorg = typecast(swapbytes(single(Originator)),'int8');
header.brw2pix = int8([0,0,0,0,63,128,0,0,0,0,0,0,63,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,128,0,0]);
header.pix2brw = int8([0,0,0,0,63,128,0,0,0,0,0,0,63,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,128,0,0]);
header.suggMean = int8([0,0,6,33]);
header.suggWindow = int8([0,0,3,77]);
header.xfrm = int8([0,0,0,0,0,0,0,0,0,0,0,0,63,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,128,0,0,63,128,0,0,63,128,0,0,63,128,0,0]);

fid = fopen(filename(1:end-4),'wb');
fwrite(fid,header.magic,'int8');
fwrite(fid,header.xdim,'int8');
fwrite(fid,header.ydim,'int8');
fwrite(fid,header.zdim,'int8');
fwrite(fid,header.pdim,'int8');
fwrite(fid,header.pixorg,'int8');
fwrite(fid,header.brw2pix,'int8');
fwrite(fid,header.pix2brw,'int8');
fwrite(fid,header.suggMean,'int8');
fwrite(fid,header.suggWindow,'int8');
fwrite(fid,header.xfrm,'int8');
fwrite(fid,rawBytes,'int16');
fclose(fid);
