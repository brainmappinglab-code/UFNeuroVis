function out = hstrcmp(arg0, arg1, varargin)
	%out = hstrcmp(arg0, arg1[, options])
	%it's behaviour is like strcmp when no option is specified
	%for example if the option specified is 'mix', it returns a matrix of bool
	%representing when there is a match
    %OPTIONS
    %   'mix'
    %   'mix'   
    %   'matchfirst'
    %   'matchsecond'

    %fix input
    if size(arg0,2)==1
        arg0=arg0';
    end
    if size(arg1,2)==1
        arg1=arg1';
    end
    
	if length(varargin)<1
		out = strcmp(arg0, arg1);
	else
		if strcmp(varargin{1}, 'mix')
			matr = [];
			for i=1:length(arg1)
				matr = [matr; strcmp(arg0, arg1{i})];
			end
			out = matr';
		elseif strcmp(varargin{1}, 'mixall')
			matr = [];
			for i=1:length(arg1)
				matr = [matr; strcmp(arg0, arg1{i})];
			end
			out = sum(sum(matr)) > 0;
		elseif strcmp(varargin{1}, 'matchfirst')
			matr = [];
			for i=1:length(arg1)
				matr = [matr; strcmp(arg0, arg1{i})];
			end
			out = sum(matr',2) > 0;
		elseif strcmp(varargin{1}, 'matchsecond')
			matr = [];
			for i=1:length(arg1)
				matr = [matr; strcmp(arg0, arg1{i})];
			end
			out = sum(matr,2) > 0;
		else
			
			error('option not recognised');
		end
	end