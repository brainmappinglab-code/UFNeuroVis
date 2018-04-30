function [transformedMRI, transformMatrix, coordinates] = transformACPC( MRI )
%Lead Localization Software

handles.gui = largeFigure(105, [1280 900]); clf(handles.gui);
handles.sliceViews.Sagittal = axes(handles.gui, 'Units', 'Normalized', 'Position', [0 0.5 0.5 0.5]); cla(handles.sliceViews.Sagittal);
handles.sliceViews.Coronal = axes(handles.gui, 'Units', 'Normalized', 'Position', [0.5 0.5 0.5 0.5], 'XDir', 'Reverse'); cla(handles.sliceViews.Coronal);
handles.sliceViews.Axial = axes(handles.gui, 'Units', 'Normalized', 'Position', [0 0 0.5 0.5], 'XDir', 'Reverse'); cla(handles.sliceViews.Axial);
handles.originalMRI = MRI;
handles.MRI = MRI;
handles.transformedMRI = MRI;
handles.transformMatrix = [1,0,0,1;0,1,0,1;0,0,1,1;0,0,0,1];

% Color Slider % Setup Figure
handles.MRI.maxIntensity = prctile(prctile(prctile(handles.MRI.img, 95), 95), 95);
handles.MRI.contrast = [0.05 0.95];
handles.MRISlider.min = uicontrol('Style','Slider','Units','Normalized','Position',[0.6 0.05 0.3 0.02],'Callback',{@updateContrast,'MRImin'},'Value',0.05);
handles.MRISlider.max = uicontrol('Style','Slider','Units','Normalized','Position',[0.6 0.025 0.3 0.02],'Callback',{@updateContrast,'MRImax'},'Value',0.95);

% Figure Setup
hold(handles.sliceViews.Sagittal, 'on');
set(handles.sliceViews.Sagittal, 'DataAspectRatio',[1 1 1]);
axis(handles.sliceViews.Sagittal, 'off');
hold(handles.sliceViews.Coronal, 'on');
set(handles.sliceViews.Coronal, 'DataAspectRatio',[1 1 1]);
axis(handles.sliceViews.Coronal, 'off');
hold(handles.sliceViews.Axial, 'on');
set(handles.sliceViews.Axial, 'DataAspectRatio',[1 1 1]);
axis(handles.sliceViews.Axial, 'off');

% Slice View Setup
handles.MRI.sliceIndex = round(handles.MRI.dimension/2);

% Colormap Setup
handles.overlay = false;
handles.colormapResolution = 1024;
handles.customColormap = defineColormap(handles);
colormap(handles.gui, handles.customColormap);
set(handles.gui, 'Color', 'k');

% Scrolling Function
handles.selectedView = 1;
set(handles.gui, 'KeyPressFcn', @keyboardEvent)
set(handles.gui, 'WindowScrollWheelFcn', @scrollSlide)
set(handles.gui, 'WindowButtonMotionFcn', @checkAxes)

referenceSlice = squeeze(handles.MRI.img(handles.MRI.sliceIndex(1),:,:))' / handles.MRI.maxIntensity * handles.colormapResolution;
referenceSlice(referenceSlice > handles.colormapResolution) = handles.colormapResolution;
handles.referenceImage(1) = image(handles.sliceViews.Sagittal, handles.MRI.YRange, handles.MRI.ZRange, referenceSlice);
axis(handles.sliceViews.Sagittal, [handles.MRI.YRange([1 end]), handles.MRI.ZRange([1 end])]);

referenceSlice = squeeze(handles.MRI.img(:,handles.MRI.sliceIndex(2),:))' / handles.MRI.maxIntensity * handles.colormapResolution;
referenceSlice(referenceSlice > handles.colormapResolution) = handles.colormapResolution;
handles.referenceImage(2) = image(handles.sliceViews.Coronal, handles.MRI.XRange, handles.MRI.ZRange, referenceSlice);
axis(handles.sliceViews.Coronal, [handles.MRI.XRange([1 end]), handles.MRI.ZRange([1 end])]);

