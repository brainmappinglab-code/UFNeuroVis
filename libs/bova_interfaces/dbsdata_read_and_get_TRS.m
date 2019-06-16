function [ TRS_table ] = dbsdata_read_and_get_TRS( dbsdata_path1 )

    %load file
    dbsdata_file1=load(dbsdata_path1,'-mat');

    [ TRS_table ] = dbsdata_get_TRS( dbsdata_file1 );
end