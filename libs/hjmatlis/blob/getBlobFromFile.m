function blob = getBlobFromFile(filePath)
	% blob = getBinaryFromFile(filePath)

	fid = fopen(filePath);
	blob = fread(fid, inf, '*uint8');
	fclose(fid);
	