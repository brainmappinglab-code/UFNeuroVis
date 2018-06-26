function [ elfv, modelType, contactCenter ] = constructElectrode( leadInfo )
%Construct Electrode Face/Vertices for Patient Specific Transform
%   [ elfv ] = constructElectrode( electrode, transformMarker )
%       elfv - Electrode Face/Vertices
%       electrode - struct holding electrode models
%       transformMarker - struct holding center of the contact 0 and
%           contact 3
%
%   J. Cagle, 2018

electrodeInfo = load([getenv('NEURO_VIS_PATH'),filesep,'leadModels',filesep,leadInfo.Type,'.mat']);
electrode = electrodeInfo.electrode;
OriginalCoordinate = [electrode.head_position, 1; 
                      electrode.tail_position, 1;
                      electrode.x_position,    1;
                      electrode.y_position,    1;];

Origin = leadInfo.Distal;
ZDirection = leadInfo.Proximal - leadInfo.Distal;
K = ZDirection/rssq(ZDirection);

temp = ([0,0,0]-Origin)/rssq([0,0,0]-Origin);
I = -cross(K,temp)/rssq(-cross(K,temp));
J = -cross(I,K)/rssq(-cross(I,K));

TemplateCoordinate = [Origin,               1;
                      Origin + ZDirection,  1;
                      Origin + I * electrode.x_position(1),   1;
                      Origin + J * electrode.x_position(1),   1;];
                  
Transformation = mldivide(OriginalCoordinate,TemplateCoordinate)';

count = 1;
for n = 1:length(electrode.contacts)
    electrode.contacts(n).vertices = Transformation * [electrode.contacts(n).vertices,ones(size(electrode.contacts(n).vertices,1),1)]';
    electrode.contacts(n).vertices = electrode.contacts(n).vertices(1:3,:)';
    
    elfv(count).faces = electrode.contacts(n).faces;
    elfv(count).vertices = electrode.contacts(n).vertices;
    modelType{count} = 'contacts';
    count = count + 1;
end

contactCenter = zeros(4,5);
contactCenter(1,1:3) = Origin;
contactCenter(2,1:3) = Origin + ZDirection / 3;
contactCenter(3,1:3) = Origin + ZDirection * 2 / 3;
contactCenter(4,1:3) = Origin + ZDirection;

for n = 1:length(electrode.insulation)
    electrode.insulation(n).vertices = Transformation * [electrode.insulation(n).vertices,ones(size(electrode.insulation(n).vertices,1),1)]';
    electrode.insulation(n).vertices = electrode.insulation(n).vertices(1:3,:)';
    
    elfv(count).faces = electrode.insulation(n).faces;
    elfv(count).vertices = electrode.insulation(n).vertices;
    modelType{count} = 'insulation';
    count = count + 1;
end

end

