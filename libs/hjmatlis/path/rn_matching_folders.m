function rn_matching_folders(search_fldpath, new_fld_name)
%rn_matching_folders(search_fldpath, new_basepath)
%   renames matching folders keeping the relative path

    a=dir_r(search_fldpath);
    %consider only folders
    a(~[a.isdir])=[];
    
    b_fld={a.name};
    
    if isempty(b_fld)
        fprintf('no folder matched. nothing was moved.\n');
    else
        for k=1:length(b_fld)
            is_to_remove=true;
            [old_fldpath, old_name, old_ext]=fileparts(b_fld{k});
            if strcmp([old_name,old_ext],new_fld_name)
                fprintf('folder %s, already in the correct format. skippping\n',b_fld{k});
                continue
            end
            new_fldpath=fullfile(old_fldpath,new_fld_name);
            if ~exist(new_fldpath,'dir')
                mkdir(new_fldpath);
            else
               %do not remove this folder later
               fprintf('folder %s, already in exist.\n',new_fldpath);
               is_to_remove=false;
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
                %discard beginning of path
                cc_fld=c_fld{k2}(length(b_fld{k})+2:end);
                %substitute folder path with the new one
                new_sub_fldpath=fullfile(new_fldpath,cc_fld);
                if ~exist(new_sub_fldpath,'dir')
                    mkdir(new_sub_fldpath);
                end 
            end

            for k2=1:length(c_files)
                %discard beginning of path
                cc_files=c_files{k2}(length(b_fld{k})+2:end);
                %substitute folder path with the new one
                new_sub_fpath=fullfile(new_fldpath,cc_files);

                movefile(c_files{k2},new_sub_fpath,'f');
                fprintf('file %s, renamed to : %s\n',c_files{k2},new_sub_fpath);
            end

            if is_to_remove
                %delete old folder (now empty)
                rmdir(b_fld{k},'s');
            end
            fprintf('folder %s, renamed to : %s\n',b_fld{k},new_fldpath);
        end
        fprintf('finished renaming\n');
    end
end


