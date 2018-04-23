function shift_axes(ax_selected1,shift_vector)
%SUPTITLE puts a title above all subplots.
%hout=suptitle2(str,ax_selected1 [,title_up_shift])
%
%	SUPTITLE('text') adds text to the top of the figure
%	above all subplots (a "super title"). Use this function
%	after all subplot commands.
%

%   Copyright 2003-2014 The MathWorks, Inc.
%   modified by Enrico Opri 2017


% Warning: If the figure or axis units are non-default, this
% function will temporarily change the units.

% Parameters used to position the supertitle.

% Amount of the figure window devoted to subplots
plotregion = .92;

% Y position of title in normalized coordinates
titleypos  = .95;

% Fontsize for supertitle
fs = get(gcf,'defaultaxesfontsize')+4;

% Fudge factor to adjust y spacing between subplots
fudge=1;

haold = gca;
figunits = get(gcf,'units');

% Get the (approximate) difference between full height (plot + title
% + xlabel) and bounding rectangle.

if ~strcmp(figunits,'pixels')
    set(gcf,'units','pixels');
    pos = get(gcf,'position');
    set(gcf,'units',figunits);
else
    pos = get(gcf,'position');
end
ff = (fs-4)*1.27*5/pos(4)*fudge;

% The 5 here reflects about 3 characters of height below
% an axis and 2 above. 1.27 is pixels per point.

% Determine the bounding rectangle for all the plots

%h = findobj(gcf,'Type','axes');

oldUnits = get(ax_selected1, {'Units'});
if ~all(strcmp(oldUnits, 'normalized'))
    % This code is based on normalized units, so we need to temporarily
    % change the axes to normalized units.
    set(ax_selected1, 'Units', 'normalized');
    cleanup = onCleanup(@()resetUnits(ax_selected1, oldUnits));
end

max_y=0;
min_y=1;
oldtitle = [];
numAxes = length(ax_selected1);
thePositions = zeros(numAxes,4);
for i=1:numAxes
    pos=get(ax_selected1(i),'pos');
    thePositions(i,:) = pos;
    if ~strcmp(get(ax_selected1(i),'Tag'),'suptitle')
        if pos(2) < min_y
            min_y=pos(2)-ff/5*3;
        end
        if pos(4)+pos(2) > max_y
            max_y=pos(4)+pos(2)+ff/5*2;
        end
    else
        oldtitle = ax_selected1(i);
    end
end

if max_y > plotregion
    scale = (plotregion-min_y)/(max_y-min_y);
    for i=1:numAxes
        pos = thePositions(i,:);
        pos(2) = (pos(2)-min_y)*scale+min_y;
        pos(4) = pos(4)*scale-(1-scale)*ff/5*3;
        set(ax_selected1(i),'position',pos);
    end
end


for i=1:numAxes
    pos = thePositions(i,:);
    pos(1:2) = pos(1:2) + shift_vector;
    set(ax_selected1(i),'position',pos);
end


end

function resetUnits(h, oldUnits)
    % Reset units on axes object. Note that one of these objects could have
    % been an old supertitle that has since been deleted.
    valid = isgraphics(h);
    set(h(valid), {'Units'}, oldUnits(valid));
end