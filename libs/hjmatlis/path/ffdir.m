function foundPath = ffdir(dirName, fileName, varargin)
	%path = getFilePath(fileName[, typePath])
	% 	Find (Generic) File in specified Dir
	%	gets the path of the file with the name given,
	%	searching between folders added to matlab path
	%
	%	typePath	type path, 'dirpath' or 'filepath' (to include in the path output also the filename)

	flagFound = 0;
	
	% get path list
	if(length(varargin)>1)
		error('too much input arguments');
		return;
	end
		
	arr_path = lfrdir(dirName);
	%assignin('base', 'r', arr_path);

	%set standard path
	foundPath = {};

	for i = 1:length(arr_path)
		[pathstr, name, ext] = fileparts(arr_path{i});
		%fprintf('string found %s, searching %s\n',strcat(name,ext), fileName);
		if strcmp(strcat(name,ext), fileName)
			%adding found file into folder
			if(length(varargin)>0)
				if strcmp(varargin{1}, 'dirpath')
					foundPath = [foundPath; pathstr];
				elseif strcmp(varargin{1}, 'filepath')
					foundPath = [foundPath; arr_path{i}];
				else
					error('one or more options are not valid');
				end
			else
				foundPath = [foundPath; arr_path{i}];
			end
		end
	end
