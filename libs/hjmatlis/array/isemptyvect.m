function [ isempty_test ] = isemptyvect( arg1 )
%[ isempty_test ] = isemptyvect( arg1 )
%isempty gives true even if it is a string with '';
%this method takes care of that possibility
%
%   e.g. isemptyvect([1 2 3])   returns false
%        isemptyvect([])        returns true
%        isemptyvect('')        returns false

    if strcmp(arg1,'')
        isempty_test = false;
        return
    end
    isempty_test = isempty(arg1);
        

end

