function remove_matching_folders(search_fldpath, is_sure)
%mv_matching_folders(search_fldpath, new_basepath)
%   moves matching folders keeping the relative path
if exist('is_sure','var') && strcmp(is_sure,'yes')
    a=dir_r(search_fldpath);
    %consider only folders
    a(~[a.isdir])=[];
    
    b_fld={a.name};
    
    if isempty(b_fld)
        fprintf('no folder matched. nothing was moved.\n');
    else
        for k=1:length(b_fld)           
            %delete folder
            rmdir(b_fld{k},'s');
            fprintf('remove folder %s\n',b_fld{k});
        end
        fprintf('finished removal\n');
    end
else
   fprintf('remove folders aborted\n'); 
end

