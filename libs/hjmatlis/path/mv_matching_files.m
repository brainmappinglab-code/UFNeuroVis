function varargout=mv_matching_files(search_fpath, new_basepath)
%[moved_files_list]=mv_matching_files(search_fldpath, new_basepath)
%   moves matching files keeping the relative path
%   no folder will be deleted

    a=dir_r(search_fpath);
    %consider only files
    a([a.isdir])=[];
    
    b_files={a.name};
    
    if nargout==1
        if isempty(b_files)
            fprintf('no file matched. Nothing was moved.\n');
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
            fprintf('finished moving\n');
        end
    else
        if isempty(b_files)
            fprintf('no file matches. Nothing was moved.\n');
        else
            for k=1:length(b_files)
                %append new basepath
                new_fpath=fullfile(new_basepath,b_files{k});
                new_fldpath=fileparts(new_fpath);
                if ~exist(new_fldpath,'dir')
                    mkdir(new_fldpath);
                end
                movefile(b_files{k},new_fpath,'f');
                fprintf('%s, moved to : %s \n',b_files{k},new_fpath);
            end
            fprintf('finished moving\n');
        end
    end
end

