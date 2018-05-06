function [variable originalname] = getSingleVarFromMatlabFile(filePath);
	%var = loadSingleVar(filePath);
	%	useful workaround to load directly
	[variable originalname] = getRealSingleMatlabVar(load(filePath,'-mat'));
	fclose all;