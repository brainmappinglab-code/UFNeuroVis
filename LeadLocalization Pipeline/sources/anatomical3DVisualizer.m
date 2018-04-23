function handles = anatomical3DVisualizer(figureHandler, NifTi)
% Anatomical3DVisualier generate the basic environment for the 3D
% visualization of MRI Images
%       handles = anatomical3DVisualizer(axeHandler, brainName)
%           Output Arguments:  
%               handles: struct containing all items generated in the code
%           Input Arguments:
%               axeHandler: handle to the axe where the image will be
%                   plotted
%               brainName: fullpath to the NifTi file containing MRI
%
%   J. Cagle, 2018

handles.gui = figureHandler; clf(handles.gui);
set(handles.gui, 'Renderer', 'opengl')

handles.Nii = NifTi;
handles.anatomicalView = axes(handles.gui, 'Units', 'Normalized', 'Position', [0 0 1 1], 'DataAspectRatio',[1 1 1]); 
hold(handles.anatomicalView,'on');
handles.anatomicalSlices(1) = generateAnatomicalSlice(handles, handles.Nii.MeshSagittal, 1, handles.Nii.XRange, round(length(handles.Nii.XRange)/2));
handles.anatomicalSlices(2) = generateAnatomicalSlice(handles, handles.Nii.MeshCoronal, 2, handles.Nii.YRange, round(length(handles.Nii.YRange)/2));
handles.anatomicalSlices(3) = generateAnatomicalSlice(handles, handles.Nii.MeshAxial, 3, handles.Nii.ZRange, round(length(handles.Nii.ZRange)/2));

axis(handles.anatomicalView,[handles.Nii.XRange([1 end]), handles.Nii.YRange([1 end]), handles.Nii.ZRange([1 end])]);
axis(handles.anatomicalView,'off');
axis(handles.anatomicalView,'vis3d');
view(handles.anatomicalView,3);
colormap(handles.anatomicalView, 'gray');

set(handles.gui, 'KeyPressFcn', @keyboardEvent)

% Update handles structure
guidata(handles.gui, handles);

% --- Generate Anatomical Slices for 3D View.
function surface = generateAnatomicalSlice( handles, Mesh, FixDim, DimRange, DimIndex )
% surface       The surface object for this slice
switch FixDim
    case 1
        surface = surf(handles.anatomicalView, DimRange(DimIndex) * Mesh.X, Mesh.Y, Mesh.Z, squeeze(handles.Nii.img(DimIndex,:,:))','edgecolor','none');
        sliceInfo.coordination = [mean(diff(DimRange)), 0, 0]';
    case 2
        surface = surf(handles.anatomicalView, Mesh.X, DimRange(DimIndex) * Mesh.Y, Mesh.Z, squeeze(handles.Nii.img(:,DimIndex,:))','edgecolor','none');
        sliceInfo.coordination = [0, mean(diff(DimRange)), 0]';
    case 3
        surface = surf(handles.anatomicalView, Mesh.X, Mesh.Y, DimRange(DimIndex) * Mesh.Z, squeeze(handles.Nii.img(:,:,DimIndex))','edgecolor','none');
        sliceInfo.coordination = [0, 0, mean(diff(DimRange))]';
end
sliceInfo.Mesh = Mesh;
sliceInfo.FixDim = FixDim;
sliceInfo.DimRange = DimRange;
sliceInfo.DimIndex = DimIndex;
set(surface, 'UserData', sliceInfo);

set(surface,'ButtonDownFcn',{@startMovement,handles});
guidata(handles.gui, handles);

% --- Get ready to move
function startMovement(hObject, eventdata, handles)
sliceInfo = get(hObject, 'UserData');
sliceInfo.StartIndex = sliceInfo.DimIndex;
sliceInfo.StartRay = get(handles.anatomicalView, 'CurrentPoint');
handles.oldMotionFcn = get(handles.gui,'WindowButtonMotionFcn');
handles.oldButtonUp = get(handles.gui,'WindowButtonUpFcn');
set(handles.gui,'WindowButtonMotionFcn',{@updateSlice,sliceInfo});
set(handles.gui,'WindowButtonUpFcn',@finishMovement);
handles.selectedSlice = hObject;
guidata(handles.gui, handles);

function updateSlice(hObject, eventdata, sliceInfo)
handles = guidata(hObject);
CurrentRay = get(handles.anatomicalView, 'CurrentPoint');
sliceOffset = distanceCalculation(sliceInfo.coordination, sliceInfo.StartRay, CurrentRay);
sliceInfo.DimIndex = min(max(1,sliceInfo.DimIndex + sliceOffset), length(sliceInfo.DimRange));
set(handles.selectedSlice,'UserData',sliceInfo);
switch sliceInfo.FixDim
    case 1
        handles.selectedSlice.XData = sliceInfo.DimRange(sliceInfo.DimIndex) * sliceInfo.Mesh.X;
        handles.selectedSlice.CData = squeeze(handles.Nii.img(sliceInfo.DimIndex,:,:))';
    case 2
        handles.selectedSlice.YData = sliceInfo.DimRange(sliceInfo.DimIndex) * sliceInfo.Mesh.Y;
        handles.selectedSlice.CData = squeeze(handles.Nii.img(:,sliceInfo.DimIndex,:))';
    case 3
        handles.selectedSlice.ZData = sliceInfo.DimRange(sliceInfo.DimIndex) * sliceInfo.Mesh.Z;
        handles.selectedSlice.CData = squeeze(handles.Nii.img(:,:,sliceInfo.DimIndex))';
end
drawnow;

function slicediff = distanceCalculation(s, startRay, nowRay)
% As referenced from LeadDBS
a = startRay(1,:)';
b = startRay(2,:)';
alphabeta = pinv([s'*s, -s'*(b-a);(b-a)'*s, -(b-a)'*(b-a)])*[s'*a, (b-a)'*a]';
alphastart = alphabeta(1);
a = nowRay(1,:)';
b = nowRay(2,:)';
alphabeta = pinv([s'*s, -s'*(b-a);(b-a)'*s, -(b-a)'*(b-a)])*[s'*a, (b-a)'*a]';
alphanow = alphabeta(1);
slicediff = round(alphanow-alphastart);

function finishMovement(hObject, eventdata, handles)
handles = guidata(hObject);
set(hObject,'WindowButtonMotionFcn',handles.oldMotionFcn);
set(hObject,'WindowButtonUpFcn',handles.oldButtonUp);
drawnow;

function keyboardEvent(hObject, eventdata)
handles = guidata(hObject);
if keyInterpreter(hObject, eventdata)
    hManager = uigetmodemanager(handles.gui);
    [hManager.WindowListenerHandles.Enabled] = deal(false);
    set(handles.gui, 'KeyPressFcn', @keyboardEvent);
    figure(handles.gui);
end