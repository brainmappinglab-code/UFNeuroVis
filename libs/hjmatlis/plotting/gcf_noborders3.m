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
    adjust_width=zeros(nfigs,1);
    for k1=1:nfigs
        %check all the colorbars
        if strcmp(a(k1).Type,'colorbar')
            %find the matching plot
            for k2=1:nfigs
                if k1==k2
                    continue
                end
                
                if abs(a(k1).Position(2)-a(k2).Position(2))<0.01;
                    adjust_width(k2)=0.01;
                    adjust_width(k2)=a(k1).Position(3)*a(k2).Position(3);
                    break;
                end
            end
        end
    end
    
    for i=1:nfigs
        %gca_noborders1(a(i))
        if strcmp(a(i).Tag,'legend') || strcmp(a(i).Tag,'suptitle') || strcmp(a(i).Type,'colorbar')
            continue;
        end
        ax = a(i);
        outerpos = ax.OuterPosition;
        ti = ax.TightInset; 
        left = outerpos(1) + ti(1);
        bottom = outerpos(2) + ti(2);
        ax_width = outerpos(3) - ti(1) - ti(3)-adjust_width(i);
        ax_height = outerpos(4) - ti(2) - ti(4);
        ax.Position = [left bottom ax_width ax_height];
    end

    % compute the rectangular convex hull of all plots and store that info
    % in mypos as [lower-left-x lower-left-y width height] in centimeters
   
    % ensure that paper position mode is in manual in order for the
    % printer driver to honor the figure properties
    %set(hFig,'PaperPositionMode', 'manual');
    set(hFig,'PaperPositionMode','auto');
    
    %hFig = gcf;
    hFig.PaperPositionMode = 'auto';
    fig_pos = hFig.PaperPosition;
    hFig.PaperSize = [fig_pos(3) fig_pos(4)];

    % use the PaperPosition four-element vector [left, bottom, width, height]
    % to control the location on printed page; place it using horizontal and
    % vertical negative offsets equal to the lower-left coordinates of the
    % rectangular convex hull of the plot, and increase the size of the figure
    % accordingly

end