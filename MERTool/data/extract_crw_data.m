function CrwData = extract_crw_data(pathToCrwFile)

fid = fopen(pathToCrwFile,'r');
tline = fgetl(fid);
A = zeros(27,1);
ii = 1;
while tline ~= -1
    str = sscanf(tline,'%*s %f');
    if isempty(str)
        str = sscanf(tline,'%*s %*s %f');
    end
    if ~isempty(str)
        A(ii) = str;
        ii = ii + 1;
    end
    tline = fgetl(fid);
end
fclose(fid);

CrwData.targetpoint = [A(2) A(3) A(4)];
CrwData.entrypoint = [A(6) A(7) A(8)];
CrwData.acpoint = [A(10) A(11) A(12)];
CrwData.pcpoint = [A(14) A(15) A(16)];
CrwData.ctrlinepoint = [A(18) A(19) A(20)];
CrwData.functargpoint = [A(22) A(23) A(24)];
CrwData.orientation = A(25);
CrwData.acpcangle = A(26);
CrwData.clineangle = A(27);

end

