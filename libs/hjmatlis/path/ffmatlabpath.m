function foundPath = ffmatlabpath(fileName,varargin)
	%path = getFilePath(fileName[, typePath])
	% 	Find (Generic) File in Matlab Path
	%	gets the path of the file with the name given,
	%	searching between folders added to matlab path
	%
	%	typePath	type path, 'folderpath' or 'filepath' (to include in the path output also the filename)

	flagFound = 0;
	
	% get path list
	if(length(varargin)>1)
		error('too much input arguments');
		return;
	end
		
	pathString = evalin('base','path');
	arr_path = regexp(pathString,';','split');

	%set standard path
	foundPath = {};
	fullpath = 0;

	if length(varargin)>1
		if varargin{2}=='full'
			fullpath = 1;
		end
	end

	for i = 1:length(arr_path)

		if exist(fullfile(arr_path{i},fileName))>0
			%adding found file into folder
			if(length(varargin)>0)
				if varargin{1} == 'folderpath'
					foundPath = [foundPath arr_path{i}];
				elseif varargin{1} == 'filepath'
					foundPath = [foundPath fullfile(arr_path{i},fileName)];
				end
			else
				foundPath = [foundPath fullfile(arr_path{i},fileName)];
			end
		
		end
	end
	