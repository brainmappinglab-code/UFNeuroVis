function leadLocalization( MRI, CT, leadFolder )
%Lead Localization Software

% Setup Figure
handles.gui = largeFigure(0, [1280 900]); clf(handles.gui);
handles.sliceViews.Sagittal = axes(handles.gui, 'Units', 'Normalized', 'Position', [0 0.5 0.5 0.5], 'DataAspectRatio',[1 1 1]); cla(handles.sliceViews.Sagittal);
handles.sliceViews.Coronal = axes(handles.gui, 'Units', 'Normalized', 'Position', [0.5 0.5 0.5 0.5], 'DataAspectRatio',[1 1 1], 'XDir', 'Reverse'); cla(handles.sliceViews.Coronal);
handles.sliceViews.Axial = axes(handles.gui, 'Units', 'Normalized', 'Position', [0 0 0.5 0.5], 'DataAspectRatio',[1 1 1], 'XDir', 'Reverse'); cla(handles.sliceViews.Axial);
handles.MRI = MRI;
handles.CT = CT;

handles.MRI.img = (handles.MRI.img - handles.MRI.intensityRange(1)) / diff(handles.MRI.intensityRange);
handles.CT.img = (handles.CT.img - handles.CT.intensityRange(1)) / diff(handles.CT.intensityRange);
handles.originalCT = handles.CT.img;

% Color Slider 
handles.MRI.contrast = [0.05 0.95];
handles.CT.contrast = [0.05 0.95];
handles.CTSlider.min = uicontrol('Style','Slider','Units','Normalized','Position',[0.6 0.05 0.3 0.02],'Callback',{@updateContrast,'CTmin'},'Value',0.05);
handles.CTSlider.max = uicontrol('Style','Slider','Units','Normalized','Position',[0.6 0.08 0.3 0.02],'Callback',{@updateContrast,'CTmax'},'Value',0.95);

% Figure Setup
hold(handles.sliceViews.Sagittal, 'on');
axis(handles.sliceViews.Sagittal, 'off');
hold(handles.sliceViews.Coronal, 'on');
axis(handles.sliceViews.Coronal, 'off');
hold(handles.sliceViews.Axial, 'on');
axis(handles.sliceViews.Axial, 'off');

% Slice View Setup
handles.MRI.sliceIndex = round(handles.MRI.dimension/2);
handles.CT.sliceIndex = round(handles.CT.dimension/2);

% Colormap Setup
handles.colormapResolution = 2048;
handles.customColormap = [gray(handles.colormapResolution);jet(handles.colormapResolution)];
colormap(handles.gui, handles.customColormap);
set(handles.gui, 'Color', 'k');

% Adjust CT Contrast
handles.CT.img = (handles.CT.img - handles.CT.contrast(1)) / handles.CT.contrast(2);
handles.CT.img(handles.CT.img < 0) = 0;
handles.CT.img(handles.CT.img > 1) = 1;

% Scrolling Function
handles.selectedView = 1;
set(handles.gui, 'KeyPressFcn', @keyboardEvent)
set(handles.gui, 'WindowScrollWheelFcn', @scrollSlide)
set(handles.gui, 'WindowButtonMotionFcn', @checkAxes);

% Lead Localization Buttons
handles.leadlocalization.addNewLead = uicontrol('Style','PushButton','Units','Normalized','Position',[0.5 0.2 0.08 0.03],...
    'String','Add New Lead','Callback',{@addNew});
handles.leadlocalization.addNewLead = uicontrol('Style','PushButton','Units','Normalized','Position',[0.5 0.15 0.08 0.03],...
    'String','Save New Lead','Callback',{@saveLead});
handles.leadlocalization.distal.select = uicontrol('Style','PushButton','Units','Normalized','Position',[0.6 0.2 0.08 0.03],...
    'String','Select Distal','Callback',{@selectContact,'distal'});
handles.leadlocalization.proximal.select = uicontrol('Style','PushButton','Units','Normalized','Position',[0.7 0.2 0.08 0.03],...
    'String','Select Proximal','Callback',{@selectContact,'proximal'});
handles.leadlocalization.distal.view = uicontrol('Style','PushButton','Units','Normalized','Position',[0.6 0.15 0.08 0.03],...
    'String','View Distal','Callback',{@viewContact,'distal'});
