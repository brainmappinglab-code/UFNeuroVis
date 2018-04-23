function [blob datatype dim] = getBlobFromMatlabMatrix(matrix)
	%[blob datatype dim] = getBlobFromMatlabMatrix(matrix)
	% to reload this matrix use the corresponding function getMatlabMatrixFromBlob
	datatype = class(matrix);
	dim = size(matrix);
	blob = typecast(matrix(:),'uint8');