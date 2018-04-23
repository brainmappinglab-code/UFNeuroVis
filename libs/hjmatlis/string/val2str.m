function [val1] = val2str(val1)
%[str_val] = val2str(val1)
%convert  value to string (useful to parse some outputs in one liner code)

if iscell(val1)
    val1=val1{1};
end

if ~ischar(val1)
    if isnumeric(val1)
        val1=num2str(val1);
    elseif islogical(val1)
        if val1==true
            val1='true';
        else
            val1='false';
        end
    end
end