handles.leadlocalization.proximal.view = uicontrol('Style','PushButton','Units','Normalized','Position',[0.7 0.15 0.08 0.03],...
    'String','View Proximal','Callback',{@viewContact,'proximal'});

leadModels = dir([getenv('NEURO_VIS_PATH'),filesep,'leadModels', filesep, '*.mat']);
leadTypeAll = cell(1,length(leadModels));
for n = 1:length(leadModels)
    leadTypeAll{n} = leadModels(n).name(1:end-4);
end
handles.leadlocalization.leadTypeSelect = uicontrol('Style','PopUpMenu','Units','Normalized','Position',[0.8 0.198 0.08 0.03],'FontSize',8,...
    'String',leadTypeAll,'Callback',{@selectLeadType});
handles.leadlocalization.leadSideSelect = uicontrol('Style','PopUpMenu','Units','Normalized','Position',[0.8 0.145 0.08 0.03],...
    'String',{'Left','Right'},'Callback',{@selectLeadSide});
handles.leadlocalization.lead.side = 'Left'; %default
handles.leadlocalization.leadContactSelect = uicontrol('Style','Edit','Units','Normalized','Position',[0.9 0.2 0.08 0.03],...
    'Callback',{@enterLeadContacts});

handles.leadlocalization.leadFolder = leadFolder;

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

