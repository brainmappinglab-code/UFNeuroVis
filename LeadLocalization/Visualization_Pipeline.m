clc; close all; clear all;

%% set the environment
UFNeuroVis_setEnv;

%teee
%% Step 0: Setups
Patient_DIR = uigetdir('','Please select the subject Folder');
if isnumeric(Patient_DIR) 
    error('No folder selected');
else
    DICOM_Directory = dir([Patient_DIR,filesep,'DICOMDIR']);
    if isempty(DICOM_Directory)
        error('Incorrect Patient Directory');
    end
end
fprintf('Change directory to patient directory...');
cd(Patient_DIR);
fprintf('Done\n\n');

MRIFILTERED = false;
CTFILTERED = false;
TRANSFORMED = false;
COREGISTERED = false;

NifTi_DIR = [Patient_DIR,filesep,'NiiX'];
Processed_DIR = [Patient_DIR,filesep,'Processed'];

%% GET BOVA TRANSFORM

BovaFits = dir([Processed_DIR,filesep,'BOVAFit_*']);
if isempty(BovaFits)
    option1 = 'Select patient folder from UF';
    option2 = 'Cancel';
    answer = questdlg('No BOVAFits located for this patient. What would you like to do?',...
                      'Please Respond',...
                      option1,option2,option2);
    switch answer
        case option1
            Patient_BOVA_DIR = uigetdir('\\gunduz-lab.bme.ufl.edu\Data\DBSArch','Please select the subject Folder');
            if isnumeric(Patient_BOVA_DIR) 
                error('No folder selected');
            else
                FMRISAVEDATA = dir([Patient_BOVA_DIR,filesep,'fmrisavedata.mat']);
                if isempty(FMRISAVEDATA)
                    error('Cannot find BOVA Transform Data');
                end
            end

            FMRISAVEDATA = load([Patient_BOVA_DIR,filesep,'fmrisavedata.mat']);
            m = matfile([Processed_DIR,filesep,'BOVAFit_PatientFolder.mat'], 'Writable', true);
            if isfield(FMRISAVEDATA.savestruct,'rotationleft')
                Left.Rotation = FMRISAVEDATA.savestruct.rotationleft;
                Left.Translation = FMRISAVEDATA.savestruct.mvmtleft;
                Left.Scale = FMRISAVEDATA.savestruct.scaleleft;
                m.Left = Left;
            end
            if isfield(FMRISAVEDATA.savestruct,'rotationright')
                Right.Rotation = FMRISAVEDATA.savestruct.rotationright;
                Right.Translation = FMRISAVEDATA.savestruct.mvmtright;
                Right.Scale = FMRISAVEDATA.savestruct.scaleright;
                
                %if we chose from patient folder, we need to adjust the
                %values for the right side: flip the x for translation and
                %the rotation for y before saving the data to BOVAFit
                Right.Translation(1) = Right.Translation(1)*-1;
                Right.Rotation(2) = Right.Rotation(2)*-1;
                
                m.Right = Right;
            end
            clear Left Right;

            BovaTransform = load([Processed_DIR,filesep,'BOVAFit_PatientFolder.mat']);

            % Transform Left Lead if Left Atlas Morph Exist
            if isfield(BovaTransform,'Left')
                leftLeads = dir([Processed_DIR,filesep,'Left*']);
                for n = 1:length(leftLeads)
                    leadInfo = load([Processed_DIR,filesep,leftLeads(n).name]);
                    T = computeTransformMatrix(BovaTransform.Left.Translation,BovaTransform.Left.Scale,BovaTransform.Left.Rotation);
                    m = matfile([Processed_DIR,filesep,'BOVA_',leftLeads(n).name],'Writable',true);
                    m.Side = leadInfo.Side;
                    m.Type = leadInfo.Type;
                    m.nContacts = leadInfo.nContacts;
                    newDistal = [leadInfo.Distal, 1] / T;
                    m.Distal = newDistal(1:3);
                    newProximal = [leadInfo.Proximal, 1] / T;
                    m.Proximal = newProximal(1:3);
                end
            end

            % Transform Right Lead if Right Atlas Morph Exist
            if isfield(BovaTransform,'Right')
                rightLeads = dir([Processed_DIR,filesep,'Right*']);
                for n = 1:length(rightLeads)
                    leadInfo = load([Processed_DIR,filesep,rightLeads(n).name]);
                    T = computeTransformMatrix(BovaTransform.Right.Translation,BovaTransform.Right.Scale,BovaTransform.Right.Rotation);
                    m = matfile([Processed_DIR,filesep,'BOVA_',rightLeads(n).name],'Writable',true);
                    m.Side = leadInfo.Side;
                    m.Type = leadInfo.Type;
                    m.nContacts = leadInfo.nContacts;
                    newDistal = [leadInfo.Distal, 1] / T;
                    m.Distal = newDistal(1:3);
                    newProximal = [leadInfo.Proximal, 1] / T;
                    m.Proximal = newProximal(1:3);
                end
            end
            
            BOVATransformation = load([Processed_Dir,filesep,'BOVAFit_PatientFolder.mat']);
            BOVATransformationName = 'PatientFolder';

        case option2
            return;
    end
