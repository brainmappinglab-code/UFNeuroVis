function NifTi = UFVTK2NifTi(filename)
% Convert the UF VTK format to NifTi format

if ~exist(filename,'file')
    error('No such VTK file, check your file path');
end

fid = fopen(filename);
header = fread(fid, [1, 180], 'uint8=>uint8');
rawData = fread(fid, Inf, 'uint8=>uint16');
fclose(fid);

info = initHeader(header);

if ~strcmp(info.magic,'SVTK')
    error('Header is incorrect. Expected magic = ''SVTK'', but received magic = ''%s''',info.magic)
end

Data = VTKShort2Single(rawData);

if length(Data) ~= info.xdim*info.ydim*info.zdim
    error('Incorrect Datasize. Is this the same Image Header for the given Image file?');
end

img = reshape(Data, [info.xdim, info.ydim, info.zdim]) - min(Data);
CenterIndex = [abs(info.pixorg(1))/info.pdim(1) + 1, abs(info.pixorg(2))/info.pdim(2) + 1, abs(info.pixorg(3))/info.pdim(3) + 1];
NifTi = make_nii(img, info.pdim, CenterIndex, 4);
NifTi = loadNifTi(NifTi,'reformat');

reference = [0, 1, 0, 0;
    1, 0, 0, 0;
    0, 0, 1, 0;
    0, 0, 0, 1;];

xtrm = [info.xfrm([2:4,1],:), [0;0;0;1]];
newXtrm = xtrm(:,[2,1,3,4]);
T = newXtrm\reference;
T(:,4) = round(T(:,4));
tform = affine3d(T);
NifTi = niftiWarp(NifTi, tform);

function info = initHeader(rawdata)
info.magic = char(rawdata(1:4));
info.xdim = bitconcat(rawdata(5:8),'int32');
info.ydim = bitconcat(rawdata(9:12),'int32');
info.zdim = bitconcat(rawdata(13:16),'int32');
info.pdim = [bitconcat(rawdata(17:20),'single'),bitconcat(rawdata(21:24),'single'),bitconcat(rawdata(25:28),'single')];
info.pixorg = [bitconcat(rawdata(29:32),'single'),bitconcat(rawdata(33:36),'single'),bitconcat(rawdata(37:40),'single')];
info.brw2pix = [bitconcat(rawdata(41:44),'single'),bitconcat(rawdata(45:48),'single'),bitconcat(rawdata(49:52),'single');
                bitconcat(rawdata(53:56),'single'),bitconcat(rawdata(57:60),'single'),bitconcat(rawdata(61:64),'single');
                bitconcat(rawdata(65:68),'single'),bitconcat(rawdata(69:72),'single'),bitconcat(rawdata(73:76),'single');];
info.pix2brw = [bitconcat(rawdata(77:80),'single'),bitconcat(rawdata(81:84),'single'),bitconcat(rawdata(85:88),'single');
                bitconcat(rawdata(89:92),'single'),bitconcat(rawdata(93:96),'single'),bitconcat(rawdata(97:100),'single');
                bitconcat(rawdata(101:104),'single'),bitconcat(rawdata(105:108),'single'),bitconcat(rawdata(109:112),'single');];
info.suggMean = bitconcat(rawdata(113:116),'int32');
info.suggWindow = bitconcat(rawdata(117:120),'int32');
info.xfrm = [bitconcat(rawdata(121:124),'single'),bitconcat(rawdata(125:128),'single'),bitconcat(rawdata(129:132),'single');
            bitconcat(rawdata(133:136),'single'),bitconcat(rawdata(137:140),'single'),bitconcat(rawdata(141:144),'single');
            bitconcat(rawdata(145:148),'single'),bitconcat(rawdata(149:152),'single'),bitconcat(rawdata(153:156),'single');
            bitconcat(rawdata(157:160),'single'),bitconcat(rawdata(161:164),'single'),bitconcat(rawdata(165:168),'single');
            bitconcat(rawdata(169:172),'single'),bitconcat(rawdata(173:176),'single'),bitconcat(rawdata(177:180),'single');];

function data = bitconcat(header, precision)
switch precision
    case 'uint16'
        header = uint16(header);
        data = typecast(bitshift(header(1),8) + header(2), 'uint16');
    case 'uint32'
        header = uint32(header);
        data = typecast(bitshift(header(1),24) + bitshift(header(2),16) + bitshift(header(3),8) + header(4), 'uint32');
    case 'int16'
        header = uint16(header);
        data = typecast(bitshift(header(1),8) + header(2), 'int16');
    case 'int32'
        header = uint32(header);
        data = typecast(bitshift(header(1),24) + bitshift(header(2),16) + bitshift(header(3),8) + header(4), 'int32');
    case 'single'
        header = uint32(header);
        data = typecast(bitshift(header(1),24) + bitshift(header(2),16) + bitshift(header(3),8) + header(4), 'single');
end

function Data = VTKShort2Single(rawData)
Data = single(bitshift(rawData(1:2:end),8) + rawData(2:2:end));
for n = 1:length(Data)
    if Data(n) > 32767
        Data(n) = Data(n) - 65535;
    end
end