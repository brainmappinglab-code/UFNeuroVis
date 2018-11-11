function mer_plot_callback(aH,event)
%{
MER_PLOT_CALLABCK
    Updates the disp_axes with the APM channel data of the closest point
    to the user's click.
ARGS
    aH: handle of axes to plot 3D trajectory on
RETURNS
    None
%}

    % this will return the row-index and pass-index of the closest match
    [iPoint,iPass] = get_point_coord(aH);

    % if a match is found,
    if iPoint ~= 0 && iPass ~= 0
        match = dbs_match(aH,iPoint,iPass);
        if match ~= 0
            display_match(aH,match,iPass);
        end
    end    

end

