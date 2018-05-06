function [  ] = fwrite_list_string( filename, strings)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fid = fopen(filename,'w');
for row = 1:size(strings,1)
    fprintf(fid, repmat('%s\t',1,size(strings,2)-1), strings{row,1:end-1});
    fprintf(fid, '%s\n', strings{row,end});
end
fclose(fid);

end

