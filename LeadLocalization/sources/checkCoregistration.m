function checkCoregistration( referenceImage, registeredImage)
%checkCoregistration will display visualization for user to determine
%whether the coregistration is acceptable or not.
%   J. Cagle, 2018

handles.gui = largeFigure(0, [1280 900]); clf;
handles.sliceView = axes; hold(handles.sliceView, 'on');
set(handles.sliceView, 'Position', [0 0 1 1]);
set(handles.sliceView, 'DataAspectRatio',[1 1 1]);
axis(handles.sliceView, 'off');
set(handles.gui, 'Color', 'k');

handles.viewDimension = 3;
handles.reference = referenceImage;
handles.reference.sliceIndex = round(handles.reference.dimension/2);
handles.reference.maxIntensity = prctile(prctile(prctile(handles.reference.img, 95), 95), 95);
handles.coRegistered = registeredImage;
handles.coRegistered.sliceIndex = round(handles.coRegistered.dimension/2);
handles.coRegistered.maxIntensity = prctile(prctile(prctile(handles.coRegistered.img, 95), 95), 95);
handles.colormapResolution = 2048;
handles.customColormap = [gray(handles.colormapResolution);jet(handles.colormapResolution)];
colormap(handles.sliceView, handles.customColormap);

handles.overlay = false;
handles.slice = [];

% Normalize MRI Image
handles.reference.img = (handles.reference.img - handles.reference.intensityRange(1)) / diff(handles.reference.intensityRange);
handles.coRegistered.img = (handles.coRegistered.img - handles.coRegistered.intensityRange(1)) / diff(handles.coRegistered.intensityRange);

% Tonemapping CT
handles.overlayImage = tonemapCT(registeredImage.img);

set(handles.gui, 'KeyPressFcn', @keyboardEvent);
set(handles.gui, 'WindowScrollWheelFcn', @scrollSlice);
handles.viewControl.Sagittal = uicontrol('Style', 'pushbutton', 'String', 'S', 'Position', [100 50 25 25], 'Callback', {@changeView, 'S'});
handles.viewControl.Coronal = uicontrol('Style', 'pushbutton', 'String', 'C', 'Position', [160 50 25 25], 'Callback', {@changeView, 'C'});
handles.viewControl.Axial = uicontrol('Style', 'pushbutton', 'String', 'A', 'Position', [220 50 25 25], 'Callback', {@changeView, 'A'});

viewSlice(handles)

function viewSlice(handles)
switch handles.viewDimension
    case 1
        referenceSlice = squeeze(handles.reference.img(handles.reference.sliceIndex(1),:,:))';
        handles.referenceImage = image(handles.sliceView, handles.reference.YRange, handles.reference.ZRange, referenceSlice * handles.colormapResolution);
        axis(handles.sliceView, [handles.reference.YRange([1 end]), handles.reference.ZRange([1 end])]);
        set(handles.sliceView, 'XDir', 'Normal');
    case 2
        referenceSlice = squeeze(handles.reference.img(:,handles.reference.sliceIndex(2),:))';
        handles.referenceImage = image(handles.sliceView, handles.reference.XRange, handles.reference.ZRange, referenceSlice * handles.colormapResolution);
        axis(handles.sliceView, [handles.reference.XRange([1 end]), handles.reference.ZRange([1 end])]);
        set(handles.sliceView, 'XDir', 'Reverse');
    case 3
        referenceSlice = squeeze(handles.reference.img(:,:,handles.reference.sliceIndex(3)))';
        handles.referenceImage = image(handles.sliceView, handles.reference.XRange, handles.reference.YRange, referenceSlice * handles.colormapResolution);
        axis(handles.sliceView, [handles.reference.XRange([1 end]), handles.reference.YRange([1 end])]);
        set(handles.sliceView, 'XDir', 'Reverse');
end

