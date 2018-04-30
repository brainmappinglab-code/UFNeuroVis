function T = readFuseMatrix(filename)
fid = fopen(filename);
line = fgetl(fid);
if ~strcmpi(line, 'Fuse 7.0 Xfrm file');
    error('Incorrect file. This is not fuse file');
end

line = fgetl(fid);
Translation = str2double(strsplit(line,' '));
line = fgetl(fid);
X = str2double(strsplit(line,' '));
line = fgetl(fid);
Y = str2double(strsplit(line,' '));
line = fgetl(fid);
Z = str2double(strsplit(line,' '));

Translation(isnan(Translation)) = 1;
X(isnan(X)) = 0;
Y(isnan(Y)) = 0;
Z(isnan(Z)) = 0;
T = [X;Y;Z;Translation];