function [out_list] = dir_ra(varargin)
%DIR_R recursive dir
%   list all files and folders files (if a folder matches, list all the files and folders inside)

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

    b_fld=b([a.isdir]);
    
    for k=1:length(a)
        a(k).name=fullfile(search_base_path,b{k});
    end
    
    c_all=[];
    for k=1:length(b_fld)
        c_all=[c_all;dir_ra(fullfile(search_base_path,b_fld{k},'*'))];%get all the files inside all the sufolders
    end
    
    out_list=[a;c_all];
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
        sub_a=dir_ra(fullfile(search_base_path,b_fld_all{k},new_fsearch));
        if ~isempty(sub_a);
            out_list=[out_list;sub_a];
        end
    end
end