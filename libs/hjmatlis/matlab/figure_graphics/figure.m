function vargout=figure(varargin)
    %overload for improved figure.
    %for now it addes a menu entry for exporting figures automatically in fig
    %and png

    init_figure=true;
    if nargin>0
        if isequal(ishandle(varargin{1}),true)
            %if figure exist already, do not reinitialize the extras (otherwise it
            %would be messy
            init_figure=false;
        end

        if isa(varargin{1},'matlab.ui.Figure') && isequal(ishandle(varargin{1}),false)
            %figure was deleted, reinitialize (remove the deleted handle)
            varargin(1)=[];
        end
    end

    if nargout>0
        vargout=builtin('figure',varargin{:});
    else
        builtin('figure',varargin{:});
    end


    if init_figure
        %get figure handler
        hFig=gcf;
        is_toolbar=false;
        try
            %get the current menubar
            %of course if there is no menubar, it will fail
            hToolbar = findall(hFig,'tag','FigureToolBar');
            is_toolbar=true;
        catch
        end
        if is_toolbar
            %add zoom tools
            try
                icon1 = fullfile('hjanalyze/dev/lib/hjmatlis/matlab/figure_graphics/bitmaps/tool_zoom_in_horizontal.png');
                [cdata,map,alpha] = imread(icon1);
                cdata=double(cdata)/65535;
                % Convert white pixels into a transparent background
                cdata(alpha<65500) = NaN;
                %add to existent toolbar
                hZoomOption1 = uipushtool(hToolbar,'cdata',cdata, 'tooltip','Zoom Horizontally', 'ClickedCallback',@zoomOptionToHorizontal);

                %this part is not needed for now
                    %since the standard figure toolbar was generated before the custom button
                    %(added by uipushtool), it will be concatenated at the end.
                    %Therefore we need to rearrange the toolbar additions
                    %hToolbar = findall(hFig,'tag','FigureToolBar');
                    %hButtons = findall(hToolbar);
                    %set(hToolbar,'children',hButtons([2:3,end,4:(end-1)]));
                set(hZoomOption1,'Separator','on');


                icon1 = fullfile('hjanalyze/dev/lib/hjmatlis/matlab/figure_graphics/bitmaps/tool_zoom_in_vertical.png');
                [cdata,map,alpha] = imread(icon1);
                cdata=double(cdata)/65535;
                % Convert white pixels into a transparent background
                cdata(alpha<65500) = NaN;
                %add to existent toolbar
                hZoomOption2 = uipushtool(hToolbar,'cdata',cdata, 'tooltip','Zoom Vertically', 'ClickedCallback',@zoomOptionToVertical);


                icon1 = fullfile('hjanalyze/dev/lib/hjmatlis/matlab/figure_graphics/bitmaps/tool_zoom_in_both.png');
                [cdata,map,alpha] = imread(icon1);
                cdata=double(cdata)/65535;
                % Convert white pixels into a transparent background
                cdata(alpha<65500) = NaN;
                %add to existent toolbar
                hZoomOption3 = uipushtool(hToolbar,'cdata',cdata, 'tooltip','Zoom in Both directions', 'ClickedCallback',@zoomOptionToBoth);
            catch
            end

            %add plotting tools
            try
                icon1 = fullfile('hjanalyze/dev/lib/hjmatlis/matlab/figure_graphics/bitmaps/paintbrush_gray.gif');
                [cdata,map] = imread(icon1);
                % Convert white pixels into a transparent background
                map(map(:,1)+map(:,2)+map(:,3)==3) = NaN;
                % Convert into 3D RGB-space
                cdataExportPlots = ind2rgb(cdata,map);
                %add to existent toolbar
                hExportPlots1 = uipushtool(hToolbar,'cdata',cdataExportPlots, 'tooltip','Export Plots (no EPS)', 'ClickedCallback','hjsnap_std1()');

                %this part is not needed for now
                    %since the standard figure toolbar was generated before the custom button
                    %(added by uipushtool), it will be concatenated at the end.
                    %Therefore we need to rearrange the toolbar additions
                    %hToolbar = findall(hFig,'tag','FigureToolBar');
                    %hButtons = findall(hToolbar);
                    %set(hToolbar,'children',hButtons([2:3,end,4:(end-1)]));
                set(hExportPlots1,'Separator','on');


                icon1 = fullfile(matlabroot,'/toolbox/matlab/icons/paintbrush.gif');
                [cdata,map] = imread(icon1);
                % Convert white pixels into a transparent background
                map(map(:,1)+map(:,2)+map(:,3)==3) = NaN;
                % Convert into 3D RGB-space
                cdataExportPlots = ind2rgb(cdata,map);
                %add to existent toolbar
                hExportPlots2 = uipushtool(hToolbar,'cdata',cdataExportPlots, 'tooltip','Export Plots (with EPS)', 'ClickedCallback','hjsnap_std_with_eps1()');
            catch
            end
        end

    end

    %methods for zoom options
    function zoomOptionToHorizontal(hObject, eventdata, handles)
        try
            %get zoom handle
            z1=zoom;
            z1.Motion='horizontal';
        catch
        end
    end
    function zoomOptionToVertical(hObject, eventdata, handles)
        try
            %get zoom handle
            z1=zoom;
            z1.Motion='vertical';
        catch
        end
    end
    function zoomOptionToBoth(hObject, eventdata, handles)
        try
            %get zoom handle
            z1=zoom;
            z1.Motion='both';
        catch
        end
    end
end
%hToolbar = findall(gcf,'tag','FigureToolBar');
%hPrintButton = findall(hToolbar,'tag','Standard.PrintFigure');
%set(hPrintButton, 'ClickedCallback','printpreview(gcbf)', 'TooltipString','Print Preview');