referenceSlice = squeeze(handles.MRI.img(:,:,handles.MRI.sliceIndex(3)))' / handles.MRI.maxIntensity * handles.colormapResolution;
referenceSlice(referenceSlice > handles.colormapResolution) = handles.colormapResolution;
handles.referenceImage(3) = image(handles.sliceViews.Axial, handles.MRI.XRange, handles.MRI.YRange, referenceSlice);
axis(handles.sliceViews.Axial, [handles.MRI.XRange([1 end]), handles.MRI.YRange([1 end])]);

handles.MRI.centerDimensions = [handles.MRI.XRange(handles.MRI.sliceIndex(1)), handles.MRI.YRange(handles.MRI.sliceIndex(2)), handles.MRI.ZRange(handles.MRI.sliceIndex(3))];
handles.crosshair.Sagittal(1) = plot(handles.sliceViews.Sagittal, handles.MRI.centerDimensions(2) + diff(handles.sliceViews.Sagittal.XLim)*[-0.01 0.01], [handles.MRI.centerDimensions(3) handles.MRI.centerDimensions(3)], 'r');
handles.crosshair.Sagittal(2) = plot(handles.sliceViews.Sagittal, [handles.MRI.centerDimensions(2) handles.MRI.centerDimensions(2)], diff(handles.sliceViews.Sagittal.XLim)*[-0.01 0.01] + handles.MRI.centerDimensions(3), 'r');
handles.crosshair.Coronal(1) = plot(handles.sliceViews.Coronal, handles.MRI.centerDimensions(1) + diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01], [handles.MRI.centerDimensions(3) handles.MRI.centerDimensions(3)], 'r');
handles.crosshair.Coronal(2) = plot(handles.sliceViews.Coronal, [handles.MRI.centerDimensions(1) handles.MRI.centerDimensions(1)], diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01] + handles.MRI.centerDimensions(3), 'r');
handles.crosshair.Axial(1) = plot(handles.sliceViews.Axial, handles.MRI.centerDimensions(1) + diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01], [handles.MRI.centerDimensions(2) handles.MRI.centerDimensions(2)], 'r');
handles.crosshair.Axial(2) = plot(handles.sliceViews.Axial, [handles.MRI.centerDimensions(1) handles.MRI.centerDimensions(1)], diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01] + handles.MRI.centerDimensions(2), 'r');

set(handles.referenceImage(1),'ButtonDownFcn',{@startMoving,1});
set(handles.referenceImage(2),'ButtonDownFcn',{@startMoving,2});
set(handles.referenceImage(3),'ButtonDownFcn',{@startMoving,3});

%load CRW
handles.crwText = uicontrol('Style','Text','Units','Normalized','Position',[0.62 0.44 0.26 0.03],...
    'String', 'No CRW loaded');
handles.crwText.ForegroundColor = [1 0 0];
handles.crwText.BackgroundColor = [0 0 0];
handles.loadButton = uicontrol('Style','PushButton','Units','Normalized','Position',[0.62 0.42 0.26 0.03],'Callback',{@loadCRWgui},...
    'String', 'Load CRW');

% AC/PC/MC Buttons
handles.transformButton.AC = uicontrol('Style','PushButton','Units','Normalized','Position',[0.62 0.34 0.06 0.05],'Callback',{@updatePosition,'AC'},...
    'String', 'Store AC');
handles.transformButton.PC = uicontrol('Style','PushButton','Units','Normalized','Position',[0.72 0.34 0.06 0.05],'Callback',{@updatePosition,'PC'},...
    'String', 'Store PC');
handles.transformButton.MC = uicontrol('Style','PushButton','Units','Normalized','Position',[0.82 0.34 0.06 0.05],'Callback',{@updatePosition,'MC'},...
    'String', 'Store MC');
