function gca_noborders1(hAxes)

    if ~exist('hAxes','var')
        hAxes=gca;
    end
    
    
if false
    ti = get(hAxes,'TightInset');
    set(hAxes,'Position',[ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);


    set(hAxes,'units','centimeters')
    pos = get(hAxes,'Position');
    ti = get(hAxes,'TightInset');

    set(gcf, 'PaperUnits','centimeters');
    set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
    
else
    set(hAxes,'LooseInset',get(hAxes,'TightInset'));
end