handles.registeredImage(1) = image(handles.sliceViews.Sagittal, handles.CT.YRange, handles.CT.ZRange, squeeze(handles.CT.img(handles.CT.sliceIndex(1),:,:))' * handles.colormapResolution + 1 + handles.colormapResolution);
set(handles.registeredImage(1),'AlphaData',squeeze(handles.CT.img(handles.CT.sliceIndex(1),:,:))');
handles.registeredImage(2) = image(handles.sliceViews.Coronal, handles.CT.XRange, handles.CT.ZRange, squeeze(handles.CT.img(:,handles.CT.sliceIndex(2),:))' * handles.colormapResolution + 1 + handles.colormapResolution);
set(handles.registeredImage(2),'AlphaData',squeeze(handles.CT.img(:,handles.CT.sliceIndex(2),:))');
handles.registeredImage(3) = image(handles.sliceViews.Axial, handles.CT.XRange, handles.CT.YRange, squeeze(handles.CT.img(:,:,handles.CT.sliceIndex(3)))' * handles.colormapResolution + 1 + handles.colormapResolution);
set(handles.registeredImage(3),'AlphaData',squeeze(handles.CT.img(:,:,handles.CT.sliceIndex(3)))');

handles.MRI.centerDimensions = [handles.MRI.XRange(handles.MRI.sliceIndex(1)), handles.MRI.YRange(handles.MRI.sliceIndex(2)), handles.MRI.ZRange(handles.MRI.sliceIndex(3))];
handles.crosshair.Sagittal(1) = plot(handles.sliceViews.Sagittal, handles.MRI.centerDimensions(2) + diff(handles.sliceViews.Sagittal.XLim)*[-0.01 0.01], [handles.MRI.centerDimensions(3) handles.MRI.centerDimensions(3)], 'r');
handles.crosshair.Sagittal(2) = plot(handles.sliceViews.Sagittal, [handles.MRI.centerDimensions(2) handles.MRI.centerDimensions(2)], diff(handles.sliceViews.Sagittal.XLim)*[-0.01 0.01] + handles.MRI.centerDimensions(3), 'r');
handles.crosshair.Coronal(1) = plot(handles.sliceViews.Coronal, handles.MRI.centerDimensions(1) + diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01], [handles.MRI.centerDimensions(3) handles.MRI.centerDimensions(3)], 'r');
handles.crosshair.Coronal(2) = plot(handles.sliceViews.Coronal, [handles.MRI.centerDimensions(1) handles.MRI.centerDimensions(1)], diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01] + handles.MRI.centerDimensions(3), 'r');
handles.crosshair.Axial(1) = plot(handles.sliceViews.Axial, handles.MRI.centerDimensions(1) + diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01], [handles.MRI.centerDimensions(2) handles.MRI.centerDimensions(2)], 'r');
handles.crosshair.Axial(2) = plot(handles.sliceViews.Axial, [handles.MRI.centerDimensions(1) handles.MRI.centerDimensions(1)], diff(handles.sliceViews.Coronal.XLim)*[-0.01 0.01] + handles.MRI.centerDimensions(2), 'r');

set(handles.registeredImage(1),'ButtonDownFcn',{@startMoving});
set(handles.registeredImage(2),'ButtonDownFcn',{@startMoving});
set(handles.registeredImage(3),'ButtonDownFcn',{@startMoving});
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

handles.registeredImage(1).CData = squeeze(handles.CT.img(handles.MRI.sliceIndex(1),:,:))' * handles.colormapResolution + 1 + handles.colormapResolution;
handles.registeredImage(1).AlphaData = squeeze(handles.CT.img(handles.MRI.sliceIndex(1),:,:))';
handles.registeredImage(2).CData = squeeze(handles.CT.img(:,handles.MRI.sliceIndex(2),:))' * handles.colormapResolution + 1 + handles.colormapResolution;
handles.registeredImage(2).AlphaData = squeeze(handles.CT.img(:,handles.MRI.sliceIndex(2),:))';
handles.registeredImage(3).CData = squeeze(handles.CT.img(:,:,handles.MRI.sliceIndex(3)))' * handles.colormapResolution + 1 + handles.colormapResolution;
handles.registeredImage(3).AlphaData = squeeze(handles.CT.img(:,:,handles.MRI.sliceIndex(3)))';

handles = updateCrossHair(handles);
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
handles.CT.sliceIndex(handles.selectedView) = handles.CT.sliceIndex(handles.selectedView) + eventdata.VerticalScrollCount * round(eventdata.VerticalScrollAmount / 2);
handles.MRI.sliceIndex(handles.selectedView) = min(max(1, handles.MRI.sliceIndex(handles.selectedView)), handles.MRI.dimension(handles.selectedView));
handles.CT.sliceIndex(handles.selectedView) = min(max(1, handles.CT.sliceIndex(handles.selectedView)), handles.CT.dimension(handles.selectedView));
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
        handles.CT.sliceIndex(handles.selectedView) = min(max(1, handles.CT.sliceIndex(handles.selectedView) + diffSlice), handles.CT.dimension(handles.selectedView));
    case 'downarrow'
        diffSlice = -1;
        handles.MRI.sliceIndex(handles.selectedView) = min(max(1, handles.MRI.sliceIndex(handles.selectedView) + diffSlice), handles.MRI.dimension(handles.selectedView));
        handles.CT.sliceIndex(handles.selectedView) = min(max(1, handles.CT.sliceIndex(handles.selectedView) + diffSlice), handles.CT.dimension(handles.selectedView));
        
end
switch handles.selectedView
    case 1
        handles.MRI.centerDimensions(1) = handles.MRI.XRange(handles.MRI.sliceIndex(1));
        handles.CT.centerDimensions(1) = handles.CT.XRange(handles.CT.sliceIndex(1));
    case 2
        handles.MRI.centerDimensions(2) = handles.MRI.YRange(handles.MRI.sliceIndex(2));
        handles.CT.centerDimensions(2) = handles.CT.YRange(handles.CT.sliceIndex(2));
    case 3
        handles.MRI.centerDimensions(3) = handles.MRI.ZRange(handles.MRI.sliceIndex(3));
        handles.CT.centerDimensions(3) = handles.CT.ZRange(handles.CT.sliceIndex(3));
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
    case 'CTmax'
        handles.CT.contrast(2) = hObject.Value;
        if strcmp(handles.CT.fileprefix,handles.MRI.fileprefix)
            handles.MRI.contrast(2) = hObject.Value; 
        end
        if handles.CTSlider.min.Value > hObject.Value
            handles.CTSlider.min.Value = hObject.Value;
            handles.CT.contrast(1) = hObject.Value;
            if strcmp(handles.CT.fileprefix,handles.MRI.fileprefix)
                handles.MRI.contrast(1) = hObject.Value; 
            end
        end
    case 'CTmin'
        handles.CT.contrast(1) = hObject.Value;
        if strcmp(handles.CT.fileprefix,handles.MRI.fileprefix)
            handles.MRI.contrast(1) = hObject.Value; 
        end
        if handles.CTSlider.max.Value < hObject.Value
            handles.CTSlider.max.Value = hObject.Value;
            handles.CT.contrast(2) = hObject.Value;
            if strcmp(handles.CT.fileprefix,handles.MRI.fileprefix)
                handles.MRI.contrast(1) = hObject.Value; 
            end
        end
end
handles.CT.img = handles.originalCT;
handles.CT.img = (handles.CT.img - handles.CT.contrast(1)) / handles.CT.contrast(2);
handles.CT.img(handles.CT.img < 0) = 0;
handles.CT.img(handles.CT.img > 1) = 1;
if strcmp(handles.CT.fileprefix,handles.MRI.fileprefix)
    handles.MRI.img = handles.originalCT;
    handles.MRI.img = (handles.CT.img - handles.CT.contrast(1)) / handles.CT.contrast(2);
    handles.MRI.img(handles.CT.img < 0) = 0;
    handles.MRI.img(handles.CT.img > 1) = 1;
end
updateSlices(handles)

%-------------------------------------%
%--------The following are -----------%
%--------series of callbacks----------%
%-------------------------------------%
function addNew(hObject, eventdata)
handles = guidata(hObject);
handles.leadlocalization.lead = [];
handles.leadlocalization.lead.distal = [0,0,0];
handles.leadlocalization.lead.proximal = [0,0,0];
handles.leadlocalization.lead.nContacts = 0;
handles.leadlocalization.lead.side = handles.leadlocalization.leadSideSelect.String{handles.leadlocalization.leadSideSelect.Value};
handles.leadlocalization.lead.type = handles.leadlocalization.leadTypeSelect.String{handles.leadlocalization.leadTypeSelect.Value};
guidata(hObject, handles);

function saveLead(hObject, eventdata)
handles = guidata(hObject);
Side = handles.leadlocalization.lead.side;
Type = handles.leadlocalization.lead.type;
nContacts = handles.leadlocalization.lead.nContacts;
Distal = handles.leadlocalization.lead.distal;
Proximal = handles.leadlocalization.lead.proximal;
leadName = sprintf('%s_',handles.leadlocalization.lead.side);
nLead = dir([handles.leadlocalization.leadFolder,filesep,leadName,'*']);
save([handles.leadlocalization.leadFolder,filesep,'LEAD_',leadName,sprintf('%.2d.mat',length(nLead)+1)],...
    'Side','Type','nContacts','Proximal','Distal');
addNew(hObject, [])

function selectContact(hObject, eventdata, type)
handles = guidata(hObject);
switch type
    case 'distal'
        handles.leadlocalization.lead.distal = handles.MRI.centerDimensions;
    case 'proximal'
        handles.leadlocalization.lead.proximal = handles.MRI.centerDimensions;
end
disp(sqrt(sum((handles.leadlocalization.lead.distal-handles.leadlocalization.lead.proximal).^2)))

updateSlices(handles);

function viewContact(hObject, eventdata, type)
handles = guidata(hObject);
switch type
    case 'distal'
        handles.MRI.centerDimensions = handles.leadlocalization.lead.distal;
        handles.CT.centerDimensions = handles.leadlocalization.lead.distal;
    case 'proximal'
        handles.MRI.centerDimensions = handles.leadlocalization.lead.proximal;
        handles.CT.centerDimensions = handles.leadlocalization.lead.proximal;
end
updateSlices(handles);

function selectLeadType(hObject, eventdata)
handles = guidata(hObject);
name = hObject.String{hObject.Value};
handles.leadlocalization.lead.type = hObject.String{hObject.Value};

if strcmp(name,'medtronic_3387') || strcmp(name,'medtronic_3389')
    handles.leadlocalization.lead.nContacts = 4;
else
   error('We dont know how many contacts there are. Pleaese see leadLocalization.m selectLeadType function'); 
end
guidata(hObject, handles);

function selectLeadSide(hObject, eventdata)
handles = guidata(hObject);
handles.leadlocalization.lead.side = hObject.String{hObject.Value};
guidata(hObject, handles);

function enterLeadContacts(hObject, eventdata)
handles = guidata(hObject);
handles.leadlocalization.lead.nContacts = hObject.Value;
guidata(hObject, handles);
