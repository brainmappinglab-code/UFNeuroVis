function [edge,splitdata,lastbin] = EdgeCalculator(bin,start,stop,varargin)
%-------function [edge,splitdata,lastbin] = EdgeCalculator(bin,start,stop,varargin)------------
%
% Calculate edge times/samples given a user-defined bin width and start/stop range.
% This is useful for things such as PSTHs, histograms, sliding averages,
% permuation entropy, etc. etc.
%
%               >>> INPUTS >>>
%   Required:
%       bin = bin width (in samples)
%       start = starting time (samples)
%       stop = ending time (samples)
%   Optional:
%       Fs = sampling rate...useful for converting edge samples to time
%       (put 0 as place holder if you want samples)
%       data = data array (not matrix) to be split into segments
%
%               <<< OUTPUTS <<<
%   edge = edge times (in samples, seconds, or ms)
%   splitdata = *optional* if input data array as optional argument, 
%                      will split into segments of equal-sized/spaced data
%   lastbin =  if length(data) < stop, will find the next index
%                   from "edge" that can be used to parse the data (i.e. up
%                   to bin X).
%
%   By JMS, 08/14/2015
%------------------------------------------------------------------------------------------

% varargin checking
if nargin > 3; Fs = varargin{1};
else Fs = 0; end
if nargin > 4; data = varargin{2};
else data = 0; end

% error checking
if isempty(Fs); Fs=0;end
if isempty(data); clear data; end

% calculate edges
edge = start:bin:stop-1; % leading edges of bins

% if data array is given
if max(data)>0
    if length(data)-(edge(end)-1) < bin % if length of data is less than 1 bin more than final starting bin
        lastbin = max(find(length(data)-(edge-1) >= bin));
    else
        lastbin = length(edge);
    end

    % split the data using the bins
    splitdata = zeros(floor(bin),floor(lastbin)); % prealocate
    start_edge = edge(1:lastbin);
    end_edge = start_edge+bin-1; % add bin amount after subtracting first point
    for i = 1:lastbin
        splitdata(:,i) = data(floor(start_edge(i)):floor(end_edge(i))); % extract data
    end
end

if Fs 
    edge = edge./Fs;
end

end
    
    
    


