%% sEEG Definitions
electrodeName = 'UF_sEEG_16';
nContacts = 16;
metalContactsDistance = 2;
insulationDistance = 1.5;
electrodeRadius = 0.4;

%% Surface Generation

[x,y,z] = cylinder(electrodeRadius,50);

metalContact(1) = surf2patch(x, y, z * metalContactsDistance * 0.65);
insulation(1) = surf2patch(x, y, metalContactsDistance * 0.95 + z * metalContactsDistance * 0.05);
for n = 2:nContacts
    heightDisplacement = (n - 1) * (insulationDistance + metalContactsDistance);
    metalContact(n) = surf2patch(x, y, heightDisplacement + z * metalContactsDistance);
    if n == nContacts
        insulation(n) = surf2patch(x, y, metalContactsDistance + heightDisplacement + z * 20);
    else
        insulation(n) = surf2patch(x, y, metalContactsDistance + heightDisplacement + z * insulationDistance);
    end
end

[x,y,z] = sphere(50);
dome = surf2patch(x(1:25,:) * electrodeRadius ,y(1:25,:) * electrodeRadius ,z(1:25,:) * 0.3);

axis([-10 10 -10 10 -10 heightDisplacement + 55]);
view(-37.5,30);

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