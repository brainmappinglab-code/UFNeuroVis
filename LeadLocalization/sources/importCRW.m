function [AC, PC, MC] = importCRW(filename)

AC = zeros(1,3);
PC = zeros(1,3);
MC = zeros(1,3);

fid = fopen(filename);
line = fgets(fid);

for i = 1:3
    while ~matchSTR(strsplit(line),'AC','bool') && ~matchSTR(strsplit(line),'PC','bool') && ~matchSTR(strsplit(line),'Ctrln','bool')
        line = fgets(fid);
    end
    
    if matchSTR(strsplit(line),'AC','bool')
        line = fgets(fid);
        line = fgets(fid);
        AC(2) = getNumberInLine(line);
        line = fgets(fid);
        AC(1) = getNumberInLine(line);
        line = fgets(fid);
        AC(3) = getNumberInLine(line);
    elseif matchSTR(strsplit(line),'PC','bool')
        line = fgets(fid);
        line = fgets(fid);
        PC(2) = getNumberInLine(line);
        line = fgets(fid);
        PC(1) = getNumberInLine(line);
        line = fgets(fid);
        PC(3) = getNumberInLine(line);
    elseif matchSTR(strsplit(line),'Ctrln','bool')
        line = fgets(fid);
        line = fgets(fid);
        MC(2) = getNumberInLine(line);
        line = fgets(fid);
        MC(1) = getNumberInLine(line);
        line = fgets(fid);
        MC(3) = getNumberInLine(line);
    end
end

fclose(fid);
        

function number = getNumberInLine(text)
C = textscan(text, '%s %s %f');
number = C{3};