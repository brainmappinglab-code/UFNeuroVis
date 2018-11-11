function status = fill_trs_info(DbsData,File)
%{
FILL_TRS_INFO
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
status = xlswrite(File.full,DbsData.TRSbaseline(1:3,1),1,'B29');
if status
    status = xlswrite(File.full,DbsData.TRSbaseline(4:6,1:5),1,'B33');
end
if status
    status = xlswrite(File.full,DbsData.TRSbaseline(7,1:2),1,'B37');
end
if status
    status = xlswrite(File.full,DbsData.TRSbaseline(8:9,1:2),1,'B39');
end
if status
    status = xlswrite(File.full,{DbsData.TRSbasedystonia;DbsData.TRSbasedyskinesia;DbsData.TRSbasecomments;},1,'B41');
end

%postmicro
if status
    status = xlswrite(File.full,DbsData.TRSpostmicro(1:3,1),1,'B46');
end
if status
    status = xlswrite(File.full,DbsData.TRSpostmicro(4:6,1:5),1,'B50');
end
if status
    status = xlswrite(File.full,DbsData.TRSpostmicro(7,1:2),1,'B54');
end
if status
    status = xlswrite(File.full,DbsData.TRSpostmicro(8:9,1:2),1,'B56');
end
if status
    status = xlswrite(File.full,{DbsData.TRSpostmicrodystonia;DbsData.TRSpostmicrodyskinesia;DbsData.TRSpostmicrocomments;},1,'B58');
end

%postlead
if status
    status = xlswrite(File.full,DbsData.TRSpostlead(1:3,1),1,'B63');
end
if status
    status = xlswrite(File.full,DbsData.TRSpostlead(4:6,1:5),1,'B67');
end
if status
    status = xlswrite(File.full,DbsData.TRSpostlead(7,1:2),1,'B71');
end
if status
    status = xlswrite(File.full,DbsData.TRSpostlead(8:9,1:2),1,'B73');
end
if status
    status = xlswrite(File.full,{DbsData.TRSpostleaddystonia;DbsData.TRSpostleaddyskinesia;DbsData.TRSpostleadcomments;},1,'B75');
end

end