function iMatch = dbs_match(aH,iPoint,iPass)
%{
DISPLAY_MATCH
    uses indices of APM file to find closest matching DBS entry
ARGS
    aH: handle of axes to plot 3D trajectory on
    iPoint: row-index of selected point in ApmDataTable
    iPass: depth-index of selected point in ApmDataTable
RETURNS
    None
%}

f = ancestor(aH,'figure');
ApmDataTable = getappdata(f,'ApmDataTable');
DbsData = getappdata(f,'DbsData');
depth = ApmDataTable{iPass}.depth(iPoint);

flag = 0;

for iMatch = 1:size(DbsData.data1,1)
    % get depth of DBS entry
    dbs_depth = str2double(DbsData.data1{iMatch,2,iPass});
    % find difference between DBS entry and APM entry depths
    delta = abs(depth - dbs_depth);
    % if within .5mm, set flag
    if delta < 0.5
        flag = 1;
        break
    end
end

% if no match found, try again with higher threshold (1mm)
if ~flag
    for iMatch = 1:size(DbsData.data1,1)
        dbs_depth = str2double(DbsData.data1{iMatch,2,iPass});
        delta = abs(depth - dbs_depth);
        if delta < 1
            flag = 1;
            break
        end
    end
end

% if still no match found, return 0
if ~flag
    iMatch = 0;
    fprintf('No close match found.\n')
end

end