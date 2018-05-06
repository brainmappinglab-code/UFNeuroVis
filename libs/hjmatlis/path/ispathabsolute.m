function [is_path_absolute] = ispathabsolute(str_path)
%ispathabsolute(str_path) check if path is absolute or not (does not check for existance)
%   works for both win and unix convention
%   return true when path starts with / or \ or c:/ or c:\

    if regexp(str_path,'^([A-Za-z]:)?(\\|\/)')==1
        is_path_absolute=true;
    else
        is_path_absolute=false;
    end
    
end