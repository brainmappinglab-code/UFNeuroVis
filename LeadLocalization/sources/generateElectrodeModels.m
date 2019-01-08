%% sEEG Definitions
nContacts = 8;
electrodeName = sprintf('UF_sEEG_%d',nContacts);
metalContactsDistance = 2;
insulationDistance = 1.5;
electrodeRadius = 0.4;

%% Surface Generation

[x,y,z] = cylinder(electrodeRadius,50);

metalContact(1) = surf2patch(x, y, z * metalContactsDistance * 0.65);
insulation(1) = surf2patch(x, y, metalContactsDistance * 0.65 + z * insulationDistance);
initialHeight = metalContactsDistance * 0.65 + insulationDistance;

for n = 2:nContacts
    heightDisplacement = (n - 2) * (insulationDistance + metalContactsDistance) + initialHeight;
    metalContact(n) = surf2patch(x, y, heightDisplacement + z * metalContactsDistance);
    patch(x, y, heightDisplacement + z * metalContactsDistance);
    if n == nContacts
        insulation(n) = surf2patch(x, y, metalContactsDistance + heightDisplacement + z * 20);
        patch(x, y, metalContactsDistance + heightDisplacement + z * 20);
    else
        insulation(n) = surf2patch(x, y, metalContactsDistance + heightDisplacement + z * insulationDistance);
        patch(x, y, metalContactsDistance + heightDisplacement + z * insulationDistance);
    end
end

figure(1); clf;
[x2,y2,z2] = sphere(50);
dome = surf2patch(x2 * electrodeRadius ,y2 * electrodeRadius ,z2 * 0.3);

patch(dome);
%axis([-10 10 -10 10 -10 heightDisplacement + 55]);
% view(-37.5,30);

%% Store Information (as in LeadDBS Models)

clear electrode;

electrode.contacts(1).faces = cat(1,metalContact(1).faces,dome.faces);
electrode.contacts(1).vertices = cat(1,metalContact(1).vertices,dome.vertices);

for n = 2:length(metalContact)
    electrode.contacts(n).faces = metalContact(n).faces;
    electrode.contacts(n).vertices = metalContact(n).vertices;
    electrode.coords_mm(n,1:3) = [0,0,mean(metalContact(n).vertices(:,3))];
end

for n = 1:length(insulation)
    electrode.insulation(n).faces = insulation(n).faces;
    electrode.insulation(n).vertices = insulation(n).vertices;
end

electrode.electrode_model = electrodeName;
electrode.numel = nContacts;
electrode.contact_color = 0.3;
electrode.lead_color = 0.7;
electrode.head_position = electrode.coords_mm(1,:);
electrode.tail_position = electrode.coords_mm(end,:);
electrode.x_position = electrode.coords_mm(1,:) + [electrodeRadius,0,0];
electrode.y_position = electrode.coords_mm(1,:) + [0,electrodeRadius,0];

save(electrodeName,'electrode');

%% Visualize the Model 

plotLeadModel(electrodeName);

% figure();
% clear elfv modelType
% 
% count = 1;
% for n = 1:length(electrode.contacts)
%     electrode.contacts(n).vertices = [electrode.contacts(n).vertices,ones(size(electrode.contacts(n).vertices,1),1)]';
%     electrode.contacts(n).vertices = electrode.contacts(n).vertices(1:3,:)';
%     
%     elfv(count).faces = electrode.contacts(n).faces;
%     elfv(count).vertices = electrode.contacts(n).vertices;
%     modelType{count} = 'contacts';
%     count = count + 1;
% end
% 
% for n = 1:length(electrode.insulation)
%     electrode.insulation(n).vertices = [electrode.insulation(n).vertices,ones(size(electrode.insulation(n).vertices,1),1)]';
%     electrode.insulation(n).vertices = electrode.insulation(n).vertices(1:3,:)';
%     
%     elfv(count).faces = electrode.insulation(n).faces;
%     elfv(count).vertices = electrode.insulation(n).vertices;
%     modelType{count} = 'insulation';
%     count = count + 1;
% end
% 
% insulationIndex = 0;
% for section = 1:length(modelType)
%     if strcmpi(modelType(section),'contacts')
%         patch(elfv(section),'FaceColor',[0,0,0],'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
%         contactIndex = section;
%     elseif strcmpi(modelType(section),'insulation')
%         insulationIndex = insulationIndex + 1;
%         patch(elfv(section),'FaceColor',[0.8 0.8 0.8],'EdgeColor','None','FaceLighting','Gouraud','AmbientStrength', 0.2);
%     end
% end
% 
% axis([-5 5 -5 5 -10 heightDisplacement + 55]);
% view(-37.5,30);
