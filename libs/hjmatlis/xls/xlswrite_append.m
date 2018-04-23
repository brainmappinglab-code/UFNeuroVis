function xlswrite_append(filepath, cellData, sheet, varargin)
% xlswrite_append(filepath, cellData, sheet[, options])
	
	if exist(filepath)==0
		fprintf('file did not exist, new rows will start from 0\n');
		xlswrite(filepath, cellData, sheet);
		
		return
	end
	[num, cells, old_array] = xlsread(filepath);
	row_num = size(old_array, 1);
	position = strcat('A', num2str(row_num + 1));
	fprintf('new rows will start from %s\n',position);
	xlswrite(filepath, cellData, sheet, position);
