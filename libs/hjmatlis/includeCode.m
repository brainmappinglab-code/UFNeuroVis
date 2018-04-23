function includeCode(filePath)
	% includeCode(filePath)
	%	this function includes the provided code (it needs to be Matlab code) where called
	[fid,message] = fopen(filePath);
	if(fid<0)
		try
            cprintf([1,0.5,0],'??? ERROR - INCLUDE > This file was not found\n \t Path: %s\n\n', filePath);
		catch ME
            error('expandMat:INCLUDE','INCLUDE > This file was not found\n \t Path: %s', filePath);
		end
		
		return;
    end
    
	chars = fscanf(fid,'%c');
	fclose(fid);

	evalin('base',chars);

	%fprintf('debug %s',string{1});
	%assignin('base','string',chars);