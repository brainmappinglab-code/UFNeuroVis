function gcf_noborders1(hFig)

    if ~exist('hFig','var')
        hFig=gcf;
    end
    
    unit_type='centimeters';
    
    set(hFig,'Units',unit_type)
    %unit_type='points';
    % first use the same non-relative unit system for paper and screen (see
    % below)
    set(hFig,'PaperUnits',unit_type);

    % now get all existing plots/subplots
    a=get(hFig,'Children');
    nfigs=length(a);

    % bounds will contain lower-left and upper-right corners of plots plus one
    % line to make sure single plots work
    bounds=zeros(nfigs+1,4);
    bounds(end,1:2)=inf;
    bounds(end,3:4)=-inf;

    % generate all coordinates of corners of graphs and store them in
    % bounds as [lower-left-x lower-left-y upper-right-x upper-right-y] in
    % the same unit system as paper (centimeters here)
    for i=1:nfigs
        set(a(i),'Unit',unit_type);
        
        if strcmp(a(i).Tag,'suptitle')
            bounds(i,1:2)=inf;
            bounds(i,3:4)=-inf;
            continue;
        end
        set(gca,'LooseInset',get(gca,'TightInset'));
        
        pos=get(a(i),'Position');
        inset=get(a(i),'TightInset');
        bounds(i,:)=[pos(1)-inset(1) pos(2)-inset(2) ...
            pos(1)+pos(3)+inset(3) pos(2)+pos(4)+inset(4)];
    end

    % compute the rectangular convex hull of all plots and store that info
    % in mypos as [lower-left-x lower-left-y width height] in centimeters
    auxmin=min(bounds(:,1:2));
    auxmax=max(bounds(:,3:4));
    mypos=[auxmin auxmax-auxmin];

    % set the paper to the exact size of the on-screen figure using
    % figure property PaperSize [width height]
    set(hFig,'PaperSize',[mypos(3) mypos(4)]);

    % ensure that paper position mode is in manual in order for the
    % printer driver to honor the figure properties
    %set(hFig,'PaperPositionMode', 'manual');
    set(hFig,'PaperPositionMode','auto');

    % use the PaperPosition four-element vector [left, bottom, width, height]
    % to control the location on printed page; place it using horizontal and
    % vertical negative offsets equal to the lower-left coordinates of the
    % rectangular convex hull of the plot, and increase the size of the figure
    % accordingly
    set(hFig,'PaperPosition',[-mypos(1) -mypos(2) ...
    mypos(3)+mypos(1) mypos(4)+mypos(2)]);

end