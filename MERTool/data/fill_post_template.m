function status = fill_post_template(DbsData,cellIndex,trackIndex,File)
%FILL_POST_TEMPLATE Summary of this function goes here
%   Detailed explanation goes here

trackLength = size(DbsData.data21,1);
topRow = cellIndex + 1;

type = cell(trackLength,1);
response = cell(trackLength,1);

% decode stim type
for i = 1:trackLength
    if ~isempty(DbsData.data21{i,4,trackIndex})
        switch DbsData.data21{i,4,trackIndex}
            case '1'
                type{i,1} = 'Electric';
            otherwise
                type{i,1} = '';
        end
    end
end

% decode response type
for i = 1:trackLength
    if ~isempty(DbsData.data21{i,5,trackIndex})
        switch DbsData.data21{i,5,trackIndex}
            case '1'
                response{i,1} = 'Positive';
            case '2'
                response{i,1} = 'Negative';
            otherwise
                response{i,1} = '';
        end
    end
end

depth = DbsData.data21(:,1,trackIndex);
current = DbsData.data21(:,2,trackIndex);
description = DbsData.data21(:,3,trackIndex);

status = xlswrite(File.full,depth,1,['A' num2str(topRow)]);
if status
    status = xlswrite(File.full,type,1,['B' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,current,1,['C' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,response,1,['D' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,description,1,['E' num2str(topRow)]);
end



end

