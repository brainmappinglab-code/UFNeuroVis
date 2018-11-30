function [iPoint,iPass] = get_point_coord(aH)
%{
GET_POINT_COORD
    Identifies point closest to stabbing vector, perpendicularly.
    Then searches the ApmDataTable for a matching entry.
    Finally, plots an 'X' over the matching point, and returns the
    rox- and depth-indices
ARGS
    aH: handle of axes to plot 3D trajectory on
RETURNS
    None
%}
    % minimum distance the stabbing vector must pass perpendicular to the point
    DISTANCE_THRESHOLD = 0.5;
    
    % get GUI handle
    f = ancestor(aH,'figure');
    
    % get coordinates of plotted 'X'
    ptH = getappdata(aH,'CurrentSelection');
    
    % get list of plotted data points along trajectory
    lH = findobj(aH,'Type','line');
    
    % get display style drop-down menu handle
    display_style = findobj(f,'Tag','display_style');
    
    % get click coordinates
    pt = get(aH,'CurrentPoint');
    
    % uncomment this to plot a cool red stabbing vector
%     plot3(aH,pt(:,1),pt(:,2),pt(:,3),'-r')
    
    lPts = [lH.XData;lH.YData;lH.ZData]';
    v1 = pt(1,:);
    v2 = pt(2,:);
    v1 = repmat(v1,size(lPts,1),1);
    v2 = repmat(v2,size(lPts,1),1);    
    a = v1 - v2;
    b = lPts - v2;
    d = sqrt(sum(cross(a,b,2).^2,2)) ./ sqrt(sum(a.^2,2));
    [m,iClose] = min(d);
    
    % if a match is found,
    if m < DISTANCE_THRESHOLD
        x = lPts(iClose,1);
        y = lPts(iClose,2);
        z = lPts(iClose,3);
        delete(ptH);    % delete previous 'X'
        axes(aH);
        ptH = plot3(aH,x,y,z,'rx'); %plot new 'X'
        setappdata(aH,'CurrentSelection',ptH); % update GUI data
        set(gca,'Tag','traj_axes');
        
        daH = findobj(f,'Tag','disp_axes');
        axes(daH);      
        ApmDataTable = getappdata(f,'ApmDataTable');
        
        % TODO make this search faster?
        % search for matching ApmDataTable entry
        flag = 0;
        for iPass = 1:size(ApmDataTable,2)
            for iPoint = 1:size(ApmDataTable{iPass},1)
                if (...
                        ~isempty(ApmDataTable{iPass}.x(iPoint)) ...
                        && x == ApmDataTable{iPass}.x(iPoint) ...
                        && y == ApmDataTable{iPass}.y(iPoint) ...
                        && z == ApmDataTable{iPass}.z(iPoint) ...
                    )
                
                    flag = 1;
                    
                    % set path to match APM file as GUI data
                    setappdata(aH,'PassPoint',[iPass iPoint]);
                    
                    % get choice of style to display APM channel data as
                    style = get(display_style,'Value');
                    
                    plot_section_data(daH,ApmDataTable,style,iPass,iPoint);   
                    xlabel(daH,'Seconds');
                                    
                    break
                end
            end
            if flag
                break
            end
        end
    else
        % if no suitable match is found,
        iPoint = 0;
        iPass = 0;
    end
end