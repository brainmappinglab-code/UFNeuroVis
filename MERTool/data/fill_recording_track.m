function status = fill_recording_track(DbsData,cellIndex,trackIndex,File)
%{
FILL_RECORDING_TRACK
    extracts data from MER structure and writes to .xls file
ARGS
    DbsData: structure, contains MER data
    cellIndex: int, the row where the headers begin (same index as createStimTemplate)
    trackIndex: int, number corresponding to which pass is being written
    File: structure, with fields
        path: string, path to output file destination
        name: string, name of output file
        type: string, '.xls' or '.xlsx'
        full: string, [File.path File.name File.type]
 RETURNS
    status: logical 1 on success, 0 on failure
%}

trackLength = size(DbsData.data1,1);

% use cell_index to find top row of the track fields
topRow = cellIndex + 7;

% preallocate
locations = cell(trackLength,1);
certainty = cell(trackLength,1);
celltype = cell(trackLength,1);
bodypart = cell(trackLength,1);
movement = cell(trackLength,1);

% decode locations
for i = 1:trackLength
    if ~isempty(DbsData.data1{i,3,trackIndex})
        switch DbsData.data1{i,3,trackIndex}
            case '1'
                locations{i,1} = 'Thal';
            case '2'
                locations{i,1} = 'Str';
            case '3'
                locations{i,1} = 'STN';
            case '4'
                locations{i,1} = 'SNr';
            case '5'
                locations{i,1} = 'GPE';
            case '6'
                locations{i,1} = 'GPi';
            case '7'
                locations{i,1} = 'Voa';
            case '8'
                locations{i,1} = 'Vop';
            case '9'
                locations{i,1} = 'Vim';
            case '10'
                locations{i,1} = 'Vc';
            case '11'
                locations{i,1} = 'IC';
            case '12'
                locations{i,1} = 'OT';
            case '13'
                locations{i,1} = 'Zl';
            case '14'
                locations{i,1} = 'Bord';
            case '15'
                locations{i,1} = 'Ansa';
            case '16'
                locations{i,1} = 'Nucl';
            case '17'
                locations{i,1} = 'Qui.';
            case '18'
                locations{i,1} = 'Oth.';
            case '19'
                locations{i,1} = 'Fib.';
            case '20'
                locations{i,1} = 'Top';
            case '21'
                locations{i,1} = 'Bot.';
            otherwise
                locations{i,1} = '';
        end
    end
end

% decode certainty
for i = 1:trackLength
    if ~isempty(DbsData.data1{i,5,trackIndex})
        switch DbsData.data1{i,5,trackIndex}
            case '1'
                certainty{i,1} = 'Certain';
            case '2'
                certainty{i,1} = 'Uncertain';
            otherwise
                certainty{i,1} = '';
        end
    end
end

% decode celltype
for i = 1:trackLength
    if ~isempty(DbsData.data1{i,6,trackIndex})
        switch DbsData.data1{i,6,trackIndex}
            case '1'
                celltype{i,1} = 'Injury';
            case '2'
                celltype{i,1} = 'Popcorn';
            case '3'
                celltype{i,1} = 'Bursting';
            case '4'
                celltype{i,1} = 'Pausing';
            case '5'
                celltype{i,1} = 'Chugging';
            case '6'
                celltype{i,1} = 'HFD-P';
            case '7'
                celltype{i,1} = 'LFD-P';
            case '8'
                celltype{i,1} = 'Tactile';
            case '9'
                celltype{i,1} = 'L. Touch';
            case '10'
                celltype{i,1} = 'Rhythmic';
            case '11'
                celltype{i,1} = 'Pro. Act';
            case '12'
                celltype{i,1} = 'Pro. Pas';
            case '13'
                celltype{i,1} = 'Tonic';
            case '14'
                celltype{i,1} = 'Neg';
            case '15'
                celltype{i,1} = 'Tremor';
            case '16'
                celltype{i,1} = 'Low Amp.';
            case '17'
                celltype{i,1} = 'High Amp.';
            case '18'
                celltype{i,1} = 'Oscilla';
            case '19'
                celltype{i,1} = 'Bg. Up';
            case '20'
                celltype{i,1} = 'Bg. Down';
            case '21'
                celltype{i,1} = 'Other';
            otherwise
                celltype{i,1} = '';
        end
    end
