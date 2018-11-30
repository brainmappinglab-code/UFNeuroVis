function ApmDataTable = fill_apm_match(ApmDataTable,DbsData)
%FILL_APM_MATCH
%   Detailed explanation goes here

nPass = size(ApmDataTable,2);

for iPass = 1:nPass
    nPoint = size(ApmDataTable{iPass},1);
    
    for iPoint = 1:nPoint
        ApmDataTable{iPass}.match(iPoint) = dbs_match(ApmDataTable,DbsData,iPoint,iPass);
    end
    
end