handles.transformButton.AC = uicontrol('Style','PushButton','Units','Normalized','Position',[0.62 0.25 0.06 0.05],'Callback',{@showPosition,'AC'},...
    'String', 'Show AC');
handles.transformButton.PC = uicontrol('Style','PushButton','Units','Normalized','Position',[0.72 0.25 0.06 0.05],'Callback',{@showPosition,'PC'},...
    'String', 'Show PC');
handles.transformButton.MC = uicontrol('Style','PushButton','Units','Normalized','Position',[0.82 0.25 0.06 0.05],'Callback',{@showPosition,'MC'},...
    'String', 'Show MC');
handles.transformButton.transform = uicontrol('Style','PushButton','Units','Normalized','Position',[0.62 0.17 0.26 0.05],'Callback',{@mriTransformation},...
    'String', 'Apply Transformation');
handles.transformButton.revert = uicontrol('Style','PushButton','Units','Normalized','Position',[0.62 0.1 0.26 0.05],'Callback',@revertTransformation,...
    'String', 'Revert Transformation');
handles.transformPosition.AC = handles.MRI.centerDimensions;
handles.transformPosition.PC = handles.MRI.centerDimensions;
handles.transformPosition.MC = handles.MRI.centerDimensions;

set(handles.gui, 'CloseRequestFcn', @closeRequestFcn);
guidata(handles.gui, handles);
uiwait(handles.gui);

disp('Finished');
handles = guidata(handles.gui);
transformedMRI = handles.transformedMRI;
transformMatrix = handles.transformMatrix;
coordinates = handles.transformPosition;
delete(handles.gui);

function closeRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject, 'waitstatus'), 'waiting')
	uiresume(hObject);
else
	delete(hObject);
end

% ------- Function to update center position of the crosshair
function handles = updateCrossHair(handles)
handles.crosshair.Sagittal(1).XData = handles.MRI.centerDimensions(2) + diff(handles.sliceViews.Sagittal.XLim)*[-0.01 0.01];
handles.crosshair.Sagittal(1).YData = [handles.MRI.centerDimensions(3) handles.MRI.centerDimensions(3)];
handles.crosshair.Sagittal(2).XData = [handles.MRI.centerDimensions(2) handles.MRI.centerDimensions(2)];
handles.crosshair.Sagittal(2).YData = handles.MRI.centerDimensions(3) + diff(handles.sliceViews.Sagittal.XLim)*[-0.01 0.01];

handles.crosshair.Coronal(1).XData = handles.MRI.centerDimensions(1) + diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01];
handles.crosshair.Coronal(1).YData = [handles.MRI.centerDimensions(3) handles.MRI.centerDimensions(3)];
handles.crosshair.Coronal(2).XData = [handles.MRI.centerDimensions(1) handles.MRI.centerDimensions(1)];
handles.crosshair.Coronal(2).YData = handles.MRI.centerDimensions(3) + diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01];

handles.crosshair.Axial(1).XData = handles.MRI.centerDimensions(1) + diff(handles.sliceViews.Axial.XLim)*[-0.01 0.01];
handles.crosshair.Axial(1).YData = [handles.MRI.centerDimensions(2) handles.MRI.centerDimensions(2)];
handles.crosshair.Axial(2).XData = [handles.MRI.centerDimensions(1) handles.MRI.centerDimensions(1)];
handles.crosshair.Axial(2).YData = handles.MRI.centerDimensions(2) + diff(handles.sliceViews.Axial.XLim)*[-0.01 0.01];

