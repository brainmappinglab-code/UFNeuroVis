function tform=LoadDBSArchACPC(filename)
%% tform=LoadDBSArchACPC(filename)
%
%  Loads the ACPC coordinates as determined by the clinical team from the .crw file
%
%  Written by: Jackson Cagle, 2020

%#ok<*NASGU>

fid = fopen(filename,'r');
line = fgets(fid);
while line > 0 
    if strfind(line,'AC Point') > 0
        Valid = fgets(fid);
        AP = sscanf(fgets(fid),'%s = %f');
        LT = sscanf(fgets(fid),'%s = %f');
        AX = sscanf(fgets(fid),'%s = %f');
        AC = [LT(3), AP(3), AX(3)];
    end
    if strfind(line,'PC Point') > 0
        Valid = fgets(fid);
        AP = sscanf(fgets(fid),'%s = %f');
        LT = sscanf(fgets(fid),'%s = %f');
        AX = sscanf(fgets(fid),'%s = %f');
        PC = [LT(3), AP(3), AX(3)];
    end
    if strfind(line,'Ctrln Point') > 0
        Valid = fgets(fid); 
        AP = sscanf(fgets(fid),'%s = %f');
        LT = sscanf(fgets(fid),'%s = %f');
        AX = sscanf(fgets(fid),'%s = %f');
        MC = [LT(3), AP(3), AX(3)];
    end
    line = fgets(fid);
end
fclose(fid);

Origin = (AC + PC) / 2;
temp = (MC - Origin) / rssq(MC - Origin);
J = (AC - PC) / rssq(AC - PC);
I = cross(J,temp)/rssq(cross(J,temp));
K = cross(I,J)/rssq(cross(I,J));

Old = [Origin+I,1; Origin+J,1; Origin+K,1; Origin,1];
New = [1,0,0,1; 0,1,0,1; 0,0,1,1; 0,0,0,1];

T = Old\New;
T(:,4) = round(T(:,4));
tform = affine3d(T);

end