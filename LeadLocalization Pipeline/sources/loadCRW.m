function [CRW] = loadCRW(crwFile)
    fid = fopen(crwFile);
    tline = fgetl(fid);
    tlines = cell(0,1);
    while ischar(tline)
        tlines{end+1,1} = tline;
        tline = fgetl(fid);
    end
    fclose(fid);
    
    CRW.Target.Target = findValuesPos(tlines,'Target Point');
    CRW.Target.Entry = findValuesPos(tlines,'Entry Point');
    CRW.ACPC.AC = findValuesPos(tlines,'AC Point');
    CRW.ACPC.AC.Point = getAsPoint(CRW.ACPC.AC);
    CRW.ACPC.PC = findValuesPos(tlines,'PC Point');
    CRW.ACPC.PC.Point = getAsPoint(CRW.ACPC.PC);
    CRW.ACPC.Cntr = findValuesPos(tlines,'Ctrln Point');
    CRW.ACPC.Cntr.Point = getAsPoint(CRW.ACPC.Cntr);
    CRW.FuncTarget.FuncTarget = findValuesPos(tlines,'Func Targ Point');
    CRW.FuncTarget.Point = getAsPoint(CRW.FuncTarget.FuncTarget);
    CRW.FuncTarget.Orientation = findSingleValue(tlines,'Orientation');
    CRW.FuncTarget.ACPCAngle = findSingleValue(tlines,'ACPC Angle');
    CRW.FuncTarget.CTRAngle = findSingleValue(tlines,'Cline Angle');
    CRW.ACPC.Empty = isPosEmpty(CRW.ACPC.AC) && isPosEmpty(CRW.ACPC.PC) && isPosEmpty(CRW.ACPC.Cntr);
    CRW.FuncTarget.Empty = isPosEmpty(CRW.FuncTarget.FuncTarget);
    
end

function Out = getAsPoint(vals)
Out = [vals.LT vals.AP vals.AX];
end

function Out = findValuesPos(tlines,header)
    ind = find(strcmp(tlines,header));
    Out.Valid = getVal(tlines{ind+1});
    Out.AP = getVal(tlines{ind+2});
    Out.LT = getVal(tlines{ind+3});
    Out.AX = getVal(tlines{ind+4});
end

function Out = getVal(tline)
    indSpace = find(tline==' ');
    indSpace = indSpace(2); %the second apce after the equal sign
    Out = str2double(tline((indSpace+1):end));
end

function Out = findSingleValue(tlines,header)
    ind = find(startsWith(tlines,header));
    tline = tlines{ind};
    indSpace = find(tline==' ');
    indSpace = indSpace(end); %get the last space before the number
    Out = str2double(tline((indSpace+1):end));
end

function Out = isPosEmpty(pos)
    Out = pos.AP==0 && pos.LT==0 && pos.AX==0;
end