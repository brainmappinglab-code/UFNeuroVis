function new_array = arraycell_append(old_array, array_to_append, varargin)

	old_len = length(old_array);
	append_len = length(array_to_append);

	if length(varargin)>0
		if length(varargin)>1
			error('too much options specified');
		elseif strcmp(varargin{1},'start') %fill from the bottom of the stack
			for i=1:old_len
				array_to_append{append_len+i}=old_array{i};
				temp_array = array_to_append;
			end
		end
	else
		for i=1:append_len
			old_array{old_len+i}=array_to_append{i};
			temp_array = old_array;
		end
	end
	

	new_array = temp_array;