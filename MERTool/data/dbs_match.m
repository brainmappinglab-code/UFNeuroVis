function match = dbs_match(ApmDataTable,DbsData,iPoint,iPass)
%{
DISPLAY_MATCH
    uses indices of APM file to find closest matching DBS entry
ARGS
    iPoint: row-index of selected point in ApmDataTable
    iPass: depth-index of selected point in ApmDataTable
RETURNS
    None
%}

depth = ApmDataTable{iPass}.depth(iPoint);

match = 0;
best = 999;

for i = 1:size(DbsData.data1,1)
    % get depth of DBS entry
    dbs_depth = str2double(DbsData.data1{i,2,iPass});
    % find difference between DBS entry and APM entry depths
    delta = abs(depth - dbs_depth);
    % if within .5mm, set flag
    if delta < 0.5 && delta < best
        match = i;
    end
end