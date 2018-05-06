function lsout=lsumt_rf(varargin)
    %lsout=lsumt([fpath[, 'legacy']])
    %LS uniform matlab version (similar to the one implemented in windows,
    %but outputs a cell array of strings)
    %wrapper to get an ls like method that shows consistency between platforms (windows matching)
    %if the legacy option is specified it will output exatly like ls method on windows
    %
    %NOTES: it is a wrapper for dir_rf

    islegacy=false;
    if nargin>0
        a=dir(varargin{1});
    else
        a=dir;
    end
    if nargin>1
        if strcmp(varargin{2},'legacy')
            islegacy=true;
        else
            error('option not recognized');
        end
    elseif nargin>2
        error('too many arguments');
    end
    
    if islegacy==false
        %more consistency in the output (output as cellarray)
        if isempty(a)
            lsout={};
        else
            lsout={a.name}';
        end
    else
        %legacy support
        if isempty(a)
            lsout='';
        else
            if length(a)==1
                lsout=a.name;
            else
                lsout={a.name}';
            end
        end
    end
end