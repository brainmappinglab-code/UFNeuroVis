function [ TRS_table ] = dbsdata_get_TRS( dbsdata_file1 )
% [ TRS_table ] = dbsdata_get_TRS( dbsdata_file1 )
%   extract all TRS values for all the phases of the surgery (from the .dbs data)

if isempty(dbsdata_file1.TRSbaseline)
    dbsdata_file1.TRSbaseline=nan(9,5);
end
[ TRS_table_bas ] = dbsdata_parse_TRS( dbsdata_file1.TRSbaseline );
TRS_table_bas = [table({'baseline'},'VariableNames',{'strTestType'}) TRS_table_bas];

if isempty(dbsdata_file1.TRSpostmicro)
    dbsdata_file1.TRSpostmicro=nan(9,5);
end
[ TRS_table_postmer ] = dbsdata_parse_TRS( dbsdata_file1.TRSpostmicro );
TRS_table_postmer = [table({'postmer'},'VariableNames',{'strTestType'}) TRS_table_postmer];

if isempty(dbsdata_file1.TRSpostlead)
    dbsdata_file1.TRSpostlead=nan(9,5);
end
[ TRS_table_postlead ] = dbsdata_parse_TRS( dbsdata_file1.TRSpostlead );
TRS_table_postlead = [table({'postlead'},'VariableNames',{'strTestType'}) TRS_table_postlead];

if isempty(dbsdata_file1.TRSbestlead)
    dbsdata_file1.TRSbestlead=nan(9,5);
end
[ TRS_table_bestlead ] = dbsdata_parse_TRS( dbsdata_file1.TRSbestlead );
TRS_table_bestlead = [table({'bestlead'},'VariableNames',{'strTestType'}) TRS_table_bestlead];


TRS_table=[TRS_table_bas;TRS_table_postmer;TRS_table_postlead;TRS_table_bestlead];


end