% ------- Function to update MRI Images
function updateSlices(handles)
[~,handles.MRI.sliceIndex(1)] = min(abs(handles.MRI.XRange - handles.MRI.centerDimensions(1)));
[~,handles.MRI.sliceIndex(2)] = min(abs(handles.MRI.YRange - handles.MRI.centerDimensions(2)));
[~,handles.MRI.sliceIndex(3)] = min(abs(handles.MRI.ZRange - handles.MRI.centerDimensions(3)));
handles.MRI.sliceIndex(1) = min(max(1, handles.MRI.sliceIndex(1)),handles.MRI.dimension(1));
handles.MRI.sliceIndex(2) = min(max(1, handles.MRI.sliceIndex(2)),handles.MRI.dimension(2));
handles.MRI.sliceIndex(3) = min(max(1, handles.MRI.sliceIndex(3)),handles.MRI.dimension(3));
        
referenceSlice = squeeze(handles.MRI.img(handles.MRI.sliceIndex(1),:,:))' / handles.MRI.maxIntensity * handles.colormapResolution;
referenceSlice(referenceSlice > handles.colormapResolution) = handles.colormapResolution;
handles.referenceImage(1).CData = referenceSlice;

referenceSlice = squeeze(handles.MRI.img(:,handles.MRI.sliceIndex(2),:))' / handles.MRI.maxIntensity * handles.colormapResolution;
referenceSlice(referenceSlice > handles.colormapResolution) = handles.colormapResolution;
handles.referenceImage(2).CData = referenceSlice;

referenceSlice = squeeze(handles.MRI.img(:,:,handles.MRI.sliceIndex(3)))' / handles.MRI.maxIntensity * handles.colormapResolution;
referenceSlice(referenceSlice > handles.colormapResolution) = handles.colormapResolution;
handles.referenceImage(3).CData = referenceSlice;

handles = updateCrossHair(handles);
guidata(handles.gui, handles);

function loadCRWgui(hObject, eventdata)
handles = guidata(hObject);
[name,path] = uigetfile('\\gunduz-lab.bme.ufl.edu\Data\DBSArch\*','Select CRW');
CRW = loadCRW(fullfile(path,name));
if CRW.ACPC.Empty
   handles.crwText.String = [name ' [CRW file empty. Not using]'];
else
    handles.crwText.String = name;
    handles.transformPosition.AC = CRW.ACPC.AC.Point;
    handles.transformPosition.PC = CRW.ACPC.PC.Point;
    handles.transformPosition.MC = CRW.ACPC.Cntr.Point;
end
updateSlices(handles);




function updatePosition(hObject, eventdata, type)
handles = guidata(hObject);
switch type
    case 'AC'
        handles.transformPosition.AC = handles.MRI.centerDimensions;
    case 'PC'
        handles.transformPosition.PC = handles.MRI.centerDimensions;
    case 'MC'
        handles.transformPosition.MC = handles.MRI.centerDimensions;
end
updateSlices(handles);

function showPosition(hObject, eventdata, type)
handles = guidata(hObject);
switch type
    case 'AC'
        handles.MRI.centerDimensions = handles.transformPosition.AC;
    case 'PC'
        handles.MRI.centerDimensions = handles.transformPosition.PC;
    case 'MC'
        handles.MRI.centerDimensions = handles.transformPosition.MC;
end
updateSlices(handles);

function mriTransformation(hObject, eventdata)

disp('Transformation Started, Please wait...');

handles = guidata(hObject);
Origin = (handles.transformPosition.AC + handles.transformPosition.PC) / 2;
temp = (handles.transformPosition.MC - Origin) / rssq(handles.transformPosition.MC - Origin);
J = (handles.transformPosition.AC - handles.transformPosition.PC) / rssq(handles.transformPosition.AC - handles.transformPosition.PC);
I = cross(J,temp)/rssq(cross(J,temp));
K = cross(I,J)/rssq(cross(I,J));

Old = [Origin+I,1; Origin+J,1; Origin+K,1; Origin,1];
New = [1,0,0,1; 0,1,0,1; 0,0,1,1; 0,0,0,1];

T = Old\New;
T(:,4) = round(T(:,4));
tform = affine3d(T);