if ~handles.overlay
    switch handles.viewDimension
        case 1
            handles.registeredImage = image(handles.sliceView, handles.coRegistered.YRange, handles.coRegistered.ZRange, squeeze(handles.coRegistered.img(handles.coRegistered.sliceIndex(1),:,:))' * handles.colormapResolution + handles.colormapResolution);
            set(handles.registeredImage,'AlphaData',squeeze(handles.coRegistered.img(handles.coRegistered.sliceIndex(1),:,:))' * 0.8);
        case 2
            handles.registeredImage = image(handles.sliceView, handles.coRegistered.XRange, handles.coRegistered.ZRange, squeeze(handles.coRegistered.img(:,handles.coRegistered.sliceIndex(2),:))' * handles.colormapResolution + handles.colormapResolution);
            set(handles.registeredImage,'AlphaData',squeeze(handles.coRegistered.img(:,handles.coRegistered.sliceIndex(2),:))' * 0.8);
        case 3
            handles.registeredImage = image(handles.sliceView, handles.coRegistered.XRange, handles.coRegistered.YRange, squeeze(handles.coRegistered.img(:,:,handles.coRegistered.sliceIndex(3)))' * handles.colormapResolution + handles.colormapResolution);
            set(handles.registeredImage,'AlphaData',squeeze(handles.coRegistered.img(:,:,handles.coRegistered.sliceIndex(3)))' * 0.8);
    end
end
set(handles.gui, 'WindowButtonDownFcn', @startMotion);
guidata(handles.gui, handles);

function updateSlice(handles)
switch handles.viewDimension
    case 1
        handles.referenceImage.CData = squeeze(handles.reference.img(handles.reference.sliceIndex(1),:,:))' * handles.colormapResolution;
    case 2
        handles.referenceImage.CData = squeeze(handles.reference.img(:,handles.reference.sliceIndex(2),:))' * handles.colormapResolution;
    case 3
        handles.referenceImage.CData = squeeze(handles.reference.img(:,:,handles.reference.sliceIndex(3)))' * handles.colormapResolution;
end

if ~handles.overlay
    switch handles.viewDimension
        case 1
            handles.registeredImage.CData = squeeze(handles.coRegistered.img(handles.coRegistered.sliceIndex(1),:,:))' * handles.colormapResolution + handles.colormapResolution;
            handles.registeredImage.AlphaData = squeeze(handles.coRegistered.img(handles.coRegistered.sliceIndex(1),:,:))';
        case 2
            handles.registeredImage.CData = squeeze(handles.coRegistered.img(:,handles.coRegistered.sliceIndex(2),:))' * handles.colormapResolution + handles.colormapResolution;
            handles.registeredImage.AlphaData = squeeze(handles.coRegistered.img(:,handles.coRegistered.sliceIndex(2),:))';
        case 3
            handles.registeredImage.CData = squeeze(handles.coRegistered.img(:,:,handles.coRegistered.sliceIndex(3)))' * handles.colormapResolution + handles.colormapResolution;
            handles.registeredImage.AlphaData = squeeze(handles.coRegistered.img(:,:,handles.coRegistered.sliceIndex(3)))';
    end
end
guidata(handles.gui, handles);

function scrollSlice(hObject, eventdata)
handles = guidata(hObject);
diffSlice = eventdata.VerticalScrollCount * round(eventdata.VerticalScrollAmount / 2);
handles.reference.sliceIndex(handles.viewDimension) = min(max(1, handles.reference.sliceIndex(handles.viewDimension) + diffSlice), handles.reference.dimension(handles.viewDimension));
handles.coRegistered.sliceIndex(handles.viewDimension) = min(max(1, handles.coRegistered.sliceIndex(handles.viewDimension) + diffSlice), handles.coRegistered.dimension(handles.viewDimension));
updateSlice(handles)

function keyboardEvent(hObject, eventdata)
handles = guidata(hObject);
switch eventdata.Key
    case 'uparrow'
        diffSlice = 1;
        handles.reference.sliceIndex(handles.viewDimension) = min(max(1, handles.reference.sliceIndex(handles.viewDimension) + diffSlice), handles.reference.dimension(handles.viewDimension));
        handles.coRegistered.sliceIndex(handles.viewDimension) = min(max(1, handles.coRegistered.sliceIndex(handles.viewDimension) + diffSlice), handles.coRegistered.dimension(handles.viewDimension));
        updateSlice(handles)
    case 'downarrow'
        diffSlice = -1;
        handles.reference.sliceIndex(handles.viewDimension) = min(max(1, handles.reference.sliceIndex(handles.viewDimension) + diffSlice), handles.reference.dimension(handles.viewDimension));
        handles.coRegistered.sliceIndex(handles.viewDimension) = min(max(1, handles.coRegistered.sliceIndex(handles.viewDimension) + diffSlice), handles.coRegistered.dimension(handles.viewDimension));
        updateSlice(handles)
end
keyInterpreter(hObject, eventdata);

function changeView(hObject, eventdata, viewType)
handles = guidata(hObject);
switch viewType
    case 'S'
        handles.viewDimension = 1;
    case 'C'
        handles.viewDimension = 2;
    case 'A'
        handles.viewDimension = 3;
end
viewSlice(handles);

function startMotion(hObject, eventdata)
handles = guidata(hObject);
viewSnippet(handles);
set(handles.gui,'WindowButtonMotionFcn',@motionDetected);
set(handles.gui,'WindowButtonUpFcn',@stopMotion);

function motionDetected(hObject, eventdata)
handles = guidata(hObject);
updateSnippet(handles);

function stopMotion(hObject, eventdata)
handles = guidata(hObject);
delete(handles.slice);
set(hObject,'WindowButtonMotionFcn','');
set(hObject,'WindowButtonUpFcn','');
drawnow;

function viewSnippet(handles)
currentCenter = get(handles.sliceView, 'CurrentPoint');
Range = -50:50;
switch handles.viewDimension
    case 1
        [~,viewIndexX] = min(abs(handles.coRegistered.YRange - currentCenter(1,1)));
        [~,viewIndexY] = min(abs(handles.coRegistered.ZRange - currentCenter(1,2)));
        viewIndexX = min(max(1-Range(1),viewIndexX),handles.coRegistered.dimension(2)-Range(2));
        viewIndexY = min(max(1-Range(1),viewIndexY),handles.coRegistered.dimension(3)-Range(2));
        % Check if clicked outside the boundary of the scan
        if viewIndexX + Range(end) < length(handles.coRegistered.YRange) && viewIndexX~=(1-Range(1)) && viewIndexY + Range(end) < length(handles.coRegistered.ZRange)
            handles.slice = image(handles.sliceView, handles.coRegistered.YRange(viewIndexX + Range), handles.coRegistered.ZRange(viewIndexY + Range), squeeze(handles.overlayImage(handles.coRegistered.sliceIndex(1), viewIndexX + Range, viewIndexY + Range))' * handles.colormapResolution);
        end
    case 2
        [~,viewIndexX] = min(abs(handles.coRegistered.XRange - currentCenter(1,1)));
        [~,viewIndexY] = min(abs(handles.coRegistered.ZRange - currentCenter(1,2)));
        viewIndexX = min(max(1-Range(1),viewIndexX),handles.coRegistered.dimension(1)-Range(2));
        viewIndexY = min(max(1-Range(1),viewIndexY),handles.coRegistered.dimension(3)-Range(2));
        % Check if clicked outside the boundary of the scan
        if viewIndexX + Range(end) < length(handles.coRegistered.XRange) && viewIndexX~=(1-Range(1)) && viewIndexY + Range(end) < length(handles.coRegistered.ZRange)
            handles.slice = image(handles.sliceView, handles.coRegistered.XRange(viewIndexX + Range), handles.coRegistered.ZRange(viewIndexY + Range), squeeze(handles.overlayImage(viewIndexX + Range, handles.coRegistered.sliceIndex(2), viewIndexY + Range))' * handles.colormapResolution);
        end
    case 3
        [~,viewIndexX] = min(abs(handles.coRegistered.XRange - currentCenter(1,1)));
        [~,viewIndexY] = min(abs(handles.coRegistered.YRange - currentCenter(1,2)));
        viewIndexX = min(max(1-Range(1),viewIndexX),handles.coRegistered.dimension(1)-Range(2));
        viewIndexY = min(max(1-Range(1),viewIndexY),handles.coRegistered.dimension(2)-Range(2));
        % Check if clicked outside the boundary of the scan
        if viewIndexX + Range(end) < length(handles.coRegistered.XRange) && viewIndexX~=(1-Range(1)) && viewIndexY + Range(end) < length(handles.coRegistered.YRange)
            handles.slice = image(handles.sliceView, handles.coRegistered.XRange(viewIndexX + Range), handles.coRegistered.YRange(viewIndexY + Range), squeeze(handles.overlayImage(viewIndexX + Range, viewIndexY + Range, handles.coRegistered.sliceIndex(3)))' * handles.colormapResolution);
        end
end
guidata(handles.gui, handles);
drawnow;

function updateSnippet(handles)
currentCenter = get(handles.sliceView, 'CurrentPoint');
Range = -50:50;
switch handles.viewDimension
    case 1
        [~,viewIndexX] = min(abs(handles.coRegistered.YRange - currentCenter(1,1)));
        [~,viewIndexY] = min(abs(handles.coRegistered.ZRange - currentCenter(1,2)));
        viewIndexX = min(max(1-Range(1),viewIndexX),handles.coRegistered.dimension(2)-Range(end));
        viewIndexY = min(max(1-Range(1),viewIndexY),handles.coRegistered.dimension(3)-Range(end));
        % Check if the image handle is valid
        if isvalid(handles.slice)
            handles.slice.XData = handles.coRegistered.YRange(viewIndexX + Range);
            handles.slice.YData = handles.coRegistered.ZRange(viewIndexY + Range);
            handles.slice.CData = squeeze(handles.overlayImage(handles.coRegistered.sliceIndex(1), viewIndexX + Range, viewIndexY + Range))' * handles.colormapResolution;
        end
    case 2
        [~,viewIndexX] = min(abs(handles.coRegistered.XRange - currentCenter(1,1)));
        [~,viewIndexY] = min(abs(handles.coRegistered.ZRange - currentCenter(1,2)));
        viewIndexX = min(max(1-Range(1),viewIndexX),handles.coRegistered.dimension(1)-Range(end));
        viewIndexY = min(max(1-Range(1),viewIndexY),handles.coRegistered.dimension(3)-Range(end));
        % Check if the image handle is valid
        if isvalid(handles.slice)
            handles.slice.XData = handles.coRegistered.XRange(viewIndexX + Range);
            handles.slice.YData = handles.coRegistered.ZRange(viewIndexY + Range);
            handles.slice.CData = squeeze(handles.overlayImage(viewIndexX + Range, handles.coRegistered.sliceIndex(2), viewIndexY + Range))' * handles.colormapResolution; 
        end
    case 3
        [~,viewIndexX] = min(abs(handles.coRegistered.XRange - currentCenter(1,1)));
        [~,viewIndexY] = min(abs(handles.coRegistered.YRange - currentCenter(1,2)));
        viewIndexX = min(max(1-Range(1),viewIndexX),handles.coRegistered.dimension(1)-Range(end));
        viewIndexY = min(max(1-Range(1),viewIndexY),handles.coRegistered.dimension(2)-Range(end));
        % Check if the image handle is valid
        if isvalid(handles.slice)
            handles.slice.XData = handles.coRegistered.XRange(viewIndexX + Range);
            handles.slice.YData = handles.coRegistered.YRange(viewIndexY + Range);
            handles.slice.CData = squeeze(handles.overlayImage(viewIndexX + Range, viewIndexY + Range, handles.coRegistered.sliceIndex(3)))' * handles.colormapResolution;
        end
end
guidata(handles.gui, handles);
drawnow;
