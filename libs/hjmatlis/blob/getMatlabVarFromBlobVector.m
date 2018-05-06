function [variable originalname] = getMatlabVarFromBlobVector(blob)
	
	%create temp directory to generate temp file
	base_dir = pwd;

	temp_dir = strcat(base_dir,'/temp', randomString(20));
	mkdir(temp_dir);

	tempFilePath = strcat(temp_dir, '/tempfile.bin');

	fprintf('%s\n', tempFilePath);
	saveBlobVectorToFile(blob, tempFilePath)

	%load var
	[variable originalname] = getSingleVarFromMatlabFile(tempFilePath);

	%deleting temp file and folder
	delete(tempFilePath);
	rmdir(temp_dir);