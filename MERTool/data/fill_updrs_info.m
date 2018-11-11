function status = fill_updrs_info(DbsData,File)
%{
FILL_UPDRS_INFO
    extracts stim data from MER structure and writes to .xls file
ARGS
    DbsData: MER structure
    File: structure, with fields
        path: string, path to output file destination
        name: string, name of output file
        type: string, '.xls' or '.xlsx'
        full: string, [File.path File.name File.type]
 RETURNS
    status: logical 1 on success, 0 on failure
%}
%baseline
status = xlswrite(File.full,DbsData.baseline(1:2,1),1,'B29');
if status
    status = xlswrite(File.full,DbsData.baseline(3:4,1:5),1,'B32');
end
if status
    status = xlswrite(File.full,DbsData.baseline(5:12,1:2),1,'B35');
end
if status
    status = xlswrite(File.full,{DbsData.basedystonia;DbsData.basedyskinesia;DbsData.basecomments;},1,'B43');
end

%postmicro
if status
    status = xlswrite(File.full,DbsData.postmicro(1:2,1),1,'B48');
end
if status
    status = xlswrite(File.full,DbsData.postmicro(3:4,1:5),1,'B51');
end
if status
    status = xlswrite(File.full,DbsData.postmicro(5:12,1:2),1,'B54');
end
if status
    status = xlswrite(File.full,{DbsData.postmicrodystonia;DbsData.postmicrodyskinesia;DbsData.postmicrocomments;},1,'B62');
end

%postlead
if status
    status = xlswrite(File.full,DbsData.postlead(1:2,1),1,'B67');
end
if status
    status = xlswrite(File.full,DbsData.postlead(3:4,1:5),1,'B70');
end
if status
    status = xlswrite(File.full,DbsData.postlead(5:12,1:2),1,'B73');
end
if status
    status = xlswrite(File.full,{DbsData.postleaddystonia;DbsData.postleaddyskinesia;DbsData.postleadcomments;},1,'B81');
end

end

