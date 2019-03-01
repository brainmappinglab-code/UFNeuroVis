function ApmDataTable = repair_apm_table(ApmDataTable,method)
%REPAIR_APM_TABLE Summary of this function goes here
%   Detailed explanation goes here

nPass = size(ApmDataTable,2);

%first remove trailing null entries, possibly a result of table allocation
for iPass = 1:nPass
    N = size(ApmDataTable{iPass},1);
    toDelete = [];
    for i = 1:N
        if ismissing(ApmDataTable{iPass}.path(i))
            toDelete = [toDelete i];
        end
    end
    ApmDataTable{iPass}(toDelete,:) = [];
end

%next, rewrite depths of out of range data points
if strcmp(method,'ignore')
    % using this option, delete any entries with depths out of range
    for iPass = 1:nPass
        N = size(ApmDataTable{iPass},1);
        toDelete = [];
        for i = 1:N
            if ApmDataTable{iPass}.depth(i) <= 0 || ApmDataTable{iPass}.depth(i) >= 40
                toDelete = [toDelete i];
            end
        end
        ApmDataTable{iPass}(toDelete,:) = [];
    end
end
if strcmp(method,'linear')
    % using this option, interpolate depths between any out of range depths
    for iPass = 1:nPass
        last = 1;
        N = size(ApmDataTable{iPass},1);
        for i = 1:N
            if (ApmDataTable{iPass}.depth(i) > 0 && ApmDataTable{iPass}.depth(i) < 40)
                if (last == i-1)
                    last = i;
                elseif (ApmDataTable{iPass}.depth(last) > 25 && ApmDataTable{iPass}.depth(i) < 10)
                    for j = last:i-1
                        ApmDataTable{iPass}.depth(j) = ApmDataTable{iPass}.depth(last);
                    end
                    last = i;                    
                else
                    x = linspace(ApmDataTable{iPass}.depth(last),ApmDataTable{iPass}.depth(i),(i-last)+1);
                    for j = 1:size(x,2)
                        ApmDataTable{iPass}.depth(last+j-1) = x(j);
                    end
                    last = i;
                end
            end
        end
    end
end

%finally, separate passes that may not have been reset
newApmDataTable = {};

%   threshold is an arbitrary cut-off value
%   if a depth is <threshold> less than the preceding depth,
%       assume it is beginning of a new pass
threshold = 14;

for iPass = 1:nPass
    N = size(ApmDataTable{iPass},1);
    last = 1;
    for i = 2:N
        if ApmDataTable{iPass}.depth(i) + threshold < (ApmDataTable{iPass}.depth(i-1))
            temp = ApmDataTable{iPass}(last:i-1,:);
            if size(newApmDataTable,2) == 0
                newApmDataTable = {temp};
            else
                newApmDataTable = [newApmDataTable {temp}];
            end
            last = i;
        end
    end
    temp = ApmDataTable{iPass}(last:N-1,:);
    if size(newApmDataTable,2) == 0
        newApmDataTable = {temp};
    else
        newApmDataTable = [newApmDataTable {temp}];
    end
end

if (size(newApmDataTable,1) ~= 0)
    ApmDataTable = newApmDataTable;
end
