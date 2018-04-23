function mv_matching_folders(search_fldpath, new_basepath)
%mv_matching_folders(search_fldpath, new_basepath)
%   moves matching folders keeping the relative path

    a=dir_r(search_fldpath);
    %consider only folders
    a(~[a.isdir])=[];
    
    b_fld={a.name};
    
    if isempty(b_fld)
        fprintf('no folder matched. nothing was moved.\n');
    else
        for k=1:length(b_fld)
            new_fldpath=fullfile(new_basepath,b_fld{k});
            if ~exist(new_fldpath,'dir')
                mkdir(new_fldpath);
            end
            %list files to move inside folder
            c=dir_ra([b_fld{k} filesep '*']);%get folder to move
            if isempty(c)
                continue;
            end
            s=[c.isdir];
            c_files={c(~s).name};
            c_fld={c(s).name};
            %create all the folders
            for k2=1:length(c_fld)
                new_sub_fldpath=fullfile(new_basepath,c_fld{k2});
                if ~exist(new_sub_fldpath,'dir')
                    mkdir(new_sub_fldpath);
                end 
            end
            
            for k2=1:length(c_files)
                %append newbasepath
                new_sub_fpath=fullfile(new_basepath,c_files{k2});
                movefile(c_files{k2},new_sub_fpath,'f');
                fprintf('file %s, moved to : %s\n',c_files{k2},new_sub_fpath);
            end
            
            %delete old folder (now empty)
            rmdir(b_fld{k},'s');
            fprintf('folder %s, moved to : %s\n',b_fld{k},new_fldpath);
        end
        fprintf('finished moving\n');
	end
end