end

% decode bodypart
for i = 1:trackLength
    if ~isempty(DbsData.data1{i,7,trackIndex})
        switch DbsData.data1{i,7,trackIndex}
            case '1'
                bodypart{i,1} = 'Face';
            case '2'
                bodypart{i,1} = 'Cheek';
            case '3'
                bodypart{i,1} = 'In. Mouth';
            case '4'
                bodypart{i,1} = 'Tongue';
            case '5'
                bodypart{i,1} = 'Jaw';
            case '6'
                bodypart{i,1} = 'Chin';
            case '7'
                bodypart{i,1} = 'Neck';
            case '8'
                bodypart{i,1} = 'Shoulder';
            case '9'
                bodypart{i,1} = 'Elbow';
            case '10'
                bodypart{i,1} = 'Arm';
            case '11'
                bodypart{i,1} = 'Hand';
            case '12'
                bodypart{i,1} = 'Wrist';
            case '13'
                bodypart{i,1} = 'Fingers';
            case '14'
                bodypart{i,1} = 'Hip';
            case '15'
                bodypart{i,1} = 'Leg';
            case '16'
                bodypart{i,1} = 'Knee';
            case '17'
                bodypart{i,1} = 'Ankle';
            case '18'
                bodypart{i,1} = 'Foot';
            case '19'
                bodypart{i,1} = 'Toes';
            otherwise
                bodypart{i,1} = '';
        end
    end
end

% decode movement
for i = 1:trackLength
    if ~isempty(DbsData.data1{i,8,trackIndex})
        switch DbsData.data1{i,8,trackIndex}
            case '10000000'
                movement{i,1} = 'Ab';
            case '01000000'
                movement{i,1} = 'Ad';
            case '00100000'
                movement{i,1} = 'Ex';
            case '00010000'
                movement{i,1} = 'FI';
            case '00001000'
                movement{i,1} = 'IR';
            case '00000100'
                movement{i,1} = 'ER';
            case '00000010'
                movement{i,1} = 'Df';
            case '00000001'
                movement{i,1} = 'Pf';
            otherwise
                movement{i,1} = '';
        end
    end
end

% extract stim data from MER structure
depth = DbsData.data1(:,2,trackIndex);
comments = DbsData.data1(:,4,trackIndex);
trackInfo = [
    DbsData.trackinfo(trackIndex,3);
    DbsData.trackinfo(trackIndex,5);
	DbsData.trackinfo(trackIndex,6);
	DbsData.trackinfo(trackIndex,7);
	DbsData.trackinfo(trackIndex,8);
    ];

% write stim data by column, checking for errors after each write
status = xlswrite(File.full,trackIndex,1,['B' num2str(cellIndex)]);
if status
    if DbsData.trackinfo(trackIndex,2) == 2
        status = xlswrite(File.full,{'Anterior'},1,['A' num2str(cellIndex + 1)]);
    elseif DbsData.trackinfo(trackIndex,2) == 3
        status = xlswrite(File.full,{'Posterior'},1,['A' num2str(cellIndex + 1)]);
    end
end
if status
    if DbsData.trackinfo(trackIndex,4) == 2
        status = xlswrite(File.full,{'Medial'},1,['A' num2str(cellIndex + 2)]);
    elseif DbsData.trackinfo(trackIndex,4) == 3
        status = xlswrite(File.full,{'Lateral'},1,['A' num2str(cellIndex + 2)]);
    end
end
if status
    status = xlswrite(File.full,trackInfo,1,['B' num2str(cellIndex + 1)]);
end
if status
    status = xlswrite(File.full,depth,1,['C' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,locations,1,['D' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,certainty,1,['E' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,celltype,1,['F' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,bodypart,1,['G' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,movement,1,['H' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,comments,1,['I' num2str(topRow)]);
end

end