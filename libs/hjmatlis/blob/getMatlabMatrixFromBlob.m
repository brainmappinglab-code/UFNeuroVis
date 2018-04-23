function matrix = getMatlabMatrixFromBlob(blob, datatype, dim)
	% blob = getBinaryOfFile(filePath)
	% to use with data obtained from getBlobFromMatlabMatrix

	matrix = reshape(typecast(blob, datatype), dim);
	