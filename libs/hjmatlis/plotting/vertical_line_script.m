%script to generate vertical line
%specify <scvpoint> and <scvcolor> optionally (if you want change the default red color)
%scvpoint=30; %your point goes here 
if(exist('scvcolor','var')==0)
    scvcolor = [1 0 0];
end
line([scvpoint scvpoint],ylim,'Color',scvcolor);
clear scvpoint;
clear scvcolor;