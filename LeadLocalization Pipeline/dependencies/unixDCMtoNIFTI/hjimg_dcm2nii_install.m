    
%script to do any installation or custom modification to run on the system
if isempty(getenv('NEURO_VIS_PATH_UNIX'))
    NEURO_VIS_PATH_UNIX = getenv('NEURO_VIS_PATH');
else
    NEURO_VIS_PATH_UNIX = getenv('NEURO_VIS_PATH_UNIX');
end
    
if ~strcmpi(NEURO_VIS_PATH_UNIX(end),'/')
    NEURO_VIS_PATH_UNIX = [NEURO_VIS_PATH_UNIX,'/'];
end

%hjimg__dcmsort = ['"',NEURO_VIS_PATH_UNIX,'dependencies/unixDCMtoNIFTI/hjimg__dcmsort"'];
%hjimg__convert_tonii = ['"',NEURO_VIS_PATH_UNIX,'dependencies/unixDCMtoNIFTI/hjimg__convert_tonii"'];
hjimg__dcmsort = [NEURO_VIS_PATH_UNIX,'dependencies/unixDCMtoNIFTI/hjimg__dcmsort'];
hjimg__convert_tonii = [NEURO_VIS_PATH_UNIX,'dependencies/unixDCMtoNIFTI/hjimg__convert_tonii'];

if isunix
    system(['chmod +x "' hjimg__dcmsort]);
    system(['chmod +x "' hjimg__convert_tonii]);
else
    system(['wsl chmod +x ' hjimg__dcmsort]);
    system(['wsl chmod +x ' hjimg__convert_tonii]);
end