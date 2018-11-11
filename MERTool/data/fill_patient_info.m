function status = fill_patient_info(DbsData,File)
%{
FILL_PATIENT_INFO
    extracts patient data from MER structure and writes to .xls file
ARGS
    DbsData: structure, contains MER data
    File: structure, with fields
        path: string, path to output file destination
        name: string, name of output file
        type: string, '.xls' or '.xlsx'
        full: string, [File.path File.name File.type]
 RETURNS
    status: logical 1 on success, 0 on failure
%}

patientInfo = {
    DbsData.lastname;
    DbsData.firstname;
    DbsData.middlename;
    DbsData.mrn; % TODO : this is writing as a number, not as a string?
    DbsData.dob;
    DbsData.study;
    '';
    DbsData.dos;
    DbsData.surgery;
    };

status = xlswrite(File.full,patientInfo,1,'B1');
if status
    if DbsData.hemisphere == 2
        status = xlswrite(File.full,{'Left'},1,'B7');
    else
        status = xlswrite(File.full,{'Right'},1,'B7');
    end
end