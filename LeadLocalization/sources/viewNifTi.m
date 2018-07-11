function viewNifTi(MRI,atlasDir)
%MRI Visaulization

if nargin == 0
    [file,path] = uigetfile('*.nii','Pick a postop_ct file');
    MRI = loadNifTi([path,file]);
    atlasDir = '';
    handles.atlasCheck = false;
end

% Setup Figure
handles.gui = largeFigure(0, [1280 900]); clf(handles.gui);
handles.sliceViews.Sagittal = axes(handles.gui, 'Units', 'Normalized', 'Position', [0 0.5 0.5 0.5], 'DataAspectRatio',[1 1 1]); cla(handles.sliceViews.Sagittal);
handles.sliceViews.Coronal = axes(handles.gui, 'Units', 'Normalized', 'Position', [0.5 0.5 0.5 0.5], 'DataAspectRatio',[1 1 1], 'XDir', 'Reverse'); cla(handles.sliceViews.Coronal);
handles.sliceViews.Axial = axes(handles.gui, 'Units', 'Normalized', 'Position', [0 0 0.5 0.5], 'DataAspectRatio',[1 1 1], 'XDir', 'Reverse'); cla(handles.sliceViews.Axial);
handles.MRI = MRI;
%handles.MRI = loadNifTi('C:\Users\eisinger\Documents\CT_MRI_Analysis\MNI\ACPC_T1_imwarp_origin000.nii');

handles.MRI.img = (handles.MRI.img - handles.MRI.intensityRange(1)) / diff(handles.MRI.intensityRange);
handles.originalMRI = handles.MRI.img;

% Load Atlas
%atlasDir = '\\gunduz-lab.bme.ufl.edu\Data\BOVA_Atlas';
if handles.atlasCheck
    allAtlas = dir([atlasDir,filesep,'*.nii']);
    for n = 1:length(allAtlas)
        handles.atlases(n) = loadNifTi([atlasDir,filesep,allAtlas(n).name]);
    end
    handles.atlasThreshold = 0.3;
end

% Color Slider 
handles.MRI.contrast = [0.05 0.95];
handles.MRI.contrast = [0.05 0.95];
handles.MRISlider.min = uicontrol('Style','Slider','Units','Normalized','Position',[0.6 0.05 0.3 0.02],'Callback',{@updateContrast,'MRImin'},'Value',0.05);
handles.MRISlider.max = uicontrol('Style','Slider','Units','Normalized','Position',[0.6 0.08 0.3 0.02],'Callback',{@updateContrast,'MRImax'},'Value',0.95);

% Figure Setup
hold(handles.sliceViews.Sagittal, 'on');
axis(handles.sliceViews.Sagittal, 'off');
hold(handles.sliceViews.Coronal, 'on');
axis(handles.sliceViews.Coronal, 'off');
hold(handles.sliceViews.Axial, 'on');
axis(handles.sliceViews.Axial, 'off');

% Slice View Setup
handles.MRI.sliceIndex = round(handles.MRI.dimension/2);

% Colormap Setup
handles.colormapResolution = 2048;
handles.customColormap = gray(handles.colormapResolution);
colormap(handles.gui, handles.customColormap);
set(handles.gui, 'Color', 'k');

% Scrolling Function
handles.selectedView = 1;
set(handles.gui, 'KeyPressFcn', @keyboardEvent)
set(handles.gui, 'WindowScrollWheelFcn', @scrollSlide)
set(handles.gui, 'WindowButtonMotionFcn', @checkAxes);

viewSlices(handles);

function viewSlices(handles)
referenceSlice = squeeze(handles.MRI.img(handles.MRI.sliceIndex(1),:,:))';
handles.referenceImage(1) = image(handles.sliceViews.Sagittal, handles.MRI.YRange, handles.MRI.ZRange, referenceSlice * handles.colormapResolution);
axis(handles.sliceViews.Sagittal, [handles.MRI.YRange([1 end]), handles.MRI.ZRange([1 end])]);

referenceSlice = squeeze(handles.MRI.img(:,handles.MRI.sliceIndex(2),:))';
handles.referenceImage(2) = image(handles.sliceViews.Coronal, handles.MRI.XRange, handles.MRI.ZRange, referenceSlice * handles.colormapResolution);
axis(handles.sliceViews.Coronal, [handles.MRI.XRange([1 end]), handles.MRI.ZRange([1 end])]);

