function text = getTextFromFile(filePath)

	[fid,message] = fopen(filePath);
	if(fid<0)
		try
            cprintf([1,0.5,0],'??? ERROR - READ > This file was not found\n \t Path: %s\n\n', filePath);
		catch ME
            error('expandMat:READFILE','READ > This file was not found\n \t Path: %s', filePath);
		end
		
		return;
    end
    
	text = fscanf(fid,'%c');
	fclose(fid);