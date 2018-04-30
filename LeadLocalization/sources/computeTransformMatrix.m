function T = computeTransformMatrix(Translation, Scale, Rotation)
% Construct Transformation Matrix from DBS Planning System

Rotation = deg2rad(Rotation); %convert to radians
xRot = [1 0 0 0; 0 cos(Rotation(1)) -sin(Rotation(1)) 0; 0 sin(Rotation(1)) cos(Rotation(1)) 0; 0 0 0 1];
yRot = [cos(Rotation(2)) 0 sin(Rotation(2)) 0; 0 1 0 0; -sin(Rotation(2)) 0 cos(Rotation(2)) 0; 0 0 0 1];
zRot = [cos(Rotation(3)) -sin(Rotation(3)) 0 0; sin(Rotation(3)) cos(Rotation(3)) 0 0; 0 0 1 0; 0 0 0 1];
scale = [Scale(1) 0 0 0; 0 Scale(2) 0 0; 0 0 Scale(3) 0; 0 0 0 1];
trans = [1 0 0 Translation(1); 0 1 0 Translation(2); 0 0 1 Translation(3); 0 0 0 1];

T = (xRot*yRot*zRot*scale*trans)';