referenceSlice = squeeze(handles.MRI.img(:,:,handles.MRI.sliceIndex(3)))';
handles.referenceImage(3) = image(handles.sliceViews.Axial, handles.MRI.XRange, handles.MRI.YRange, referenceSlice * handles.colormapResolution);
axis(handles.sliceViews.Axial, [handles.MRI.XRange([1 end]), handles.MRI.YRange([1 end])]);

handles.MRI.centerDimensions = [handles.MRI.XRange(handles.MRI.sliceIndex(1)), handles.MRI.YRange(handles.MRI.sliceIndex(2)), handles.MRI.ZRange(handles.MRI.sliceIndex(3))];
handles.crosshair.Sagittal(1) = plot(handles.sliceViews.Sagittal, handles.MRI.centerDimensions(2) + diff(handles.sliceViews.Sagittal.XLim)*[-0.01 0.01], [handles.MRI.centerDimensions(3) handles.MRI.centerDimensions(3)], 'r');
handles.crosshair.Sagittal(2) = plot(handles.sliceViews.Sagittal, [handles.MRI.centerDimensions(2) handles.MRI.centerDimensions(2)], diff(handles.sliceViews.Sagittal.XLim)*[-0.01 0.01] + handles.MRI.centerDimensions(3), 'r');
handles.crosshair.Coronal(1) = plot(handles.sliceViews.Coronal, handles.MRI.centerDimensions(1) + diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01], [handles.MRI.centerDimensions(3) handles.MRI.centerDimensions(3)], 'r');
handles.crosshair.Coronal(2) = plot(handles.sliceViews.Coronal, [handles.MRI.centerDimensions(1) handles.MRI.centerDimensions(1)], diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01] + handles.MRI.centerDimensions(3), 'r');
handles.crosshair.Axial(1) = plot(handles.sliceViews.Axial, handles.MRI.centerDimensions(1) + diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01], [handles.MRI.centerDimensions(2) handles.MRI.centerDimensions(2)], 'r');
handles.crosshair.Axial(2) = plot(handles.sliceViews.Axial, [handles.MRI.centerDimensions(1) handles.MRI.centerDimensions(1)], diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01] + handles.MRI.centerDimensions(2), 'r');

set(handles.referenceImage(1),'ButtonDownFcn',{@startMoving});
set(handles.referenceImage(2),'ButtonDownFcn',{@startMoving});
set(handles.referenceImage(3),'ButtonDownFcn',{@startMoving});
guidata(handles.gui, handles);

function updateSlices(handles)
[~,handles.MRI.sliceIndex(1)] = min(abs(handles.MRI.XRange - handles.MRI.centerDimensions(1)));
[~,handles.MRI.sliceIndex(2)] = min(abs(handles.MRI.YRange - handles.MRI.centerDimensions(2)));
[~,handles.MRI.sliceIndex(3)] = min(abs(handles.MRI.ZRange - handles.MRI.centerDimensions(3)));
handles.MRI.sliceIndex(1) = min(max(1, handles.MRI.sliceIndex(1)),handles.MRI.dimension(1));
handles.MRI.sliceIndex(2) = min(max(1, handles.MRI.sliceIndex(2)),handles.MRI.dimension(2));
handles.MRI.sliceIndex(3) = min(max(1, handles.MRI.sliceIndex(3)),handles.MRI.dimension(3));

handles.referenceImage(1).CData = squeeze(handles.MRI.img(handles.MRI.sliceIndex(1),:,:))' * handles.colormapResolution;
handles.referenceImage(2).CData = squeeze(handles.MRI.img(:,handles.MRI.sliceIndex(2),:))' * handles.colormapResolution;
handles.referenceImage(3).CData = squeeze(handles.MRI.img(:,:,handles.MRI.sliceIndex(3)))' * handles.colormapResolution;

handles = updateCrossHair(handles);
if handles.atlasCheck
    handles = computeAtlas(handles);
end
guidata(handles.gui, handles);

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

function handles = computeAtlas(handles)
for child = handles.sliceViews.Sagittal.Children'
    if strcmpi(child.Tag,'Atlas')
        child.delete;
    end
end
for child = handles.sliceViews.Coronal.Children'
    if strcmpi(child.Tag,'Atlas')
        child.delete;
    end
end
for child = handles.sliceViews.Axial.Children'
    if strcmpi(child.Tag,'Atlas')
        child.delete;
    end
end

