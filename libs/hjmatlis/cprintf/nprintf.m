function count = nprintf(formatString, varargin)
    %nprintf(formatString, vars[,'nmod-STYLE', style])
    %   printf variant to wrap the unsupported cprintf and normal fprintf
    %   if style not specified, it prints with fprintf (and with it's
    %   output rules)
    %   if keyword 'nmod-STYLE' is specified it uses the style specified
    %   for the wrapped cprintf
	count = -1;
	arrVar = varargin;
    if(length(arrVar)>0)
        
        if(strmatch(arrVar{end-1},'nmod-STYLE'))
            style = arrVar{end};

            if(length(arrVar)>2)
                arrVar = arrVar(1:end-2);
            end
        end
    else
        arrVar = {};
    end
    	
    
	try
		count = cprintf(style, formatString, arrVar{:});
	catch ME
		count = fprintf(formatString, arrVar{:});
	end
