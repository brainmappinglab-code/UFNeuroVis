function plotLeadModel(leadName)
%% plotLeadModel(leadName)
%
%  Given the name of the file containing the lead model, this function will plot the lead
%  freestanding, with the tip of the lead at coordinates (0, 0, 1).
%
%   Created by: Brandon Parks
%

figure;
    
ee = load([getenv('NEURO_VIS_PATH'),filesep,'leadModels',filesep,leadName,'.mat']);
electrode = ee.electrode;

leadInfo.Type = leadName;
leadInfo.Distal = [electrode.head_position(1),electrode.head_position(2)+0.01,electrode.head_position(3)+1];
leadInfo.Proximal = [electrode.tail_position(1),electrode.tail_position(2)+0.01,electrode.tail_position(3)+1];

[ elfv, modelType ] = constructElectrode(leadInfo);

for section = 1:length(elfv)
    if strcmp(modelType(section),'contacts')
        patch(elfv(section),'FaceColor',[0.9 0.9 0.9],'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
    else
        patch(elfv(section),'FaceColor',[0.3 0.3 0.3],'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
    end
end

axis([-5 5 -5 5 -10 electrode.tail_position(3) + 25]);
% view(-37.5,30);