handles.transformedMRI = niftiWarp(handles.MRI, tform);
handles.transformMatrix = T;
handles.transformPosition.AC = transformPoint(handles.transformPosition.AC, T);
handles.transformPosition.PC = transformPoint(handles.transformPosition.PC, T);
handles.transformPosition.MC = transformPoint(handles.transformPosition.MC, T);

handles.MRI = handles.transformedMRI;
handles.MRI.sliceIndex = round(handles.MRI.dimension/2);
handles.MRI.maxIntensity = prctile(prctile(prctile(handles.MRI.img, 95), 95), 95);
handles.MRI.centerDimensions = [handles.MRI.XRange(handles.MRI.sliceIndex(1)), handles.MRI.YRange(handles.MRI.sliceIndex(2)), handles.MRI.ZRange(handles.MRI.sliceIndex(3))];

handles.referenceImage(1).XData = handles.MRI.YRange;
handles.referenceImage(1).YData = handles.MRI.ZRange;
handles.referenceImage(2).XData = handles.MRI.XRange;
handles.referenceImage(2).YData = handles.MRI.ZRange;
handles.referenceImage(3).XData = handles.MRI.XRange;
handles.referenceImage(3).YData = handles.MRI.YRange;

axis(handles.sliceViews.Sagittal, [handles.MRI.YRange([1 end]), handles.MRI.ZRange([1 end])]);
axis(handles.sliceViews.Coronal, [handles.MRI.XRange([1 end]), handles.MRI.ZRange([1 end])]);
axis(handles.sliceViews.Axial, [handles.MRI.XRange([1 end]), handles.MRI.YRange([1 end])]);
updateSlices(handles);
disp('Done');

function newPoint = transformPoint(point, T)
newPoint = [point,1]*T;
newPoint = newPoint(1:3);

function revertTransformation(hObject, eventdata)
handles = guidata(hObject);
handles.transformedMRI = handles.MRI;
handles.transformMatrix = [1,0,0,1;0,1,0,1;0,0,1,1;0,0,0,1];
handles.transformPosition.AC = handles.MRI.centerDimensions;
handles.transformPosition.PC = handles.MRI.centerDimensions;
handles.transformPosition.MC = handles.MRI.centerDimensions;

handles.MRI = handles.originalMRI;
handles.MRI.sliceIndex = round(handles.MRI.dimension/2);
handles.MRI.maxIntensity = prctile(prctile(prctile(handles.MRI.img, 95), 95), 95);
handles.MRI.centerDimensions = [handles.MRI.XRange(handles.MRI.sliceIndex(1)), handles.MRI.YRange(handles.MRI.sliceIndex(2)), handles.MRI.ZRange(handles.MRI.sliceIndex(3))];

handles.referenceImage(1).XData = handles.MRI.YRange;
handles.referenceImage(1).YData = handles.MRI.ZRange;
handles.referenceImage(2).XData = handles.MRI.XRange;
handles.referenceImage(2).YData = handles.MRI.ZRange;
handles.referenceImage(3).XData = handles.MRI.XRange;
handles.referenceImage(3).YData = handles.MRI.YRange;

axis(handles.sliceViews.Sagittal, [handles.MRI.YRange([1 end]), handles.MRI.ZRange([1 end])]);
axis(handles.sliceViews.Coronal, [handles.MRI.XRange([1 end]), handles.MRI.ZRange([1 end])]);
axis(handles.sliceViews.Axial, [handles.MRI.XRange([1 end]), handles.MRI.YRange([1 end])]);
updateSlices(handles);

function startMoving(hObject, eventdata, viewID)
handles = guidata(hObject);
handles.selectedView = viewID;
switch handles.selectedView
    case 1
        pt = get(handles.sliceViews.Sagittal, 'CurrentPoint');
        handles.MRI.centerDimensions([2 3]) = pt(1,[1,2]);
    case 2
        pt = get(handles.sliceViews.Coronal, 'CurrentPoint');
        handles.MRI.centerDimensions([1 3]) = pt(1,[1,2]);
    case 3
        pt = get(handles.sliceViews.Axial, 'CurrentPoint');
        handles.MRI.centerDimensions([1 2]) = pt(1,[1,2]);
