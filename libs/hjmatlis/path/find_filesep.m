function pos_trail=find_filesep(str)
% pos_trail=find_filesep(str)
% find fileseparators (in both unix and windows convention

    s1=strfind(str,'\');
    if ~isempty(s1)
        s1=s1(1);
    end
    s2=strfind(str,'/');
    if ~isempty(s2)
        s2=s2(1);
    end
    pos_trail=sort([s1 s2]);
    
end
