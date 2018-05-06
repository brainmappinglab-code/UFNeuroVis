function out = array_struct_field_add(array, keyName, varargin)
	%array_struct_field_add(array, keyName[, value, interval])
	%	interval need to be written as string with format '1:end'

	%initial values
	value = [];
	startList = 1;
	endList = length(array);
	temparr = [];

	if length(varargin) > 2
		error('too much options specified');
		return;
	elseif length(varargin) > 1
		value = varargin{1};%get value to set

		interval = varargin{2};%get intervals
		interval = regexp(interval, '([^:]*)', 'match');

		if length(interval)~=2
			error('interval format error');
			return;
		end

		startList = str2num(interval{1});
		endList = str2num(interval{2});

		fprintf('debug array length %d, start %d, end %d',length(array), startList, endList);

		if startList < 1
			error('start interval too low');
		end
		if endList > length(array)
			error('end interval too large');
		end

	elseif length(varargin)> 0
		value = varargin{1};
	end

	temparr = [];

	for i=1:length(array)
		if and((i >= startList),(i <= endList))
			temparr = [temparr setfield(array(i), keyName, value)];
		else
			try 
				getfield(array(i), keyName)
				temparr = [temparr array(i)];
			catch
				temparr = [temparr setfield(array(i), keyName, [])];
			end
		end
	end

	out = temparr;
	