else
    %then we have BOVAFits to use
    ToUse = BovaFits(1); %just grab the first one for now
    BOVATransformation = load([ToUse.folder,filesep,ToUse.name]);
    
    %find name of bova transformation coming after BOVAFit_
    UnderscoreInd = find(ToUse.name=='_');
    PeriodInd = find(ToUse.name=='.');
    BOVATransformationName = ToUse.name((UnderscoreInd+1):(PeriodInd-1));
    
    disp(['Loaded BOVAFit: ',ToUse.name]);
end

%% Setup
MetalLead = [0.7 0.7 0.7];
InsulationColor = [1,0,0];
PlotLead = false;

if ~PlotLead
    MetalLead = InsulationColor;
end

% Get Subject Directory
%if ~exist([subDir,filesep,'Processed',filesep,'anat_t1_acpc.nii'],'file')
 %   error('Cannot find ACPC, did you complete MRI_Pipeline?');
%end

%Chauncey Wissam patient
%BOVATransformation.Left.Translation = [-4 -2 0];
%BOVATransformation.Left.Scale = [1 0.95 0.98];
%BOVATransformation.Left.Rotation = deg2rad([6 6 -3]);
%BOVATransformation.Right.Translation = [-2 1 4];
%BOVATransformation.Right.Scale = [1 0.95 0.98];
%BOVATransformation.Right.Rotation = deg2rad([8 -2 -1]);

%Ramirez ZI patient
%BOVATransformation.Left.Translation = [-1.25 -1.5 2];
%BOVATransformation.Left.Scale = [0.94 0.93 0.9];
%BOVATransformation.Left.Rotation = deg2rad([9.5 2 -1]);
%BOVATransformation.Right.Translation = [-1 1 0.5];
%BOVATransformation.Right.Scale = [0.94 0.93 0.9];
%BOVATransformation.Right.Rotation = deg2rad([7.5 5 -2]);

% Load ACPC Brain
preop_T1_acpc = loadNifTi([Processed_DIR,filesep,'anat_t1_acpc.nii']);

%% Choose Atlas
%atlasDir = uigetdir('\\gunduz-lab.bme.ufl.edu\Data\','Please Select the atlas directory for visualization');
atlasDir = [NEURO_VIS_PATH,filesep,'atlasModels',filesep,'UF Anatomical Models']; 
[atlasDir,atlasName] = fileparts(atlasDir);
if ~exist([Processed_DIR,filesep,atlasName,'_STL_',BOVATransformationName,'.mat'],'file')
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
    save([Processed_DIR,filesep,atlasName,'_STL_',BOVATransformationName,'.mat'],'AtlasSTL','AtlasInfo');
end

load([Processed_DIR,filesep,atlasName,'_STL_',BOVATransformationName,'.mat'],'AtlasSTL','AtlasInfo');

%% Visualization
% Setup Figure
h = largeFigure(100,[1280 900]); clf; set(h,'Color','k');
handles = anatomical3DVisualizer(h, preop_T1_acpc);

if isfield(AtlasInfo,'Left')
    % Add to View Area
    AtlasInfo.LeftCMAP = hsv(length(AtlasSTL.Left));
    for n = 1:length(AtlasSTL.Left)
        AtlasSTL.Left(n) = reducepatch(AtlasSTL.Left(n), 200);
        AtlasPatch.Left(n) = patch(AtlasSTL.Left(n), 'FaceColor', AtlasInfo.LeftCMAP(n,:), 'EdgeColor', 'None', 'FaceAlpha', 0.5, 'FaceLighting','phong');
    end
end

if isfield(AtlasInfo,'Right')
    AtlasInfo.RightCMAP = hsv(length(AtlasSTL.Right));
    for n = 1:length(AtlasSTL.Right)
        AtlasSTL.Right(n) = reducepatch(AtlasSTL.Right(n), 200);
        AtlasPatch.Right(n) = patch(AtlasSTL.Right(n), 'FaceColor', AtlasInfo.RightCMAP(n,:), 'EdgeColor', 'None', 'FaceAlpha', 0.5, 'FaceLighting','phong');
    end
end

AtlasController(AtlasInfo, AtlasPatch);

% View Left Leads
leftLeads = dir([Processed_DIR,filesep,'LEAD_Left*']);
for n = 1:length(leftLeads)
    leadInfo = load([Processed_DIR,filesep,leftLeads(n).name]);
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
rightLeads = dir([Processed_DIR,filesep,'LEAD_Right*']);
for n = 1:length(rightLeads)
    leadInfo = load([Processed_DIR,filesep,rightLeads(n).name]);
    [ elfv, modelType ] = constructElectrode( leadInfo );
    for section = 1:length(modelType)
        if strcmpi(modelType(section),'contacts')
            patch(handles.anatomicalView, elfv(section),'FaceColor',MetalLead,'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
        elseif PlotLead
            patch(handles.anatomicalView, elfv(section),'FaceColor',InsulationColor,'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
        end
    end
end

%% OPTIONAL STEP TO VIEW PLANNED LEAD
% NOT USUALLY USED
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
