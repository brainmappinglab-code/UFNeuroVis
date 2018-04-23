function varargout=cp_matching_files(search_fpath, new_basepath)
%[copied_files_list]=cp_matching_files(search_fldpath, new_basepath)
%   copy matching files keeping the relative path

    a=dir_r(search_fpath);
    %consider only files
    a([a.isdir])=[];
    
    b_files={a.name};
    
    if nargout==1
        if isempty(b_files)
            fprintf('no file matched. Nothing was copied.\n');
        else
            for k=1:length(b_files)
                old_fldpath=fileparts(b_files{k});
                new_fpath=fullfile(new_basepath,old_fldpath);
                if ~exist(new_fpath,'dir')
                    mkdir(new_fpath);
                end
                movefile(b_files{k},new_fpath,'f');
            end
            varargout{1}=b_files;
            fprintf('finished copying\n');
        end
    else
        if isempty(b_files)
            fprintf('no file matches. Nothing was copied.\n');
        else
            for k=1:length(b_files)
                %append new basepath
                new_fpath=fullfile(new_basepath,b_files{k});
                new_fldpath=fileparts(new_fpath);
                if ~exist(new_fldpath,'dir')
                    mkdir(new_fldpath);
                end
                copyfile(b_files{k},new_fpath,'f');
                fprintf('%s, copied to : %s \n',b_files{k},new_fpath);
            end
            fprintf('finished copying\n');
        end
    end
end

