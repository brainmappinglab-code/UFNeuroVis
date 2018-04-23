function [out_list] = dir_rf(varargin)
%DIR_R recursive dir
%   list all the files (if a folder matches, list all the files inside, do not list folders)

%requires hstrcmp.m

if nargin>0
    fpath_search=varargin{1};
    a=dir(fpath_search);
else
    out_list=dir;
    return
end

search_not_empty=false;

[search_base_path,search_name,search_ext]=fileparts(fpath_search);
new_fsearch=[search_name search_ext];

if isempty(a)
    out_list=a;
else
    b={a.name};
    s=hstrcmp(b,{'.','..'},'matchfirst');%discard the . and  .. folders
    a(s)=[];
    b(s)=[];
    s=[a.isdir];
    a_files=a(~s);
    b_files=b(~s);
    b_fld=b(s);
    
    for k=1:length(a_files)
        a_files(k).name=fullfile(search_base_path,b_files{k});
    end
    
    c_files=[];
    for k=1:length(b_fld)
        c_files=[c_files;dir_rf(fullfile(search_base_path,b_fld{k},'*'))];%get all the files inside all the sufolders
    end
    
    out_list=[a_files;c_files];
    search_not_empty=true;
end

%if the search string starts with * search also in subfolders
%get new basepath for the next search
if new_fsearch(1)=='*'
    %get complete list of folders
    a_all=dir(fullfile(search_base_path,'*'));
    %get folders only
    b_fld_all={a_all([a_all.isdir]).name};
    b_fld_all=b_fld_all(~hstrcmp(b_fld_all,{'.','..'},'matchfirst'));%discard the . and  .. folders
    
    if search_not_empty
        b_fld_all(hstrcmp(b_fld_all,b_fld,'matchfirst'))=[];
    end

    %search recursively in b_fld_all
    for k=1:length(b_fld_all)
        sub_a=dir_rf(fullfile(search_base_path,b_fld_all{k},new_fsearch));
        if ~isempty(sub_a);
            out_list=[out_list;sub_a];
        end
    end
end