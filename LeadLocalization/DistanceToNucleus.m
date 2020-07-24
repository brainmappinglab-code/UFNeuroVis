UFNeuroVis_setEnv;

[filename, pathname] = uigetfile('BOVA_*.mat');
ElectrodeInformation = load([pathname,filesep,filename]);

ElectrodeContacts = zeros(4,3);
for n = 1:3
    ElectrodeContacts(:,n) = linspace(ElectrodeInformation.Distal(1,n), ElectrodeInformation.Proximal(1,n), 4);
end

NifTi_Folder = [NEURO_VIS_PATH,filesep,'atlasModels\UF Anatomical Models'];
AllStructure = load([NifTi_Folder,filesep,'UF Anatomical Models_STL.mat']);
if ElectrodeInformation.Distal(1) < 0
    AtlasNuclei = AllStructure.AtlasSTL.Left;
else
    AtlasNuclei = AllStructure.AtlasSTL.Right;
end

DistanceToNucleus = zeros(4,length(AtlasNuclei));
fprintf('===========================================\n');
for contact = 1:4
    for n = 1:length(AtlasNuclei)
        DistanceToNucleus(contact,n) = min(rssq(bsxfun(@minus, AtlasNuclei(n).vertices, ElectrodeContacts(contact,:)),2));
    end
    [distance,index] = min(DistanceToNucleus(contact,:));
    fprintf('The closest nucleus to Contact E%.2d is %s with a distance of %.2f mm\n',contact,AllStructure.AtlasInfo.Left(index).name,distance);
end
fprintf('===========================================\n');