for n = 1:length(handles.atlases)
    [~,sliceIndex] = min(abs(handles.MRI.centerDimensions(1) - handles.atlases(n).XRange));
    BW = bwboundaries(squeeze(handles.atlases(n).img(sliceIndex,:,:)) > handles.atlasThreshold);
    for k = 1:length(BW)
        plot(handles.sliceViews.Sagittal, handles.atlases(n).YRange(BW{k}(:,1)),handles.atlases(n).ZRange(BW{k}(:,2)),'r','linewidth',2,'Tag','Atlas');
    end
    
    [~,sliceIndex] = min(abs(handles.MRI.centerDimensions(2) - handles.atlases(n).YRange));
    BW = bwboundaries(squeeze(handles.atlases(n).img(:,sliceIndex,:)) > handles.atlasThreshold);
    for k = 1:length(BW)
        plot(handles.sliceViews.Coronal, handles.atlases(n).XRange(BW{k}(:,1)),handles.atlases(n).ZRange(BW{k}(:,2)),'r','linewidth',2,'Tag','Atlas');
    end
    
    [~,sliceIndex] = min(abs(handles.MRI.centerDimensions(3) - handles.atlases(n).ZRange));
    BW = bwboundaries(handles.atlases(n).img(:,:,sliceIndex) > handles.atlasThreshold);
    for k = 1:length(BW)
        plot(handles.sliceViews.Axial, handles.atlases(n).XRange(BW{k}(:,1)),handles.atlases(n).YRange(BW{k}(:,2)),'r','linewidth',2,'Tag','Atlas');
    end
end

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

function startMoving(hObject, eventdata)
handles = guidata(hObject);
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
set(handles.gui,'WindowButtonMotionFcn',@motionDetected);
set(handles.gui,'WindowButtonUpFcn',@stopMotion);
updateSlices(handles)

function motionDetected(hObject, eventdata)
handles = guidata(hObject);
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
updateSlices(handles)

function stopMotion(hObject, eventdata)
set(hObject,'WindowButtonMotionFcn',@checkAxes);
set(hObject,'WindowButtonUpFcn','');

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
updateSlices(handles)

function keyboardEvent(hObject, eventdata)
handles = guidata(hObject);
switch eventdata.Key
    case 'uparrow'
        diffSlice = 1;
        handles.MRI.sliceIndex(handles.selectedView) = min(max(1, handles.MRI.sliceIndex(handles.selectedView) + diffSlice), handles.MRI.dimension(handles.selectedView));
    case 'downarrow'
        diffSlice = -1;
        handles.MRI.sliceIndex(handles.selectedView) = min(max(1, handles.MRI.sliceIndex(handles.selectedView) + diffSlice), handles.MRI.dimension(handles.selectedView));
end
switch handles.selectedView
    case 1
        handles.MRI.centerDimensions(1) = handles.MRI.XRange(handles.MRI.sliceIndex(1));
    case 2
        handles.MRI.centerDimensions(2) = handles.MRI.YRange(handles.MRI.sliceIndex(2));
    case 3
        handles.MRI.centerDimensions(3) = handles.MRI.ZRange(handles.MRI.sliceIndex(3));
end
updateSlices(handles)
if keyInterpreter(hObject, eventdata)
    hManager = uigetmodemanager(handles.gui);
    [hManager.WindowListenerHandles.Enabled] = deal(false);
    set(handles.gui, 'KeyPressFcn', @keyboardEvent);
    figure(handles.gui);
end

function updateContrast(hObject, eventdata, type)
handles = guidata(hObject);
switch type
    case 'MRImax'
        handles.MRI.contrast(2) = hObject.Value;
        if handles.MRISlider.min.Value > hObject.Value
            handles.MRISlider.min.Value = hObject.Value;
            handles.MRI.contrast(1) = hObject.Value;
        end
    case 'MRImin'
        handles.MRI.contrast(1) = hObject.Value;
        if handles.MRISlider.max.Value < hObject.Value
            handles.MRISlider.max.Value = hObject.Value;
            handles.MRI.contrast(2) = hObject.Value;
        end
end
handles.MRI.img = handles.originalMRI;
handles.MRI.img = (handles.MRI.img - handles.MRI.contrast(1)) / handles.MRI.contrast(2);
handles.MRI.img(handles.MRI.img < 0) = 0;
handles.MRI.img(handles.MRI.img > 1) = 1;
updateSlices(handles)
