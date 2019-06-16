function [ TRS_table ] = dbsdata_get_TRS( dbsdata_file1 )
% [ TRS_table ] = dbsdata_get_TRS( dbsdata_file1 )
%   extract all TRS values for all the phases of the surgery (from the .dbs data)

[ TRS_table_bas ] = dbsdata_parse_TRS( dbsdata_file1.TRSbaseline );
TRS_table_bas = [table({'baseline'},'VariableNames',{'type'}) TRS_table_bas];

[ TRS_table_postmer ] = dbsdata_parse_TRS( dbsdata_file1.TRSpostmicro );
TRS_table_postmer = [table({'postmer'},'VariableNames',{'type'}) TRS_table_postmer];

[ TRS_table_postlead ] = dbsdata_parse_TRS( dbsdata_file1.TRSpostlead );
TRS_table_postlead = [table({'postlead'},'VariableNames',{'type'}) TRS_table_postlead];

[ TRS_table_bestlead ] = dbsdata_parse_TRS( dbsdata_file1.TRSbestlead );
TRS_table_bestlead = [table({'bestlead'},'VariableNames',{'type'}) TRS_table_bestlead];


TRS_table=[TRS_table_bas;TRS_table_postmer;TRS_table_postlead;TRS_table_bestlead];


end

