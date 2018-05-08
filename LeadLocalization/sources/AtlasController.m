function AtlasController(AtlasInfo, AtlasPatch)

handles.gui = largeFigure(0, [200 700]); clf(handles.gui);
set(handles.gui, 'Name', 'Atlas Controller', 'Units', 'Normalized', 'PaperPositionMode', 'Auto');

if isfield(AtlasInfo,'Left')
    ButtonHeight = 0.9 / length(AtlasInfo.Left);
    for n = 1:length(AtlasInfo.Left)
        handles.AtlasControl.Left(n) = uicontrol(handles.gui, 'Style','PushButton','String','',...
            'Units','Normalized','Position',[0.1 0.95-ButtonHeight*n 0.1 ButtonHeight*0.7],...
            'Callback',{@SelectColor, 'Left', n}, 'BackGroundColor', AtlasInfo.LeftCMAP(n,:));
        handles.AtlasCheck.Left(n) = uicontrol(handles.gui, 'Style','Checkbox','String','',...
            'Units','Normalized','Position',[0.22 0.95-ButtonHeight*n 0.08 ButtonHeight*0.7],...
            'Callback',{@CheckAtlas, 'Left', n}, 'Value', 1);
        handles.AtlasLabel.Left(n) = uicontrol(handles.gui, 'Style','text','String',AtlasInfo.Left(n).name(1:end-4),...
            'Units','Normalized','Position',[0.32 0.94-ButtonHeight*n 0.25 ButtonHeight*0.7],...
            'FontName', 'Ubuntu Mono', 'FontSize', 15, 'HorizontalAlignment', 'Left');
    end
end

if isfield(AtlasInfo,'Right')
    ButtonHeight = 0.9 / length(AtlasInfo.Right);
    for n = 1:length(AtlasInfo.Right)
        handles.AtlasControl.Right(n) = uicontrol(handles.gui, 'Style','PushButton','String','',...
            'Units','Normalized','Position',[0.6 0.95-ButtonHeight*n 0.1 ButtonHeight*0.7],...
            'Callback',{@SelectColor, 'Right', n}, 'BackGroundColor', AtlasInfo.RightCMAP(n,:));
        handles.AtlasCheck.Right(n) = uicontrol(handles.gui, 'Style','Checkbox','String','',...
            'Units','Normalized','Position',[0.72 0.95-ButtonHeight*n 0.08 ButtonHeight*0.7],...
            'Callback',{@CheckAtlas, 'Right', n}, 'Value', 1);
        handles.AtlasLabel.Right(n) = uicontrol(handles.gui, 'Style','text','String',AtlasInfo.Right(n).name(1:end-4),...
            'Units','Normalized','Position',[0.78 0.94-ButtonHeight*n 0.15 ButtonHeight*0.7],...
            'FontName', 'Ubuntu Mono', 'FontSize', 15, 'HorizontalAlignment', 'Left');
    end
end

handles.AtlasInfo = AtlasInfo;
handles.AtlasPatch = AtlasPatch;
guidata(handles.gui, handles);

function SelectColor(hObject, eventdata, side, atlasIndex)
h = figure(); clf;
lambda = 400:700;
sRGB = repmat(spectrumRGB(lambda),[150 1 1]);
for n = 1:size(sRGB,1)
    sRGB(n,:,:) = sRGB(n,:,:)*n/size(sRGB,1);
end
imshow(sRGB);
[x,y] = ginput(1);
delete(h);
color = squeeze(sRGB(round(y),round(x),:));

handles = guidata(hObject);
switch side
    case 'Left'
        set(handles.AtlasControl.Left(atlasIndex), 'BackgroundColor', color);
        set(handles.AtlasPatch.Left(atlasIndex), 'FaceColor', color);
    case 'Right'
        set(handles.AtlasControl.Right(atlasIndex), 'BackgroundColor', color);
        set(handles.AtlasPatch.Right(atlasIndex), 'FaceColor', color);
end
guidata(handles.gui, handles);

function CheckAtlas(hObject, eventdata, side, atlasIndex)
handles = guidata(hObject);
switch side
    case 'Left'
        if hObject.Value == 0
            handles.AtlasPatch.Left(atlasIndex).Visible = 'off';
        else
            handles.AtlasPatch.Left(atlasIndex).Visible = 'on';
        end
    case 'Right'
        if hObject.Value == 0
            handles.AtlasPatch.Right(atlasIndex).Visible = 'off';
        else
            handles.AtlasPatch.Right(atlasIndex).Visible = 'on';
        end
end
guidata(handles.gui, handles);