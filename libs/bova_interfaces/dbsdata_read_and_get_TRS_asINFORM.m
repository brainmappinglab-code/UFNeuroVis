function [ INFORM_TRS_table ] = dbsdata_read_and_get_TRS_asINFORM( dbsdata_path1 )

    %load file
    dbsdata_file1=load(dbsdata_path1,'-mat');
    
    %consider adding these fields
    %   idPatient	dtmEvaluation	intVisit	intFollowup	intTest  blnDBSR	blnDBSL
    %dbsdata stores only MRN, then store idMRNPatient, will need a later look up

    [ date_asinform ] = date_fromBOVAtoINFORM( dbsdata_file1.dos );
    date_asinform=[date_asinform ' 00:00:00 +0000'];
    
    blnDBSR=~isempty(strfind(lower(dbsdata_file1.surgery),'left'));
    blnDBSL=~isempty(strfind(lower(dbsdata_file1.surgery),'right'));
    
    info1_head={'idMRNPatient','dtmEvaluation','intVisit','intFollowup','intTest','blnDBSR','blnDBSL'};
    info1=table({dbsdata_file1.mrn},{date_asinform},[0],nan,nan,[blnDBSR],[blnDBSL],'VariableNames',info1_head);
    info1=[info1;info1;info1;info1];
    
    
    [ TRS_table ] = dbsdata_get_TRS( dbsdata_file1 );
    
    
    INFORM_TRS_table=[info1 TRS_table];
end