%Robert Eisinger, 2018
%No extra parameters necessary
function varargout = BovaAtlasFitter(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',  gui_Singleton,'gui_OpeningFcn', @BovaAtlasFitter_OpeningFcn,'gui_OutputFcn',  @BovaAtlasFitter_OutputFcn,'gui_LayoutFcn',[] ,'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


function BovaAtlasFitter_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

set(handles.figure1,'WindowButtonMotionFcn',{@mouseMove,handles});
set(handles.figure1,'WindowButtonDownFcn',{@mouseClick,handles});
set(handles.figure1,'WindowKeyPressFcn',{@keyPress,handles});
set(handles.figure1,'WindowScrollWheelFcn', {@wheelScrolled,handles});
    
%set some temp values
setappdata(handles.figure1,'XInd',293); %293
setappdata(handles.figure1,'YInd',307); %307
setappdata(handles.figure1,'ZInd',160); %209

Planned.Empty = 1;
setappdata(handles.figure1,'PlannedCoords',Planned);
Measured.Empty = 1;
setappdata(handles.figure1,'MeasuredCoords',Measured);

%set color
setappdata(handles.figure1,'ColorMin',0);
setappdata(handles.figure1,'ColorMax',1); %don't forget to change default value through GUIDE

setappdata(handles.figure1,'Updating',false);

z = zoom(handles.figure1);
set(z,'ActionPostCallback',{@zoomIn,handles});

setappdata(handles.figure1,'NeuroVisPath',varargin{3});

atlasDir = [getappdata(handles.figure1,'NeuroVisPath'),filesep,'atlasModels',filesep,'UF Anatomical Models',filesep,'lh'];%'\\gunduz-lab.bme.ufl.edu\Data\BOVA_Atlas\lh';
allAtlas = dir([atlasDir,filesep,'*.nii']);
disp('Loading atlas...')
for n = 1:length(allAtlas)
    atlases(n) = loadNifTi([atlasDir,filesep,allAtlas(n).name]);
end
disp('Done')
setappdata(handles.figure1,'atlases',atlases);
setappdata(handles.figure1,'originalAtlases',atlases);
setappdata(handles.figure1,'atlasThreshold',0.4);

%set lims
if ~isempty(varargin)
    InitNiftiFromNifti(handles,varargin{1});
    setappdata(handles.figure1,'ProcessedDir',varargin{2});
    %NOTE, varargin{3} used above
    
    %look for crw
    updateLeadPlannedPopup(handles);
    updateLeadMeasuredPopup(handles);
    
else
    InitNiftiFromPath(handles,'C:\Users\eisinger\Documents\CT_MRI_Analysis\MNI\ACPC_T1_imwarp_origin000.nii');
end

%turn on all structures for now
    structures = {'AC','CM','GPe','GPi','OT','Ru','SNr','STN','Str','Thal','Vc','Vim','Voa','Vop','ZI'};
    for i=1:length(structures)
        handles.([structures{i} 'Checkbox']).Value = ~handles.([structures{i} 'Checkbox']).Value;
    end

updatePlots(handles);

guidata(hObject, handles);


function updateLeadMeasuredPopup(handles)
    leads = dir(fullfile(getappdata(handles.figure1,'ProcessedDir'),'LEAD_*'));
    if ~isempty(leads)
        names = cell(size(leads));
        for i=1:length(leads)
            names{i} = leads(i).name;
        end
        handles.measuredPopup.String = names;
    end
        
function updateLeadPlannedPopup(handles)
    crws = dir(fullfile(getappdata(handles.figure1,'ProcessedDir'),'*_CRW.mat'));
    if ~isempty(crws)
        names = cell(size(crws));
        for i=1:length(crws)
            names{i} = crws(i).name;
        end
        handles.plannedPopup.String = names;
    end
            
function InitNiftiFromPath(handles,niftipath)
    disp('Loading nifti...'); 
    MRI = loadNifTi(niftipath);
    InitNiftiFromNifti(handles,MRI);
    disp('Done');

function InitNiftiFromNifti(handles,MRI)
    setappdata(handles.figure1,'MRI',MRI);
    UpdateDefaultLimits(handles);
    
    MRIsliceIndex = round(MRI.dimension/2);
    setappdata(handles.figure1,'MRIsliceIndex',MRIsliceIndex);
    setappdata(handles.figure1,'MRIcenterDimensions',[MRI.XRange(MRIsliceIndex(1)), MRI.YRange(MRIsliceIndex(2)), MRI.ZRange(MRIsliceIndex(3))]);
    
    [t1Dir,t1Name] = fileparts(MRI.fileprefix);
    [processedDir,processedName] = fileparts(t1Dir);
    [patientDir,patientName] = fileparts(processedDir);
    handles.patientFolderText.String = patientName;
    handles.patientFolderText.ForegroundColor = [0 0 0];
    handles.mriText.String = t1Name;
    handles.mriText.ForegroundColor = [0 0 0];


function UpdateDefaultLimits(handles)
    setappdata(handles.figure1,'XLim',GetDefaultLim(handles));
    setappdata(handles.figure1,'YLim',GetDefaultLim(handles));
    setappdata(handles.figure1,'ZLim',GetDefaultLim(handles));    

function Out = UpdateTranslationBasedOnLaterality(handles,translation)
    Out = translation;
    if handles.rightCheckbox.Value == 1
       Out(1) = -1*Out(1); %if we are on the right side, a negative shift means away from the midline, which mathematically is actually a positive number
    end
function Out = UpdateRotationBasedOnLaterality(handles,rotation)  
    Out = rotation;
    if handles.rightCheckbox.Value == 1
        Out(2) = -1*Out(2); %if we are on the right side, the rotation that occurs is actually flipped for y dimension
    end
    
function Out = getConsFromTextboxes(handles)
    Out.rotation = [str2num(handles.xRotateTextbox.String),str2num(handles.yRotateTextbox.String),str2num(handles.zRotateTextbox.String)];
    Out.translation = [str2num(handles.xTranslateTextbox.String),str2num(handles.yTranslateTextbox.String),str2num(handles.zTranslateTextbox.String)];
    Out.scale = [str2num(handles.xScaleTextbox.String),str2num(handles.yScaleTextbox.String),str2num(handles.zScaleTextbox.String)];
    
function TransformAtlas(handles)
    Cons = getConsFromTextboxes(handles);
    Rotation = deg2rad(Cons.rotation); %convert to radians
    Scale = Cons.scale;
    Translation = Cons.translation;
    
    %UPDATE BASED ON LATERALITY
    Translation = UpdateTranslationBasedOnLaterality(handles,Translation);
    Rotation = UpdateRotationBasedOnLaterality(handles,Rotation);
    
    xRot = [1 0 0 0; 0 cos(Rotation(1)) -sin(Rotation(1)) 0; 0 sin(Rotation(1)) cos(Rotation(1)) 0; 0 0 0 1];
    yRot = [cos(Rotation(2)) 0 sin(Rotation(2)) 0; 0 1 0 0; -sin(Rotation(2)) 0 cos(Rotation(2)) 0; 0 0 0 1];
    zRot = [cos(Rotation(3)) -sin(Rotation(3)) 0 0; sin(Rotation(3)) cos(Rotation(3)) 0 0; 0 0 1 0; 0 0 0 1];
    scale = [Scale(1) 0 0 0; 0 Scale(2) 0 0; 0 0 Scale(3) 0; 0 0 0 1];
    trans = [1 0 0 Translation(1); 0 1 0 Translation(2); 0 0 1 Translation(3); 0 0 0 1];
    
    atlas = getappdata(handles.figure1,'OriginalAtlas');
    
    structures = {'AC','CM','GPe','GPi','OT','Ru','SNr','STN','Str','Thal','Vc','Vim','Voa','Vop','ZI'};
    
    atlases = getappdata(handles.figure1,'originalAtlases');
    for n = 1:length(atlases)
        image = permute(atlases(n).img,[2,1,3]);
        image(isnan(image)) = 0;
        Ref = imref3d(size(image),atlases(n).XRange([1 end]) + [-1 1] * atlases(n).hdr.dime.pixdim(2) / 2,...
                atlases(n).YRange([1 end]) + [-1 1] * atlases(n).hdr.dime.pixdim(3) / 2,...
                atlases(n).ZRange([1 end]) + [-1 1] * atlases(n).hdr.dime.pixdim(4) / 2);
        
        tform = affine3d((xRot*yRot*zRot*scale*trans)');
        [warpedImage,refWarp] = imwarp(image, Ref, tform);
        warpedImage = permute(warpedImage,[2,1,3]);

        XRange = linspace(refWarp.XWorldLimits(1) + refWarp.PixelExtentInWorldX / 2, refWarp.XWorldLimits(2) - refWarp.PixelExtentInWorldX / 2, refWarp.ImageSize(2));
        YRange = linspace(refWarp.YWorldLimits(1) + refWarp.PixelExtentInWorldY / 2, refWarp.YWorldLimits(2) - refWarp.PixelExtentInWorldY / 2, refWarp.ImageSize(1));
        ZRange = linspace(refWarp.ZWorldLimits(1) + refWarp.PixelExtentInWorldZ / 2, refWarp.ZWorldLimits(2) - refWarp.PixelExtentInWorldZ / 2, refWarp.ImageSize(3));

        newAtlases(n) = atlases(n);
        newAtlases(n).XRange = XRange;
        newAtlases(n).YRange = YRange;
        newAtlases(n).ZRange = ZRange;
        newAtlases(n).img = warpedImage;
    end
    setappdata(handles.figure1,'atlases',newAtlases); 

    disp 'Done Transforming';
   
     
function zoomIn(varargin)
    newaxes = varargin{2}.Axes;
    handles = varargin{3};
    curXLim = getappdata(handles.figure1,'XLim');
    curYLim = getappdata(handles.figure1,'YLim');
    curZLim = getappdata(handles.figure1,'ZLim');

    %zoomout = false;
    if(MouseOverCoronalPlot(handles))
        ZoomFromAxes(handles,newaxes,'XLim','ZLim','YLim');
    elseif(MouseOverSagittalPlot(handles))
        disp('testtest');
        ZoomFromAxes(handles,newaxes,'YLim','ZLim','XLim');
    elseif(MouseOverAxialPlot(handles))
        ZoomFromAxes(handles,newaxes,'XLim','YLim','ZLim');
    end   
        
function ZoomFromAxes(handles,newaxes,xaxis,yaxis,otheraxis)
    curFirstLim = getappdata(handles.figure1,xaxis); %whatever x-axis is
    curSecondLim = getappdata(handles.figure1,yaxis); %whatever y-axis is
    curThirdLim = getappdata(handles.figure1,otheraxis); %whatever the other axis is (not x and y)
    
    newFirstLim = newaxes.(xaxis); %whatever the x-axis is
    newSecondLim = newaxes.(yaxis); %whatever the y-axis is
    
    if range(newFirstLim) < range(curFirstLim) %then we are zooming in
        currentThird = getappdata(handles.figure1,otheraxis);
        halfwayNewThirdLim = currentThird(1)+range(currentThird)/2;
        if(range(newFirstLim)>range(newSecondLim))
            halfwayNewSecondLim = newSecondLim(1)+range(newSecondLim)/2;
            actualNewSecondLim = [halfwayNewSecondLim-range(newFirstLim)/2 halfwayNewSecondLim+range(newFirstLim)/2];
            setappdata(handles.figure1,xaxis,newFirstLim);
            setappdata(handles.figure1,yaxis,actualNewSecondLim);
            setappdata(handles.figure1,otheraxis,[halfwayNewThirdLim-range(newFirstLim)/2 halfwayNewThirdLim+range(newFirstLim)/2]);
        else
            halfwayNewFirstLim = newFirstLim(1)+range(newFirstLim)/2;
            actualNewFirstLim = [halfwayNewFirstLim-range(newSecondLim)/2 halfwayNewFirstLim+range(newSecondLim)/2];
            setappdata(handles.figure1,xaxis,actualNewFirstLim);
            setappdata(handles.figure1,yaxis,newSecondLim);
            setappdata(handles.figure1,otheraxis,[halfwayNewThirdLim-range(newSecondLim)/2 halfwayNewThirdLim+range(newSecondLim)/2]);
        end
        updatePlots(handles);
    else
        ZoomOut(handles);
    end
        
function ZoomOut(handles)  
    %zoom everything out a bit
    
    curXLim = getappdata(handles.figure1,'XLim');
    curYLim = getappdata(handles.figure1,'YLim');
    curZLim = getappdata(handles.figure1,'ZLim');
    
    scale = 0.1;
    newXLim = [curXLim(1)-scale*range(curXLim) curXLim(2)+scale*range(curXLim)];
    newYLim = [curYLim(1)-scale*range(curYLim) curYLim(2)+scale*range(curYLim)];
    newZLim = [curZLim(1)-scale*range(curZLim) curZLim(2)+scale*range(curZLim)];
    DefLim = GetDefaultLim(handles);
    if newXLim(1) < DefLim(1) || newYLim(1) < DefLim(1) || newZLim(1) < DefLim(1) || newXLim(2) > DefLim(2) || newYLim(2) > DefLim(2) || newZLim(2) > DefLim(2)
        newXLim = DefLim;
        newYLim = DefLim;
        newZLim = DefLim;
    end
    setappdata(handles.figure1,'XLim',newXLim);
    setappdata(handles.figure1,'YLim',newYLim);
    setappdata(handles.figure1,'ZLim',newZLim);
    
    updatePlots(handles);
        
function keyPress(varargin)
     fig1 = varargin{1};
     keyevent = varargin{2};
     handles = varargin{3};
     key = keyevent.Key;
     MousePos = get(handles.figure1,'currentpoint');

     CheckKeyPress(handles,handles.sagittalPlot,MousePos,key,'XInd');
     CheckKeyPress(handles,handles.coronalPlot,MousePos,key,'YInd');
     CheckKeyPress(handles,handles.axialPlot,MousePos,key,'ZInd');

function wheelScrolled(varargin)
    handles = varargin{3};
    direction = varargin{2}.VerticalScrollCount;
    MousePos = get(handles.figure1,'currentpoint');
    if(MouseOverPlot(MousePos,handles.coronalPlot))
        if(direction < 0) %zoom in
            %x = GetNearestPoint(MousePos(1));
            %y = GetNearestPoint(MousePos(2));
            %scalechange = 10;
            %offsetx = -(x*scalechange);
            %offsety = -(y*scalechange);
            %handles.
            
        else %zoom out
            disp('neg')
        end
    end
        
function mouseClick(varargin)
    handles = varargin{3};
    MousePos = get(handles.figure1,'currentpoint');
    CheckMouseClickSagittal(MousePos,handles);
    CheckMouseClickCoronal(MousePos,handles);
    CheckMouseClickAxial(MousePos,handles);

function mouseMove (varargin)
    handles = varargin{3};
    CheckMouseOverPlots(handles)
    
function CheckMouseOverPlots(handles)
    MousePos = get(handles.figure1,'currentpoint');
    CheckMouseOverPlot(MousePos,handles.coronalPlot);
    CheckMouseOverPlot(MousePos,handles.sagittalPlot);
    CheckMouseOverPlot(MousePos,handles.axialPlot);
    
function updatePlots(handles)
    
    if ~getappdata(handles.figure1,'Updating')
        setappdata(handles.figure1,'Updating',true);
        Nifti = getappdata(handles.figure1,'MRI');
        XInd = getappdata(handles.figure1,'XInd');
        YInd = getappdata(handles.figure1,'YInd');
        ZInd = getappdata(handles.figure1,'ZInd');
        handles.xIndexText.String = num2str(XInd);
        handles.yIndexText.String = num2str(YInd);
        handles.zIndexText.String = num2str(ZInd);

        coronal = (squeeze(Nifti.img(:,YInd,:))); %with coronal we fix Y and just have x and z left
        sagittal = (squeeze(Nifti.img(XInd,:,:))); %with sagittal we fix X and just have y and z left
        axial = (squeeze(Nifti.img(:,:,ZInd))); %with axial we fix Z and just have x and y left
        histObj = Nifti.original.hdr.hist;

        xstart = histObj.srow_x(4);
        ystart = histObj.srow_y(4);
        zstart = histObj.srow_z(4);
        dx = histObj.srow_x(1);
        dy = histObj.srow_y(2);
        dz = histObj.srow_z(3);
        Nx = size(Nifti.img,1);
        Ny = size(Nifti.img,2);
        Nz = size(Nifti.img,3);
        x = xstart + (0:Nx-1)*dx;
        y = ystart + (0:Ny-1)*dy;
        z = zstart + (0:Nz-1)*dz;
        handles.xText.String = num2str(x(XInd));
        handles.yText.String = num2str(y(YInd));
        handles.zText.String = num2str(z(ZInd));

        imagesc(handles.sagittalPlot,y,z,sagittal');
        axis(handles.sagittalPlot,'xy')
        xlim(handles.sagittalPlot,getappdata(handles.figure1,'YLim'));
        ylim(handles.sagittalPlot,getappdata(handles.figure1,'ZLim'));
        hold(handles.sagittalPlot,'on');

        imagesc(handles.coronalPlot,x,z,coronal');
        axis(handles.coronalPlot,'xy')
        set(handles.coronalPlot,'Xdir','reverse');
        xlim(handles.coronalPlot,getappdata(handles.figure1,'XLim'));
        ylim(handles.coronalPlot,getappdata(handles.figure1,'ZLim'));
        hold(handles.coronalPlot,'on');

        imagesc(handles.axialPlot,x,y,axial');
        axis(handles.axialPlot,'xy')
        set(handles.axialPlot,'Xdir','reverse');
        xlim(handles.axialPlot,getappdata(handles.figure1,'XLim'));
        ylim(handles.axialPlot,getappdata(handles.figure1,'YLim'));
        hold(handles.axialPlot,'on');
        
        %drawMeasuredCoords
        Measured = getappdata(handles.figure1,'MeasuredCoords');
        if ~Measured.Empty
            
            if z(ZInd)>=Measured.Distal(3)
            
                %(x-x1)/l = (y-y1)/m = (z-z1)/n
                %l*(y-y1) = m*(x-x1)
                %l*(z-z1) = n*(x-x1)
                %m*(z-z1) = n*(y-y1)
                %l,m,n = unit vec
                %x1,y1,z1 = distal point

                diffs = Measured.Proximal-Measured.Distal;
                uv = diffs/norm(diffs); %unit vec
                l = uv(1); m = uv(2); n = uv(3);
                xdif = x(XInd) - Measured.Distal(1);
                ydif = y(YInd) - Measured.Distal(2);
                zdif = z(ZInd) - Measured.Distal(3);

                %knowing x, solve for y and z
                theY = ((m*xdif)/l)+Measured.Distal(2); %l*(y-y1) = m*(x-x1)
                theZ = ((n*xdif)/l)+Measured.Distal(3); %l*(z-z1) = n*(x-x1)
                %scatter(handles.sagittalPlot,theY,theZ,'MarkerEdgeColor',[0 1 1],'LineWidth',3)

                %knowing y, solve for x and z
                theX = ((l*ydif)/m)+Measured.Distal(2); %l*(y-y1) = m*(x-x1)
                theZ = ((n*ydif)/m)+Measured.Distal(3); %m*(z-z1) = n*(y-y1)
                %scatter(handles.coronalPlot,theX,theZ,'MarkerEdgeColor',[0 1 1],'LineWidth',3)

                %knowing z, solve for x and y
                theX = ((l*zdif)/n)+Measured.Distal(1); %l*(z-z1) = n*(x-x1)
                theY = ((m*zdif)/n)+Measured.Distal(2); %m*(z-z1) = n*(y-y1)
                scatter(handles.axialPlot,theX,theY,'MarkerEdgeColor',[0 1 1],'LineWidth',3)
            end
            
        end
        
        %drawPlannedCoords
        Planned = getappdata(handles.figure1,'PlannedCoords');
        if ~Planned.Empty
            curPos = [x(XInd) y(YInd) z(ZInd)];
            pt = Planned.Point;
            dis = pdist([pt; curPos]);
            
            if z(ZInd)>=pt(3)
                ctr=Planned.CTRAngle;
                if pt(1)<0
                    ctr=-ctr;
                end
                acpc=Planned.ACPCAngle;
                thisX = x(XInd);
                t0 = (thisX-pt(1))/sind(ctr);
                xpo = thisX;
                ypo = pt(2)+t0*cosd(acpc)*cosd(ctr);
                zpo = pt(3)+t0*sind(acpc)*cosd(ctr);
               % scatter(handles.sagittalPlot,ypo,zpo,'MarkerEdgeColor',[1 1 0],'LineWidth',3)
                thisY = y(YInd);
                tt = (thisY-pt(2))/(cosd(acpc)*cosd(ctr));
                xpo = pt(1)+tt*sind(ctr);
                zpo = pt(3)+tt*sind(acpc)*cosd(ctr);
               % scatter(handles.coronalPlot,xpo,zpo,'MarkerEdgeColor',[1 1 0],'LineWidth',3)
                thisZ = z(ZInd);
                tt2 = (thisZ-pt(3))/(sind(acpc)*cosd(ctr));
                xpo = pt(1)+tt2*sind(ctr);
                ypo = pt(2)+tt2*cosd(acpc)*cosd(ctr);
                scatter(handles.axialPlot,xpo,ypo,'MarkerEdgeColor',[1 1 0],'LineWidth',3)
            end

           % t0 = 1.5+1.5/2;
           % c0_x = xtip+t0*sind(ctr);
           % c0_y = ytip+t0*cosd(acpc)*cosd(ctr);
           % c0_z = ztip+t0*sind(acpc)*cosd(ctr);
            
           fdsa=1+1; 
        end

        %draw red lines
        %sagittal
        DrawRedLines(handles.sagittalPlot,y(YInd),z(ZInd));
        DrawRedLines(handles.coronalPlot,x(XInd),z(ZInd));
        DrawRedLines(handles.axialPlot,x(XInd),y(YInd));

        %colormap(contrast(coronal));
        minC = getappdata(handles.figure1,'ColorMin');
        maxC = getappdata(handles.figure1,'ColorMax');
        rangeC = [minC-0.001 maxC+0.001]*max(Nifti.img(:));
        colormap(handles.sagittalPlot,'gray');
        colormap(handles.coronalPlot,'gray');
        colormap(handles.axialPlot,'gray');
        caxis(handles.sagittalPlot,rangeC);
        caxis(handles.coronalPlot,rangeC);
        caxis(handles.axialPlot,rangeC);

        CheckMouseOverPlots(handles);
        
        structures = {'AC',   'CM',   'GPe',  'GPi', 'OT',   'Ru', 'SNr',  'STN','Str','Thal',  'Vc',   'Vim',  'Voa', 'Vop', 'ZI'};
        colors =     {'black','green','green','red','yellow','red','black','red','blue','green','green','green','green','green','black'};
        
        atlases = getappdata(handles.figure1,'atlases');
        MRIcenterDimensions = getappdata(handles.figure1,'MRIcenterDimensions');
        MRIcenterDimensions(1) = x(XInd);
        MRIcenterDimensions(2) = y(YInd);
        MRIcenterDimensions(3) = z(ZInd);
        atlasThreshold = getappdata(handles.figure1,'atlasThreshold');
        for n = 1:length(atlases)
            obj = handles.([structures{n} 'Checkbox']);
            if obj.Value==1
                [~,sliceIndex] = min(abs(MRIcenterDimensions(1) - atlases(n).XRange));
                BW = bwboundaries(squeeze(atlases(n).img(sliceIndex,:,:)) > atlasThreshold);
                for k = 1:length(BW)
                    plot(handles.sagittalPlot, atlases(n).YRange(BW{k}(:,1)),atlases(n).ZRange(BW{k}(:,2)),colors{n},'linewidth',2,'Tag','Atlas');
                end

                [~,sliceIndex] = min(abs(MRIcenterDimensions(2) - atlases(n).YRange));
                BW = bwboundaries(squeeze(atlases(n).img(:,sliceIndex,:)) > atlasThreshold);
                for k = 1:length(BW)
                    plot(handles.coronalPlot, atlases(n).XRange(BW{k}(:,1)),atlases(n).ZRange(BW{k}(:,2)),colors{n},'linewidth',2,'Tag','Atlas');
                end

                [~,sliceIndex] = min(abs(MRIcenterDimensions(3) - atlases(n).ZRange));
                BW = bwboundaries(atlases(n).img(:,:,sliceIndex) > atlasThreshold);
                for k = 1:length(BW)
                    plot(handles.axialPlot, atlases(n).XRange(BW{k}(:,1)),atlases(n).YRange(BW{k}(:,2)),colors{n},'linewidth',2,'Tag','Atlas');
                end
            end
        
        end
    

        hold(handles.coronalPlot,'off');
        hold(handles.sagittalPlot,'off');
        hold(handles.axialPlot,'off');

        setappdata(handles.figure1,'Updating',false);
    end
 
function DrawRedLines(Plot,x,y)
    line(Plot,[Plot.XLim(1) Plot.XLim(2)],[y y],'Color','red');
    line(Plot,[x x],[Plot.YLim(1) Plot.YLim(2)],'Color','red');
   
%IndName is either 'XInd', 'YInd', or 'ZInd'
function CheckKeyPress(handles,Plot,MousePos,key,IndName)
    if(MouseOverPlot(MousePos,Plot))
       if strcmp(key,'uparrow')
           ind = getappdata(handles.figure1,IndName);
           setappdata(handles.figure1,IndName,ind+1);
           updatePlots(handles);
       elseif strcmp(key,'downarrow')
           ind = getappdata(handles.figure1,IndName);
           setappdata(handles.figure1,IndName,ind-1);
           updatePlots(handles);
       end
    end
 
    
function CheckMouseClickSagittal(MousePos,handles)
    Plot = handles.sagittalPlot;
    if(MouseOverPlot(MousePos,Plot))
        PlotPos = get(handles.sagittalPlot,'currentpoint');
        yind = GetIndexForYPos(handles,PlotPos(1,1)); %x on this plot is Y in image space
        zind = GetIndexForZPos(handles,PlotPos(1,2)); %y on this plot is Z in image space
        setappdata(handles.figure1,'YInd',yind);
        setappdata(handles.figure1,'ZInd',zind);
        updatePlots(handles);
    end
    
function CheckMouseClickCoronal(MousePos,handles)
    Plot = handles.coronalPlot;
    if(MouseOverPlot(MousePos,Plot))
        PlotPos = get(handles.coronalPlot,'currentpoint');
        xind = GetIndexForXPos(handles,PlotPos(1,1)); %x on this plot is X in image space
        zind = GetIndexForZPos(handles,PlotPos(1,2)); %y on this plot is Z in image space
        setappdata(handles.figure1,'XInd',xind);
        setappdata(handles.figure1,'ZInd',zind);
        updatePlots(handles);
    end
    
 function CheckMouseClickAxial(MousePos,handles)
    Plot = handles.axialPlot;
    if(MouseOverPlot(MousePos,Plot))
        PlotPos = get(handles.axialPlot,'currentpoint');
        xind = GetIndexForXPos(handles,PlotPos(1,1)); %x on this plot is X in image space
        yind = GetIndexForYPos(handles,PlotPos(1,2)); %y on this plot is Y in image space
        setappdata(handles.figure1,'XInd',xind);
        setappdata(handles.figure1,'YInd',yind);
        updatePlots(handles);
    end

function Out = MouseOverCoronalPlot(handles)
    Pos = get(handles.figure1,'currentpoint');
    Plot = handles.coronalPlot;
    Out = MouseOverPlot(Pos,Plot);
function Out = MouseOverSagittalPlot(handles)
    Pos = get(handles.figure1,'currentpoint');
    Plot = handles.sagittalPlot;
    Out = MouseOverPlot(Pos,Plot);
function Out = MouseOverAxialPlot(handles)
    Pos = get(handles.figure1,'currentpoint');
    Plot = handles.axialPlot;
    Out = MouseOverPlot(Pos,Plot);
    
function Out = MouseOverPlot(Pos,Plot)
    PlotPos = Plot.Position;
    if(Pos(1) >= PlotPos(1) && Pos(1) <= PlotPos(1) + PlotPos(3) && Pos(2) >= PlotPos(2) && Pos(2) <= PlotPos(2) + PlotPos(4))
        Out = true;
    else
        Out = false;
    end

function CheckMouseOverPlot(MousePos,Plot)
   if(MouseOverPlot(MousePos,Plot))
        PlotSelected(Plot);
   else
        PlotDeselected(Plot); 
   end
    
function PlotSelected(Plot)
     Plot.XColor = 'red';
     Plot.YColor = 'red';
     
function PlotDeselected(Plot)
     Plot.XColor = 'black';
     Plot.YColor = 'black';

function Index = GetIndexForXPos(handles,x)
    x = GetNearestPoint(x);
    Nifti = getappdata(handles.figure1,'MRI');
    histObj = Nifti.original.hdr.hist;   
    xstart = histObj.srow_x(4);
    dx = histObj.srow_x(1);
    Index = round((x - xstart)/dx);
    
function Index = GetIndexForYPos(handles,y)
    y = GetNearestPoint(y);
    Nifti = getappdata(handles.figure1,'MRI');
    histObj = Nifti.original.hdr.hist;   
    ystart = histObj.srow_y(4);
    dy = histObj.srow_y(2);
    Index = round((y - ystart)/dy);
    
function Index = GetIndexForZPos(handles,z)
    z = GetNearestPoint(z);
    Nifti = getappdata(handles.figure1,'MRI');
    histObj = Nifti.original.hdr.hist;   
    zstart = histObj.srow_z(4);
    dz = histObj.srow_z(3);
    Index = round((z - zstart)/dz);

function v = GetNearestPoint(v)
    v = round(v*2)/2;
    
function Out = GetDefaultXLim(handles)
    Nifti = getappdata(handles.figure1,'MRI');
    histObj = Nifti.original.hdr.hist;
    xstart = histObj.srow_x(4);
    dx = histObj.srow_x(1);
    Nx = size(Nifti.img,1);
    x = xstart + (0:Nx-1)*dx;
    Out = [min(x) max(x)];
function Out = GetDefaultYLim(handles)
    Nifti = getappdata(handles.figure1,'MRI');
    histObj = Nifti.original.hdr.hist;
    ystart = histObj.srow_y(4);
    dy = histObj.srow_y(2);
    Ny = size(Nifti.img,2);
    y = ystart + (0:Ny-1)*dy;
    Out = [min(y) max(y)];
function Out = GetDefaultZLim(handles)
    Nifti = getappdata(handles.figure1,'MRI');
    histObj = Nifti.original.hdr.hist;
    zstart = histObj.srow_z(4);
    dz = histObj.srow_z(3);
    Nz = size(Nifti.img,3);
    z = zstart + (0:Nz-1)*dz;
    Out = [min(z) max(z)];
function Out = GetDefaultLim(handles)   
    X = GetDefaultXLim(handles);
    Y = GetDefaultYLim(handles);
    Z = GetDefaultZLim(handles);
    MinVal = min([X(1) Y(1) Z(1)]);
    MaxVal = max([X(2) Y(2) Z(2)]);
    Out = [MinVal MaxVal];
    
function varargout = BovaAtlasFitter_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


function colorMinSlider_Callback(hObject, eventdata, handles)
    if hObject.Value >= getappdata(handles.figure1,'ColorMax')
            handles.invalidColorText.String = 'Invalid. Minimum value must be less than maximum value.';        
    else
        handles.invalidColorText.String = '';
        setappdata(handles.figure1,'ColorMin',hObject.Value);
        updatePlots(handles);
    end

function colorMinSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function colorMaxSlider_Callback(hObject, eventdata, handles)
    if hObject.Value <= getappdata(handles.figure1,'ColorMin')
        handles.invalidColorText.String = 'Invalid. Minimum value must be less than maximum value.';    
    else
        handles.invalidColorText.String = '';
        setappdata(handles.figure1,'ColorMax',hObject.Value);
        updatePlots(handles);
    end
    
function colorMaxSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function xRotateTextbox_Callback(hObject, eventdata, handles)
    TransformAtlas(handles);
    updatePlots(handles);


function xRotateTextbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit3_Callback(hObject, eventdata, handles)
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yRotateTextbox_Callback(hObject, eventdata, handles)
    TransformAtlas(handles);
    updatePlots(handles);

function yRotateTextbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zRotateTextbox_Callback(hObject, eventdata, handles)
    TransformAtlas(handles);    
    updatePlots(handles);

function zRotateTextbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xScaleTextbox_Callback(hObject, eventdata, handles)
    TransformAtlas(handles);
    updatePlots(handles);

function xScaleTextbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yScaleTextbox_Callback(hObject, eventdata, handles)
    TransformAtlas(handles);
    updatePlots(handles);

function yScaleTextbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zScaleTextbox_Callback(hObject, eventdata, handles)
    TransformAtlas(handles);
    updatePlots(handles);

function zScaleTextbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xTranslateTextbox_Callback(hObject, eventdata, handles)
    TransformAtlas(handles);
    updatePlots(handles);
    
function xTranslateTextbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yTranslateTextbox_Callback(hObject, eventdata, handles)
    TransformAtlas(handles);
    updatePlots(handles);

function yTranslateTextbox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zTranslateTextbox_Callback(hObject, eventdata, handles)
    TransformAtlas(handles);
    updatePlots(handles);

function zTranslateTextbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fillTransformationTextboxesWithCons(handles,Cons)   
    handles.xRotateTextbox.String = Cons.rotation(1);
    handles.yRotateTextbox.String = Cons.rotation(2);
    handles.zRotateTextbox.String = Cons.rotation(3);
    handles.xScaleTextbox.String = Cons.scale(1);
    handles.yScaleTextbox.String = Cons.scale(2);
    handles.zScaleTextbox.String = Cons.scale(3);
    handles.xTranslateTextbox.String = Cons.translation(1);
    handles.yTranslateTextbox.String = Cons.translation(2);
    handles.zTranslateTextbox.String = Cons.translation(3);    
    TransformAtlas(handles);
    updatePlots(handles);

function ACCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function CMCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function GPeCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function GPiCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function OTCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function RuCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function SNrCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function STNCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function StrCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function ThalCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function VcCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function VimCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function VoaCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function VopCheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
function ZICheckbox_Callback(hObject, eventdata, handles)
    updatePlots(handles);
    
function selectExistingTransformationButton_Callback(hObject, eventdata, handles)
    
    %when we load from the DBSArch fmrisaveddata.mat structure, fill the
    %textboxes directly in with the values, and then when we call the function fillTransformationTextboxesWithCons
    %that function calls TransformAtlas which will then negate the
    %appropriate values if we are on the right side of the brain
    
    out = uigetdir('\\gunduz-lab.bme.ufl.edu\Data\DBSArch\','Select Patient Folder');    
    tr = fullfile(out,'fmrisavedata.mat');
    if exist(tr,'file')
       M = load(tr); 
       M = M.savestruct;
       if handles.leftCheckbox.Value == 1
           consL = getLeftCons(M);
           if consL.empty
               consR = getRightCons(M);
               if ~consR.empty
                    handles.existingTransformationText.String = 'Found right, but not left';
               end
           else
               handles.existingTransformationText.String = 'Loaded transformation';
               fillTransformationTextboxesWithCons(handles,consL);
           end
               
       elseif handles.rightCheckbox.Value == 1
           consR = getRightCons(M);
           if consR.empty
               consL = getLeftCons(M);
               if ~consL.empty
                    handles.existingTransformationText.String = 'Found left, but not right';
               end
           else
               handles.existingTransformationText.String = 'Loaded tranformation.';
               fillTransformationTextboxesWithCons(handles,consR);
           end
       end
    end

function selectBOVAFitMorph_Callback(hObject, eventdata, handles)
    [one,two] = uigetfile('./BOVAFit*');
    Co = load(fullfile(two,one));
    if ~isequal(one,0)
        
        handles.existingTransformationText.String = one(9:end); %file should be called BOVAFit_X where X is custom name, so chop of the BOVAFit part
        handles.existingTransformationText.ForegroundColor = [0 0 0]; %change color to black

        if handles.rightCheckbox.Value == 1

            Cons.rotation = Co.Right.Rotation;
            Cons.translation = Co.Right.Translation;
            Cons.scale = Co.Right.Scale;

            %if we are on the right side, then negate the actual values that are
            %stored in BOVAFit for display purposes, but then when the
            %TransformAtlas function is called down below then the values will get
            %re-negated back to their original, actual, values that are loaded here
            Cons.translation = UpdateTranslationBasedOnLaterality(handles,Cons.translation);
            Cons.rotation = UpdateRotationBasedOnLaterality(handles,Cons.rotation);

        elseif handles.leftCheckbox.Value == 1
            Cons.rotation = Co.Left.Rotation;
            Cons.translation = Co.Left.Translation;
            Cons.scale = Co.Left.Scale;
        end


        handles.xRotateTextbox.String = Cons.rotation(1);
        handles.yRotateTextbox.String = Cons.rotation(2);
        handles.zRotateTextbox.String = Cons.rotation(3);
        handles.xScaleTextbox.String = Cons.scale(1);
        handles.yScaleTextbox.String = Cons.scale(2);
        handles.zScaleTextbox.String = Cons.scale(3);
        handles.xTranslateTextbox.String = Cons.translation(1);
        handles.yTranslateTextbox.String = Cons.translation(2);
        handles.zTranslateTextbox.String = Cons.translation(3);    
        TransformAtlas(handles);
        updatePlots(handles);
    end
    
    
function Out = getLeftCons(M)
    if isfield(M,'scaleleft') && isfield(M,'mvmtleft') && isfield(M,'rotationleft')
        Out.scale = M.scaleleft;
        Out.scale = [Out.scale(2) Out.scale(1) Out.scale(3)];
        Out.translation = M.mvmtleft;
        Out.translation = [Out.translation(2) Out.translation(1) Out.translation(3)];
        Out.rotation = M.rotationleft;
        Out.rotation = [Out.rotation(2) Out.rotation(1) Out.rotation(3)];
    else
       Out = getEmptyTransformation();
    end
    
    if isEmptyTransformation(Out)
        Out.empty = true;
    else
        Out.empty = false;
    end
function Out = getRightCons(M)
    if isfield(M,'scaleright') && isfield(M,'mvmtright') && isfield(M,'rotationright')
        Out.scale = M.scaleright;
        Out.scale = [Out.scale(2) Out.scale(1) Out.scale(3)];
        Out.translation = M.mvmtright;
        Out.translation = [Out.translation(2) Out.translation(1) Out.translation(3)];
        Out.rotation = M.rotationright;
        Out.rotation = [Out.rotation(2) Out.rotation(1) Out.rotation(3)];
    else
       Out = getEmptyTransformation();
    end
    
    if isEmptyTransformation(Out)
        Out.empty = true;
    else
        Out.empty = false;
    end
function Out = isEmptyTransformation(In)
    Out = In.scale(1)==1 && In.scale(2)==1 && In.scale(3)==1 && ...
          In.translation(1)==0 && In.translation(2)==0 && In.translation(3)==0 &&  ...
          In.rotation(1)==0 && In.rotation(2)==0 && In.rotation(3)==0;
function Out = getEmptyTransformation()
    Out.scale = [1 1 1];
    Out.translation = [0 0 0];
    Out.rotation = [0 0 0];
    
function leftCheckbox_Callback(hObject, eventdata, handles)
    
    if handles.leftCheckbox.Value==1 && strcmp(getappdata(handles.figure1,'Side'),'R')
        handles.existingTransformationText.String = '...';
    end
    
    setappdata(handles.figure1,'Side','L');
    atlasDir = [getappdata(handles.figure1,'NeuroVisPath'),filesep,'atlasModels',filesep,'UF Anatomical Models',filesep,'lh']; %'\\gunduz-lab.bme.ufl.edu\Data\BOVA_Atlas\lh';
    allAtlas = dir([atlasDir,filesep,'*.nii']);
    disp('Loading atlas...')
    for n = 1:length(allAtlas)
        atlases(n) = loadNifTi([atlasDir,filesep,allAtlas(n).name]);
    end
    setappdata(handles.figure1,'atlases',atlases);
    setappdata(handles.figure1,'originalAtlases',atlases);
    setappdata(handles.figure1,'atlasThreshold',0.4);

    updatePlots(handles);
    handles.leftCheckbox.Value = 1;
    handles.rightCheckbox.Value = 0;
    guidata(hObject, handles);
    
function rightCheckbox_Callback(hObject, eventdata, handles)
    
    if handles.rightCheckbox.Value==1 && strcmp(getappdata(handles.figure1,'Side'),'L')
        handles.existingTransformationText.String = '...';
    end
    
    setappdata(handles.figure1,'Side','R');
    atlasDir = [getappdata(handles.figure1,'NeuroVisPath'),filesep,'atlasModels',filesep,'UF Anatomical Models',filesep,'rh'];%'\\gunduz-lab.bme.ufl.edu\Data\BOVA_Atlas\rh';
    allAtlas = dir([atlasDir,filesep,'*.nii']);
    disp('Loading atlas...')
    for n = 1:length(allAtlas) %
        atlases(n) = loadNifTi([atlasDir,filesep,allAtlas(n).name]);
    end
    setappdata(handles.figure1,'atlases',atlases);
    setappdata(handles.figure1,'originalAtlases',atlases);
    setappdata(handles.figure1,'atlasThreshold',0.4);

    updatePlots(handles);
    handles.leftCheckbox.Value = 0;
    handles.rightCheckbox.Value = 1;
    guidata(hObject, handles);

function loadPatientFolderButton_Callback(hObject, eventdata, handles)
Patient_DIR = uigetdir('','Please select the subject Folder');
if isnumeric(Patient_DIR) 
    error('No folder selected');
else
    %try to find the AC-PC MRI
    attempt = [Patient_DIR filesep 'Processed' filesep 'anat_t1_acpc.nii'];
    if exist(attempt,'file')
        [~,name] = fileparts(Patient_DIR);
        handles.patientFolderText.String = name;
        handles.patientFolderText.ForegroundColor = [0 0 0];
        handles.mriText.String = 'anat_t1_acpc.nii';
        handles.mriText.ForegroundColor = [0 0 0];
        InitNiftiFromPath(handles,attempt);
        updatePlots(handles);
    end
end

function loadImage_Callback(hObject, eventdata, handles)
[ImageName,Path] = uigetfile([getappdata(handles.figure1,'ProcessedDir') filesep '*.nii']);
handles.mriText.String = ImageName;
InitNiftiFromPath(handles,fullfile(Path,ImageName));
updatePlots(handles);




% --- Executes on button press in addPlannedLeadButton.
function addPlannedLeadButton_Callback(hObject, eventdata, handles)
    
    [name,path] = uigetfile('\\gunduz-lab.bme.ufl.edu\Data\DBSArch\*.crw','Select CRW file');
    CRW = loadCRW(fullfile(path,name));
    checkShouldSaveCRW(getappdata(handles.figure1,'ProcessedDir'),CRW);
    setappdata(handles.figure1,'PlannedCoords',CRW.FuncTarget);
    updateLeadPlannedPopup(handles);
        %eventually should save it to processed directory
    %Processed_DIR = getappdata(handles.figure1,'ProcessedDir');
    %[Proximal,Distal] = getContactPositionsFromUFCoords(CRW.Point, CRW.ACPCAngle, CRW.CTRAngle);
        updatePlots(handles);

    
    
    


% --- Executes on button press in addMeasuredLead.
function addMeasuredLead_Callback(hObject, eventdata, handles)
% hObject    handle to addMeasuredLead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in plannedPopup.
function plannedPopup_Callback(hObject, eventdata, handles)
% hObject    handle to plannedPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plannedPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plannedPopup
CRW = open(fullfile(getappdata(handles.figure1,'ProcessedDir'),handles.plannedPopup.String{handles.plannedPopup.Value}));
setappdata(handles.figure1,'PlannedCoords',CRW.FuncTarget);
updatePlots(handles);



% --- Executes during object creation, after setting all properties.
function plannedPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plannedPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function measuredPopup_Callback(hObject, eventdata, handles)
    LEAD = open(fullfile(getappdata(handles.figure1,'ProcessedDir'),handles.measuredPopup.String{handles.measuredPopup.Value}));
    LEAD.Empty = 0;
    setappdata(handles.figure1,'MeasuredCoords',LEAD);
    updatePlots(handles);

function measuredPopup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveAsButton.
function saveAsButton_Callback(hObject, eventdata, handles)
    Rotation = [str2num(handles.xRotateTextbox.String),str2num(handles.yRotateTextbox.String),str2num(handles.zRotateTextbox.String)];
    Translation = [str2num(handles.xTranslateTextbox.String),str2num(handles.yTranslateTextbox.String),str2num(handles.zTranslateTextbox.String)];
    Scale = [str2num(handles.xScaleTextbox.String),str2num(handles.yScaleTextbox.String),str2num(handles.zScaleTextbox.String)];
    
    prompt = {'Enter name of BOVAFit (e.g., myFit)'};
    title = 'Name';
    definput = {'myFit'};
    answer = inputdlg(prompt,title,[1 40],definput);
    
    name = fullfile([getappdata(handles.figure1,'ProcessedDir'),filesep,'BOVAFit_',answer{1},'.mat']);
    if exist(name,'file')
        M = load(name);
        if handles.leftCheckbox.Value == 1 && isfield(M,'Left')
            option1 = 'Override';
            option2 = 'Cancel';
            answer = questdlg('There is already a BOVAFit with that name with left morph values.',...
                      'Please Respond',...
                      option1,option2,option2);
            switch answer
                case option1
                   Left.Rotation = Rotation;
                   Left.Translation = Translation;
                   Left.Scale = Scale;
                   if isfield(M,'Right')
                       Right = M.Right;
                       save(name,'Left','Right');
                   else
                    save(name,'Left');
                   end
                   msgbox('Saved the Left side');
                case option2
                    return;
            end
        elseif handles.leftCheckbox.Value == 1 && isfield(M,'Right') && ~isfield(M,'Left')
            Left.Rotation = Rotation;
            Left.Translation = Translation;
            Left.Scale = Scale;
            Right = M.Right;
            save(name,'Left','Right');
            msgbox('Saved the Left side');
        elseif handles.rightCheckbox.Value == 1 && isfield(M,'Right')
            option1 = 'Override';
            option2 = 'Cancel';
            answer = questdlg('There is already a BOVAFit with that name with right morph values.',...
                      'Please Respond',...
                      option1,option2,option2);
            switch answer
                case option1
                   Right.Rotation = UpdateRotationBasedOnLaterality(handles,Rotation);
                   Right.Translation = UpdateTranslationBasedOnLaterality(handles,Translation);
                   Right.Scale = Scale;
                   if isfield(M,'Left')
                       Left = M.Left;
                       save(name,'Left','Right');
                   else
                    save(name,'Right');
                   end
                   msgbox('Saved the Right side');
                case option2
                    return;
            end    
        elseif handles.rightCheckbox.Value == 1 && isfield(M,'Left') && ~isfield(M,'Right')
            Right.Rotation = UpdateRotationBasedOnLaterality(handles,Rotation);
            Right.Translation = UpdateTranslationBasedOnLaterality(handles,Translation);
            Right.Scale = Scale;
            Left = M.Left;
            save(name,'Left','Right');
            msgbox('Saved the Right side');
        end
    else
        
        if handles.leftCheckbox.Value == 1
           Left.Rotation = Rotation;
           Left.Translation = Translation;
           Left.Scale = Scale;
           save(name,'Left');
           msgbox('Saved the Left side');
        elseif handles.rightCheckbox.Value == 1
            %if right side selected, update to the actual values before
            %saving by negating the proper values
            Right.Rotation = UpdateRotationBasedOnLaterality(handles,Rotation);
            Right.Translation = UpdateTranslationBasedOnLaterality(handles,Translation);
            Right.Scale = Scale;
            save(name,'Right');
            msgbox('Saved the right side');
        end

    end
    
function toggleAllButton_Callback(hObject, eventdata, handles)
    structures = {'AC','CM','GPe','GPi','OT','Ru','SNr','STN','Str','Thal','Vc','Vim','Voa','Vop','ZI'};
    for i=1:length(structures)
        handles.([structures{i} 'Checkbox']).Value = ~handles.([structures{i} 'Checkbox']).Value;
    end
    updatePlots(handles);