end
updateSlices(handles);

function checkAxes(hObject, eventdata)
windowPosition = get(hObject,'Position');
mousePos = get(hObject,'CurrentPoint');
handles = guidata(hObject);
if mousePos(1) > windowPosition(3) / 2 && mousePos(2) > windowPosition(4) / 2
    handles.selectedView = 2;
elseif mousePos(1) < windowPosition(3) / 2 && mousePos(2) < windowPosition(4) / 2
    handles.selectedView = 3;
elseif mousePos(1) < windowPosition(3) / 2 && mousePos(2) > windowPosition(4) / 2
    handles.selectedView = 1;
end
guidata(hObject, handles);

function keyboardEvent(hObject, eventdata)
handles = guidata(hObject);
switch eventdata.Key
    case 'uparrow'
        diffSlice = 1;
        handles.MRI.sliceIndex(handles.viewDimension) = min(max(1, handles.reference.sliceIndex(handles.viewDimension) + diffSlice), handles.reference.dimension(handles.viewDimension));
        updateSlice(handles)
    case 'downarrow'
        diffSlice = -1;
        handles.MRI.sliceIndex(handles.viewDimension) = min(max(1, handles.reference.sliceIndex(handles.viewDimension) + diffSlice), handles.reference.dimension(handles.viewDimension));
        updateSlice(handles)
end
if keyInterpreter(hObject, eventdata);
    hManager = uigetmodemanager(handles.gui);
    [hManager.WindowListenerHandles.Enabled] = deal(false);
    set(handles.gui, 'KeyPressFcn', @keyboardEvent);
    figure(handles.gui);
end

function scrollSlide(hObject, eventdata)
handles = guidata(hObject);
handles.MRI.sliceIndex(handles.selectedView) = handles.MRI.sliceIndex(handles.selectedView) + eventdata.VerticalScrollCount * round(eventdata.VerticalScrollAmount / 2);
handles.MRI.sliceIndex(handles.selectedView) = min(max(1, handles.MRI.sliceIndex(handles.selectedView)), handles.MRI.dimension(handles.selectedView));
switch handles.selectedView
    case 1
        handles.MRI.centerDimensions(1) = handles.MRI.XRange(handles.MRI.sliceIndex(1));
    case 2
        handles.MRI.centerDimensions(2) = handles.MRI.YRange(handles.MRI.sliceIndex(2));
    case 3
        handles.MRI.centerDimensions(3) = handles.MRI.ZRange(handles.MRI.sliceIndex(3));
end
updateSlices(handles);

% ------- Function to update contrast value based on slider
function updateContrast(hObject, eventdata, type)
handles = guidata(hObject);
switch type
    case 'MRImax'
        handles.MRI.contrast(2) = hObject.Value;
        if handles.MRI.contrast(1) > hObject.Value
            handles.MRISlider.min.Value = hObject.Value;
            handles.MRI.contrast(1) = hObject.Value;
        end
    case 'MRImin'
        handles.MRI.contrast(1) = hObject.Value;
        if handles.MRI.contrast(2) < hObject.Value
            handles.MRISlider.max.Value = hObject.Value;
            handles.MRI.contrast(2) = hObject.Value;
        end
end
handles.customColormap = defineColormap(handles);
colormap(handles.gui, handles.customColormap);
updateSlices(handles)

% ------- Function to update colormap based on contrast
function colormap = defineColormap(handles)
ContrastID = round(handles.MRI.contrast * handles.colormapResolution);
mriMap = gray(diff(ContrastID));
mriMap = [repmat(mriMap(1,:),[ContrastID(1),1]);
          mriMap;
          repmat(mriMap(end,:),[handles.colormapResolution - ContrastID(2),1])];
colormap = mriMap;
