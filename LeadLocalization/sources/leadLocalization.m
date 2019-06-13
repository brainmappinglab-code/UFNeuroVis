function leadLocalization( MRI, CT, leadFolder )
%Lead Localization Software

%#ok<*INUSD>
%#ok<*INUSL>
%#ok<*NASGU>

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
handles.leadlocalization.reset = uicontrol('Style','PushButton','Units','Normalized','Position',[0.5 0.2 0.08 0.03],...
    'String','Reset','Callback',{@Reset});
handles.leadlocalization.saveNewLead = uicontrol('Style','PushButton','Units','Normalized','Position',[0.5 0.15 0.08 0.03],...
    'String','Save New Lead','Callback',{@saveLead});
handles.leadlocalization.distal.select = uicontrol('Style','PushButton','Units','Normalized','Position',[0.6 0.2 0.08 0.03],...
    'String','Select Distal','Callback',{@selectContact,'distal'});
handles.leadlocalization.proximal.select = uicontrol('Style','PushButton','Units','Normalized','Position',[0.7 0.2 0.08 0.03],...
    'String','Select Proximal','Callback',{@selectContact,'proximal'});
handles.leadlocalization.distal.showSelect = uicontrol('Style','text','Units','Normalized','Position',[0.6 0.25 0.08 0.03],...
    'String','[   0,   0,   0]','BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1]);
handles.leadlocalization.proximal.showSelect = uicontrol('Style','text','Units','Normalized','Position',[0.7 0.25 0.08 0.03],...
    'String','[   0,   0,   0]','BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1]);
handles.leadlocalization.missingContacts = uicontrol('Style','PushButton','Units','Normalized','Position',[0.85 0.25 0.08 0.03],...
    'String','Missing Contacts','Callback',{@missingContacts,'distal'});
handles.leadlocalization.distal.view = uicontrol('Style','PushButton','Units','Normalized','Position',[0.6 0.15 0.08 0.03],...
    'String','View Distal','Callback',{@viewContact,'distal'});
handles.leadlocalization.proximal.view = uicontrol('Style','PushButton','Units','Normalized','Position',[0.7 0.15 0.08 0.03],...
    'String','View Proximal','Callback',{@viewContact,'proximal'});

leadModels = dir([getenv('NEURO_VIS_PATH'),filesep,'leadModels', filesep, '*.mat']);
leadTypeAll = cell(1,length(leadModels)+1);
leadTypeAll{1} = 'Choose Lead';
for n = 1:length(leadModels)
    leadTypeAll{n+1} = leadModels(n).name(1:end-4);
end
handles.leadlocalization.leadTypeSelect = uicontrol('Style','PopUpMenu','Units','Normalized','Position',[0.8 0.198 0.08 0.03],'FontSize',8,...
    'String',leadTypeAll,'Callback',{@selectLeadType});
handles.leadlocalization.leadSideSelect = uicontrol('Style','PopUpMenu','Units','Normalized','Position',[0.8 0.145 0.08 0.03],...
    'String',{'Choose Side','Left','Right'},'Callback',{@selectLeadSide});
handles.leadlocalization.leadContactSelect = uicontrol('Style','Edit','Units','Normalized','Position',[0.9 0.2 0.08 0.03],...
    'String','Number of Contacts','Callback',{@enterLeadContacts});
handles.leadlocalization.leadNotes = uicontrol('Style','Edit','Units','Normalized','Position',[0.9 0.15 0.08 0.03],...
    'String','Notes');

handles.leadlocalization.leadFolder = leadFolder;

guidata(handles.gui,handles);

Reset(handles.leadlocalization.reset,[]);

handles=guidata(handles.gui);

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
function Reset(hObject, eventdata)
handles = guidata(hObject);
handles.leadlocalization.lead = [];
handles.leadlocalization.lead.distal = [0,0,0];
handles.leadlocalization.lead.proximal = [0,0,0];
handles.leadlocalization.lead.nContacts = 0;
handles.leadlocalization.lead.side = handles.leadlocalization.leadSideSelect.String{handles.leadlocalization.leadSideSelect.Value};
handles.leadlocalization.lead.type = handles.leadlocalization.leadTypeSelect.String{handles.leadlocalization.leadTypeSelect.Value};
handles.leadlocalization.leadContactSelect.String = 'Number of contacts';
handles.leadlocalization.leadNotes.String = 'Notes';
handles.leadlocalization.leadTypeSelect.Value = 1;
handles.leadlocalization.leadSideSelect.Value = 1;
handles.leadlocalization.distal.showSelect.String='[   0,   0,   0]';
handles.leadlocalization.proximal.showSelect.String='[   0,   0,   0]';

if isfield(handles,'interp')
    close(handles.interp.gui);
    handles=rmfield(handles,'interp');
end

guidata(hObject, handles);

function savePoints(filename, Distal, Proximal, numContacts)
Distance = (Proximal - Distal) / (numContacts - 1);
fid = fopen(filename,'w+');
fprintf(fid,'x,y,z,t,label,comment\n');
% fprintf(fid,'%.2f,%.2f,%.2f,0,1,This is Contact 0\n',Distal(1),Distal(2),Distal(3));
% fprintf(fid,'%.2f,%.2f,%.2f,0,2,This is Contact 1\n',Distal(1) + Distance(1), Distal(2) + Distance(2), Distal(3) + Distance(3));
% fprintf(fid,'%.2f,%.2f,%.2f,0,3,This is Contact 2\n',Distal(1) + Distance(1)*2, Distal(2) + Distance(2)*2, Distal(3) + Distance(3)*2);
for i=0:numContacts-2
    fprintf(fid,'%.2f,%.2f,%.2f,0,%d,This is Contact %d\n',Distal(1) + Distance(1)*i, Distal(2) + Distance(2)*i, Distal(3) + Distance(3)*i,i+1,i);
end
fprintf(fid,'%.2f,%.2f,%.2f,0,%d,This is Contact %d\n',Proximal(1),Proximal(2),Proximal(3),i+2,i+1);
fclose(fid);

function saveLead(hObject, eventdata)
handles = guidata(hObject);

if isfield(handles,'interp') % Dealing with missing contacts; need to extrapolate distal or proximal
    handles=findEndContacts(handles);
end

Side = handles.leadlocalization.lead.side; 
Type = handles.leadlocalization.lead.type;
nContacts = handles.leadlocalization.lead.nContacts;

if nContacts==0
    selectLeadType(handles.leadlocalization.leadTypeSelect,[]);
    handles = guidata(hObject);
    nContacts = handles.leadlocalization.lead.nContacts; 
end

if strcmp(Side,'Choose Side')
    disp('Need to choose a side before saving the lead');
    return;
elseif all(handles.leadlocalization.lead.distal == 0) || all(handles.leadlocalization.lead.proximal == 0)
    disp('No distal and/or proximal contacts chosen');
    return;
end

Distal = handles.leadlocalization.lead.distal;
Proximal = handles.leadlocalization.lead.proximal;

% If the estimated lead length from the contacts is greater than 0.5mm off from the
% documented lead length, warn the user
if abs(rssq(Distal - Proximal) - getLeadLength(Type)) >= 0.5
    uiwait(msgbox({'Warning: Estimated length is greater than 0.5mm off from expected length',...
        sprintf('Estimated length is %.2f, expected length is %.2f',rssq(Distal - Proximal),getLeadLength(Type)),...
        'Check location of estimated contact locations','Check number of contacts'},...
        'Length Differences','modal'));
    
    option1='Change length w/ proximal constant';
    option2='Change length w/ distal constant';
    option3='Change length w/out a constant contact';
    
    answer=questdlg({'Would you like to save the lead anyway? Choose an option below to attempt to correct the length',...
        'Press ''X'' to cancel'},...
        'Continue?',option1,option2,option3,option3);
    
    switch answer
        case option1
            handles=ChangeLength(handles,'p');  % proximal constant
            
        case option2
            handles=ChangeLength(handles,'d');  % distal constant
            
        case option3
            handles=ChangeLength(handles,'n');  % no constant
            
        otherwise
            return;
    end
    
    Distal = handles.leadlocalization.lead.distal;
    Proximal = handles.leadlocalization.lead.proximal;
end

Notes = handles.leadlocalization.leadNotes.String;
leadName = sprintf('%s_',handles.leadlocalization.lead.side);
nLead = dir([handles.leadlocalization.leadFolder,filesep,'LEAD_',leadName,'*.mat']);
save([handles.leadlocalization.leadFolder,filesep,'LEAD_',leadName,sprintf('%.2d.mat',length(nLead)+1)],...
    'Side','Type','nContacts','Proximal','Distal','Notes');
savePoints([handles.leadlocalization.leadFolder,filesep,'LEAD_',leadName,sprintf('%.2d.csv',length(nLead)+1)],Distal, Proximal, nContacts);
Reset(hObject, [])

function selectContact(hObject, eventdata, type)
handles = guidata(hObject);
switch type
    case 'distal'
        handles.leadlocalization.lead.distal = handles.MRI.centerDimensions;
        handles.leadlocalization.distal.showSelect.String=sprintf('[%.2f, %.2f, %.2f]',...
            handles.leadlocalization.lead.distal(1),handles.leadlocalization.lead.distal(2),...
            handles.leadlocalization.lead.distal(3));
    case 'proximal'
        handles.leadlocalization.lead.proximal = handles.MRI.centerDimensions;
        handles.leadlocalization.proximal.showSelect.String=sprintf('[%.2f, %.2f, %.2f]',...
            handles.leadlocalization.lead.proximal(1),handles.leadlocalization.lead.proximal(2),...
            handles.leadlocalization.lead.proximal(3));
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
elseif strcmp(name,'UF_sEEG_12')
    handles.leadlocalization.lead.nContacts = 12;
elseif strcmp(name,'UF_sEEG_14')
    handles.leadlocalization.lead.nContacts = 14;
elseif strcmp(name,'UF_sEEG_16')
    handles.leadlocalization.lead.nContacts = 16;
elseif strcmp(name,'UF_sEEG_10')
    handles.leadlocalization.lead.nContacts = 10;
elseif strcmp(name,'UF_sEEG_8')
    handles.leadlocalization.lead.nContacts = 8;
else
   error('We dont know how many contacts there are. Pleaese see leadLocalization.m selectLeadType function'); 
end
handles.leadlocalization.leadContactSelect.String=sprintf('%d',handles.leadlocalization.lead.nContacts);
guidata(hObject, handles);

function selectLeadSide(hObject, eventdata)
handles = guidata(hObject);
handles.leadlocalization.lead.side = hObject.String{hObject.Value};
guidata(hObject, handles);

function enterLeadContacts(hObject, eventdata) 
handles = guidata(hObject);
handles.leadlocalization.lead.nContacts = str2double(hObject.String);
guidata(hObject, handles);

function missingContacts(hObject, eventdata, type)
% Launches an external GUI that allows for interpolating missing contacts
handles=guidata(hObject);
nContacts=handles.leadlocalization.lead.nContacts;

if ~isfield(handles,'interp')
    handles.interp=interpolateMissingContacts(nContacts);
elseif isempty(handles.interp)
    handles.interp=interpolateMissingContacts(nContacts);    
elseif ~ishandle(handles.interp.gui)
    handles.interp=interpolateMissingContacts(nContacts);     
else
    return
end

for i=1:nContacts
    handles.interp.node(i).set.Callback={@setContact, i, hObject};
    handles.interp.node(i).view.Callback={@viewMissingContact, i, hObject};
end

handles.interp.gui.DeleteFcn={@deleteMissingContact, handles};

guidata(hObject,handles);

function setContact(hObject, eventdata, contactNumber, hObj)

handles=guidata(hObj);

handles.interp.node(contactNumber).pos=handles.MRI.centerDimensions;
handles.interp.node(contactNumber).posStr.String=sprintf('[%3.2f,%3.2f,%3.2f]',...
    handles.MRI.centerDimensions(1),handles.MRI.centerDimensions(2),...
    handles.MRI.centerDimensions(3));

guidata(hObj,handles);

function deleteMissingContact(hObject, eventdata, handles)
% handles=guidata(hObject);
handles=rmfield(handles,'interp');
guidata(hObject,handles);

function viewMissingContact(hObject, eventdata, contactNum, hObj)

handles = guidata(hObj);

if ~isempty(handles.interp.node(contactNum).pos)
    handles.MRI.centerDimensions = handles.interp.node(contactNum).pos;
    handles.CT.centerDimensions = handles.interp.node(contactNum).pos;

    updateSlices(handles);
end

function handles=findEndContacts(handles)
% Using the lead locations given in handles.interp, find the location of distal/proximal
% if they are not already set

method='mle';

if all(handles.leadlocalization.lead.distal == 0)
    indContact=0;
    
    for i=1:handles.leadlocalization.lead.nContacts
        if ~isempty(handles.interp.node(i).pos)
            indContact=[indContact,i]; %#ok<AGROW>
        end
    end
    
    indContact=indContact(2:end);
    
    if sum(indContact) == 1
        disp('Need to have more than one contact chosen to extrapolate');
        return;
    end
    
    switch method
        case 'bipolar'
            minContactKnown=min(indContact);

            possibleCombs=nchoosek(indContact,2);
            distalEstimate=nan(size(possibleCombs,1),3);

            for i=1:size(possibleCombs,1)
                dirVec=(handles.interp.node(possibleCombs(i,1)).pos - handles.interp.node(possibleCombs(i,2)).pos) / abs(possibleCombs(i,1) - possibleCombs(i,2));

                distalEstimate(i,:)=handles.interp.node(minContactKnown).pos + dirVec * (minContactKnown - 1);
            end

            handles.leadlocalization.lead.distal=mean(distalEstimate,1);
            
        case 'mle'
            len=length(indContact);
            allPoints=zeros(len,3);
            for i=1:len
                allPoints(i,:)=handles.interp.node(indContact(i)).pos;
            end
            
            r0=mean(allPoints);
            d=bsxfun(@minus,allPoints,r0);
            [~,~,V]=svd(d,0);
            dirVec=V(:,1)';
            t=(-40:0.01:40)';
            newLine=r0+t.*dirVec;
            
            val=nan(len,1);
            ind=nan(len,1);
            
            for i=1:len
                d=allPoints(i,:)-newLine;
                [val(i),ind(i)]=min(rssq(d,2));
            end
            
            belowThreshold=val <= 0.25;
            
            if sum(belowThreshold) < 2
                uiwait(msgbox('Warning: Not enough contacts are within threshold of the MLE line. Try some other method','ERROR','modal'));
            else
                newContacts=[];
                newPos=nan(sum(belowThreshold),3);
                count=1;
                
                for i=1:len
                    if belowThreshold(i)
                        newContacts=[newContacts,indContact(i)];  %#ok<AGROW>
                        newPos(count,:)=newLine(ind(i),:);
                        count=count+1;
                    end
                end
                
                minContactKnown=min(newContacts);
                possibleCombs=nchoosek(1:length(newContacts),2);
                distalEstimate=nan(size(possibleCombs,1),3);
                
                for i=1:size(possibleCombs,1)
                    dirVec=(newPos(possibleCombs(i,1),:) - newPos(possibleCombs(i,2),:)) / ...
                        abs(newContacts(possibleCombs(i,1)) - newContacts(possibleCombs(i,2)));
                    
                    distance=rssq(dirVec);
                    dirVec=dirVec * (3.5 / distance);

                    distalEstimate(i,:)=newPos(1,:) + dirVec * (minContactKnown - 1);
                end

                handles.leadlocalization.lead.distal=mean(distalEstimate,1);
                
            end
    end
end

if all(handles.leadlocalization.lead.proximal == 0)
    indContact=0;
    
    for i=1:handles.leadlocalization.lead.nContacts
        if ~isempty(handles.interp.node(i).pos)
            indContact=[indContact,i]; %#ok<AGROW>
        end
    end
    
    indContact=indContact(2:end);
    
    if sum(indContact) == 1
        disp('Need to have more than one contact chosen to interpolate');
    end
    
    switch method
        case 'bipolar'
            maxContactKnown=max(indContact);

            possibleCombs=nchoosek(indContact,2);
            proximalEstimate=nan(size(possibleCombs,1),3);

            for i=1:size(possibleCombs,1)
                dirVec=(handles.interp.node(possibleCombs(i,1)).pos - handles.interp.node(possibleCombs(i,2)).pos) / abs(possibleCombs(i,1) - possibleCombs(i,2));

                proximalEstimate(i,:)=handles.interp.node(maxContactKnown).pos - dirVec * (handles.leadlocalization.lead.nContacts - maxContactKnown);
            end

            handles.leadlocalization.lead.proximal=mean(proximalEstimate,1);
            
        case 'mle'
            len=length(indContact);
            allPoints=zeros(len,3);
            for i=1:len
                allPoints(i,:)=handles.interp.node(indContact(i)).pos;
            end
            
            r0=mean(allPoints);
            d=bsxfun(@minus,allPoints,r0);
            [~,~,V]=svd(d,0);
            dirVec=V(:,1)';
            t=(-40:0.01:40)';
            newLine=r0+t.*dirVec;
            
            val=nan(len,1);
            ind=nan(len,1);
            
            for i=1:len
                d=allPoints(i,:)-newLine;
                [val(i),ind(i)]=min(rssq(d,2));
            end
            
            belowThreshold=val <= 0.25;
            
            if sum(belowThreshold) < 2
                uiwait(msgbox('Warning: Not enough contacts are within threshold of the MLE line. Try some other method','ERROR','modal'));
            else
                newContacts=[];
                newPos=nan(sum(belowThreshold),3);
                count=1;
                
                for i=1:len
                    if belowThreshold(i)
                        newContacts=[newContacts,indContact(i)];  %#ok<AGROW>
                        newPos(count,:)=newLine(ind(i),:);
                        count=count+1;
                    end
                end
                
                maxContactKnown=max(newContacts);
                possibleCombs=nchoosek(1:length(newContacts),2);
                proximalEstimate=nan(size(possibleCombs,1),3);
                
                for i=1:size(possibleCombs,1)
                    dirVec=(newPos(possibleCombs(i,1),:) - newPos(possibleCombs(i,2),:)) / ...
                        abs(newContacts(possibleCombs(i,1)) - newContacts(possibleCombs(i,2)));
                    
                    distance=rssq(dirVec);
                    dirVec=dirVec * (3.5 / distance);

                    proximalEstimate(i,:)=newPos(end,:) - dirVec * (handles.leadlocalization.lead.nContacts - maxContactKnown);
                end

                handles.leadlocalization.lead.proximal=mean(proximalEstimate,1);
                
            end
    end
end

function handles=ChangeLength(handles,const)
% Change the length of the lead to match the expected lead length. 'const' refers to which
% contact is constant (i.e. which one does not change)

distal=handles.leadlocalization.lead.distal;
proximal=handles.leadlocalization.lead.proximal;
expectedLength=getLeadLength(handles.leadlocalization.lead.type);

switch const
    case 'p'
        dirVec=proximal-distal;
        handles.leadlocalization.lead.distal=proximal-dirVec*(expectedLength / rssq(dirVec));
        
    case 'd'
        dirVec=distal-proximal;
        handles.leadlocalization.lead.proximal=distal-dirVec*(expectedLength / rssq(dirVec));
        
    case 'n'
        dirVec=proximal-distal;
        lengthDiff=dirVec*(expectedLength / rssq(dirVec))-dirVec;
        handles.leadlocalization.lead.distal=proximal-dirVec-lengthDiff/2;
        handles.leadlocalization.lead.proximal=distal+dirVec+lengthDiff/2;
end

