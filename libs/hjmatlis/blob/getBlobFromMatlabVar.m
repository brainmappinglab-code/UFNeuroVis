function blob = getBlobFromMatlabVar(variable)
	%blob = getBlobFromMatlabVarWithName(variableName)

	%create temp directory to generate temp file
	base_dir = pwd;

	temp_dir = strcat(base_dir, filesep,'temp', randomString(20));
	mkdir(temp_dir);

	tempFilePath = strcat(temp_dir, filesep, 'tempfile.bin');
	
	save(tempFilePath,'variable');
	%cmdString = strcat('save(', char(39), tempFilePath, char(39), ', ', char(39), variable, char(39), ')');
	%fprintf('%s\n', cmdString);
	%evalin('base', cmdString);

	%fprintf('%s\n', tempFilePath);
	blob = getBlobFromFile(tempFilePath);

	%deleting temp file and folder
	delete(tempFilePath);
	rmdir(temp_dir);