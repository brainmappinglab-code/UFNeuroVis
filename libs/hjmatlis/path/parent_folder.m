function outpath = parent_folder(pathFolder, level)

	if level <= 0
		outpath = pathFolder;
		return
	end

	poss = regexp(pathFolder, '\\|/', 'end');

	if length(poss)<=0
		fprintf('path already basepath, cannot go further\n');
		outpath = pathFolder;
		return
	end
	
	if poss(end)==length(pathFolder)
		poss(end)=[];
	end
	
	pos = poss(end - level+1);
	outpath = pathFolder(1:pos);