function checkShouldSaveCRW(ProcessedDir,CRW)

prompt = {'Would you like to locally save this CRW for future use?'};
title = 'Save CRW?';
definput = {'mycrw'};
answer = inputdlg(prompt,title,[1 40],definput);

if ~isempty(answer)
   save(fullfile(ProcessedDir,[cell2str(answer) '_CRW.mat']),'-struct','CRW') 
end

end

