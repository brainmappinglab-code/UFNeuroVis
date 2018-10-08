function [ handler ] = largeFigure( x, Size, varargin )
%largeFigure is a aliased version of figure function with pre-determined
%windows size.
%
%   h = largeFigure( x, size );
%
% J. Cagle, University of Florida, 2013

if x > 0
    handler = figure(x);
else
    handler = figure();
end

if ~isempty(varargin)
    p = get(0,'MonitorPositions');
    if varargin{1} > size(p,1)
        warning('A monitor of nonexistance is chosen, select default monitor');
        monitorP = p(1,1:2);
        monitorPSize = p(1,3:4);
    else
        monitorP = p(varargin{1},1:2);
        monitorPSize = p(varargin{1},3:4);
    end
    set(handler, 'Units', 'pixels');
    set(handler,'Position',[monitorP+((monitorPSize-Size)/2) Size], 'Units', 'pixels');
    set(handler,'PaperPositionMode','auto');
else
    p = get(0,'MonitorPositions');
    monitorP = p(1,1:2);
    monitorPSize = p(1,3:4);
    set(handler, 'Units', 'pixels');
    set(handler,'Position',[monitorP+((monitorPSize-Size)/2) Size]);
    set(handler,'PaperPositionMode','auto');
end
end
