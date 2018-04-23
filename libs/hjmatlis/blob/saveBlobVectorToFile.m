function count = saveBlobVectorToFile(blob, filePath);

	fid = fopen(filePath,'w');
	count = fwrite(fid, blob, '*uint8');
