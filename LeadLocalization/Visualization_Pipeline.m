%% Setup
MetalLead = [0.7 0.7 0.7];
InsulationColor = [1,0,0];
PlotLead = true;

if ~PlotLead
    MetalLead = InsulationColor;
end

% Get Subject Directory
subDir = uigetdir('','Please Select the subject for visualization');
if ~exist([subDir,filesep,'Processed',filesep,'anat_t1_acpc.nii'],'file') || ~exist([subDir,filesep,'Processed',filesep,'BOVAFit.mat'],'file')
    error('Cannot find ACPC, did you complete MRI_Pipeline?');
end
cd(subDir);

% Import BOVA Atlas Fit
BOVATransformation = load([subDir,filesep,'Processed',filesep,'BOVAFit.mat']);

% Load ACPC Brain
preop_T1_acpc = loadNifTi([subDir,filesep,'Processed',filesep,'anat_t1_acpc.nii']);

%% Choose Atlas
atlasDir = uigetdir('\\gunduz-lab.bme.ufl.edu\Data\','Please Select the atlas directory for visualization');
[atlasDir,atlasName] = fileparts(atlasDir);
if ~exist([subDir,filesep,'Processed',filesep,atlasName,'_STL.mat'],'file')
    if isfield(BOVATransformation,'Left')
        T = computeTransformMatrix(BOVATransformation.Left.Translation,BOVATransformation.Left.Scale,BOVATransformation.Left.Rotation);
        tform = affine3d(T);
        [AtlasSTL.Left, AtlasInfo.Left] = atlas2STL([atlasDir,filesep,atlasName,filesep,'lh'],tform);
    end
    if isfield(BOVATransformation,'Right')
        T = computeTransformMatrix(BOVATransformation.Right.Translation,BOVATransformation.Right.Scale,BOVATransformation.Right.Rotation);
        tform = affine3d(T);
        [AtlasSTL.Right, AtlasInfo.Right] = atlas2STL([atlasDir,filesep,atlasName,filesep,'rh'],tform);
    end
    save([subDir,filesep,'Processed',filesep,atlasName,'_STL.mat'],'AtlasSTL','AtlasInfo');
end

load([subDir,filesep,'Processed',filesep,atlasName,'_STL.mat'],'AtlasSTL','AtlasInfo');

%% Visualization
% Setup Figure
h = largeFigure(100,[1280 900]); clf; set(h,'Color','k');
handles = anatomical3DVisualizer(h, preop_T1_acpc);

% Add to View Area
AtlasInfo.LeftCMAP = hsv(length(AtlasSTL.Left));
for n = 1:length(AtlasSTL.Left)
    AtlasSTL.Left(n) = reducepatch(AtlasSTL.Left(n), 200);
    AtlasPatch.Left(n) = patch(AtlasSTL.Left(n), 'FaceColor', AtlasInfo.LeftCMAP(n,:), 'EdgeColor', 'None', 'FaceAlpha', 0.5, 'FaceLighting','phong');
end

AtlasInfo.RightCMAP = hsv(length(AtlasSTL.Right));
for n = 1:length(AtlasSTL.Right)
    AtlasSTL.Right(n) = reducepatch(AtlasSTL.Right(n), 200);
    AtlasPatch.Right(n) = patch(AtlasSTL.Right(n), 'FaceColor', AtlasInfo.RightCMAP(n,:), 'EdgeColor', 'None', 'FaceAlpha', 0.5, 'FaceLighting','phong');
end
AtlasController(AtlasInfo, AtlasPatch);

% View Left Leads
leftLeads = dir([subDir,filesep,'Processed',filesep,'LEAD_Left*']);
for n = 2:length(leftLeads)
    leadInfo = load([subDir,filesep,'Processed',filesep,leftLeads(n).name]);
    [ elfv, modelType ] = constructElectrode( leadInfo );
    for section = 1:length(modelType)
        if strcmpi(modelType(section),'contacts')
            patch(handles.anatomicalView, elfv(section),'FaceColor',MetalLead,'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
            contactIndex = section;
        elseif PlotLead
            patch(handles.anatomicalView, elfv(section),'FaceColor',InsulationColor,'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
        end
    end
end

% View Right Leads
rightLeads = dir([subDir,filesep,'Processed',filesep,'LEAD_Right*']);
for n = 1:length(rightLeads)
    leadInfo = load([subDir,filesep,'Processed',filesep,rightLeads(n).name]);
    [ elfv, modelType ] = constructElectrode( leadInfo );
    for section = 1:length(modelType)
        if strcmpi(modelType(section),'contacts')
            patch(handles.anatomicalView, elfv(section),'FaceColor',MetalLead,'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
        elseif PlotLead
            patch(handles.anatomicalView, elfv(section),'FaceColor',InsulationColor,'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
        end
    end
end

%% View planned lead
MetalLeadPlan = [0.7 0.7 0.7];
InsulationColorPlan = [0,0,1];

if ~PlotLead
    MetalLeadPlan = InsulationColorPlan;
end

plannedLeads = dir([subDir,filesep,'Processed',filesep,'*_CRW.mat']);
for n = 1:length(plannedLeads)
    lead = load([subDir,filesep,'Processed',filesep,plannedLeads(n).name]);
    targ = lead.FuncTarget.Point;
    acpc = lead.FuncTarget.ACPCAngle;
    ctr = lead.FuncTarget.CTRAngle;
    if targ(1)<0
        ctr=-ctr;
    end
    leadInfo.Type = 'medtronic_3387';
    leadInfo.nContacts = 4;
    
    leadInfo.Distal = [targ(1)+0.75*sind(ctr), targ(2)+0.75*cosd(acpc)*cosd(ctr), targ(3)+0.75*sind(acpc)*cosd(ctr)];
    t2 = 0.75+9;
    leadInfo.Proximal = [targ(1)+t2*sind(ctr), targ(2)+t2*cosd(acpc)*cosd(ctr), targ(3)+t2*sind(acpc)*cosd(ctr)];
    
    
    [ elfv, modelType ] = constructElectrode( leadInfo );
    for section = 1:length(modelType)
        if strcmpi(modelType(section),'contacts')
            patch(handles.anatomicalView, elfv(section),'FaceColor',MetalLeadPlan,'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
        elseif PlotLead
            patch(handles.anatomicalView, elfv(section),'FaceColor',InsulationColorPlan,'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
        end
    end
end
