function [realvar originalname] = getRealSingleMatlabVar(loadedvar)

	%[realvar originalname] = getRealMatlabVar(loadedvar)
	%	workaround to get a var matlab loaded with 'load' function assigned to realvar, not as struct inside it
	%	useful only if there is a single var in it, not multiple

	keys = fieldnames(loadedvar);
	originalname = keys{1};
	realvar = loadedvar.(originalname);
