%group analysis
clc; close all; clear;

%#ok<*SAGROW>

%% set the environment

UFNeuroVis_setEnv;

%% Step 0: Setups

root = uigetdir('','Choose the root path of all images');

if root == 0
    return
end

possibleFolders = dir(root);
possibleFolders([1,2]) = [];

isDir = false(length(possibleFolders),1);
folderNames = cell(length(possibleFolders),1);

for i = 1:length(possibleFolders)
    isDir(i) = possibleFolders(i).isdir;
    folderNames{i} = possibleFolders(i).name;
end

possibleFolders(~isDir) = [];
folderNames(~isDir) = [];

[foldersToUse,OK] = listdlg('ListString',folderNames,'PromptString','Select subject folders',...
    'SelectionMode','multiple','ListSize',[300 400]);

if OK == 0
    return
end

subjs = cell(length(foldersToUse),1);

for i=1:length(foldersToUse)
    subjs{i}=folderNames{foldersToUse(i)};
end

% root = 'C:\Users\jcagle\Documents\VirtualMachine\Imaging';
% subjs = {'ET_CL_04'};%
%subjs = {'TS06'};

%% get all the leads
leads = [];
leadCount = 0;
for i=1:length(subjs)
    
    thisPatientFolder = [root,filesep,subjs{i}];
%     patient.Name = subjs{i};
    
    thisPatientFolderProcessed = [thisPatientFolder,filesep,'Processed'];
    
    leadsR = dir([thisPatientFolderProcessed,filesep,'BOVA_LEAD_Right_*']); %in the future, can also load LEAD_Right to look at non-reverse-transformed
    leadsL = dir([thisPatientFolderProcessed,filesep,'BOVA_LEAD_Left_*']);    
    
    for j=1:length(leadsR)
        leadCount = leadCount + 1;
        leads{leadCount} = load([thisPatientFolderProcessed,filesep,leadsR(j).name]); 
    end
    for j=1:length(leadsL)
        leadCount = leadCount + 1;
        leads{leadCount} = load([thisPatientFolderProcessed,filesep,leadsL(j).name]);
    end
  
    clear patient;
end


%% Visualization

load([NEURO_VIS_PATH,filesep,'atlasModels',filesep,'UF Anatomical Models STL',filesep,'RawAtlas_STL.mat'],'AtlasSTL','AtlasInfo');

% Setup Figure
h = largeFigure(100,[1280 900]); clf; set(h,'Color','k');
set(h, 'Renderer', 'opengl');
axHandles = gca;
axis(axHandles,'off');
axis(axHandles,'vis3d');
view(axHandles,3);
colormap(axHandles, 'gray');
%handles = anatomical3DVisualizer(h, '');

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

MetalLead = [0.7 0.7 0.7];
InsulationColor = [1,0,0];
PlotLead = true;

if ~PlotLead
    MetalLead = InsulationColor;
end

for n = 1:length(leads)
    leadInfo = leads{n};
    [ elfv, modelType ] = constructElectrode( leadInfo );
    for section = 1:length(modelType)
        if strcmpi(modelType(section),'contacts')
            patch(axHandles, elfv(section),'FaceColor',MetalLead,'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
            contactIndex = section;
        elseif PlotLead
            patch(axHandles, elfv(section),'FaceColor',InsulationColor,'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
        end
    end
end
