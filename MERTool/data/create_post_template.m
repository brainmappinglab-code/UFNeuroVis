function status = create_post_template(Headers,cellIndex,File)
%CREATE_POST_TEMPLATE Summary of this function goes here
%   Detailed explanation goes here

% write headers to pathName/.../fileName, checking for errors after each write
status = xlswrite(File.full,Headers.postRecordingStim,1,['A' num2str(cellIndex)]);

end

