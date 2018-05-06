function plot_vertical_line(scvpoint, varargin)
%script to generate vertical line
%specify <scvpoint> and <scvcolor> optionally (if you want change the default red color)
%scvpoint=30; %your point goes here 
if length(varargin)>0
	scvcolor = varargin{1};
else
    scvcolor = [1 0 0];
end
if length(varargin)>1
	ylimits = varargin{2};
else
	ylimits = ylim;
end

line([scvpoint scvpoint],ylim,'Color',scvcolor);
%hold on;
%plot([scvpoint scvpoint], ylim,'r-')
%hold off
