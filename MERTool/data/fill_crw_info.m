function status = fill_crw_info(CrwData,File)
%{
FILL_CRW_INFO
    extracts patient data from MER structure and writes to .xls file
ARGS
    CrwData: structure, created by extract_crw_data()
    File: structure, with fields
        path: string, path to output file destination
        name: string, name of output file
        type: string, '.xls' or '.xlsx'
        full: string, [File.path File.name File.type]
 RETURNS
    status: logical 1 on success, 0 on failure
%}

%TODO this is still missing 'slider' information

crwInfo1 = [
    CrwData.targetpoint;
    CrwData.entrypoint;
    ];

crwInfo2 = [
    CrwData.acpoint;
    CrwData.pcpoint;
    CrwData.ctrlinepoint;
    CrwData.functargpoint;
    ];

crwInfo3 = [
    CrwData.acpcangle; % do these have an orientation?
    CrwData.clineangle;
    ];

status = xlswrite(File.full,crwInfo1,1,'B12');
if status
    status = xlswrite(File.full,crwInfo2,1,'B21');
end
if status
    status = xlswrite(File.full,crwInfo3,1,'B25');
end

end