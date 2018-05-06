function gcf_noborders2(hFig)

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

    % generate all coordinates of corners of graphs and store them in
    % bounds as [lower-left-x lower-left-y upper-right-x upper-right-y] in
    % the same unit system as paper (centimeters here)
    for i=1:nfigs
        %gca_noborders1(a(i))
        if strcmp(a(i).Type,'colorbar') || strcmp(a(i).Tag,'legend') || strcmp(a(i).Tag,'suptitle')
            continue
        end
        set(a(i),'LooseInset',get(a(i),'TightInset'));
    end

    % compute the rectangular convex hull of all plots and store that info
    % in mypos as [lower-left-x lower-left-y width height] in centimeters
   
    % ensure that paper position mode is in manual in order for the
    % printer driver to honor the figure properties
    %set(hFig,'PaperPositionMode', 'manual');
    set(hFig,'PaperPositionMode','auto');

    % use the PaperPosition four-element vector [left, bottom, width, height]
    % to control the location on printed page; place it using horizontal and
    % vertical negative offsets equal to the lower-left coordinates of the
    % rectangular convex hull of the plot, and increase the size of the figure
    % accordingly

end