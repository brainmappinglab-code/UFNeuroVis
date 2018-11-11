function status = fill_stim_track(DbsData,cellIndex,trackIndex,File)
%{
FILL_STIM_TRACK
    extracts stim data from MER structure and writes to .xls file
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

% use cell_index to find top row of the track fields
topRow = cellIndex + 7;

% extract stim data from MER structure
depth = DbsData.data31(:,1,trackIndex);
neg = DbsData.data31(:,2,trackIndex);
pos = DbsData.data31(:,3,trackIndex);
pulse_width = DbsData.data31(:,4,trackIndex);
amp = DbsData.data31(:,5,trackIndex);
freq = DbsData.data31(:,6,trackIndex);
comments = DbsData.data31(:,7,trackIndex);
trackInfo = [
    DbsData.trackinfo2(trackIndex,3);
    DbsData.trackinfo2(trackIndex,5);
	DbsData.trackinfo2(trackIndex,6);
	DbsData.trackinfo2(trackIndex,7);
	DbsData.trackinfo2(trackIndex,8);
    ];

% write stim data by column, checking for errors after each write
status = xlswrite(File.full,trackIndex,1,['B' num2str(cellIndex)]);
if status
    if DbsData.trackinfo2(trackIndex,2) == 2
        status = xlswrite(File.full,{'Anterior'},1,['A' num2str(cellIndex + 1)]);
    elseif DbsData.trackinfo2(trackIndex,2) == 3
        status = xlswrite(File.full,{'Posterior'},1,['A' num2str(cellIndex + 1)]);
    end
end
if status
    if DbsData.trackinfo2(trackIndex,2) == 2
        status = xlswrite(File.full,{'Anterior'},1,['A' num2str(cellIndex + 1)]);
    elseif DbsData.trackinfo2(trackIndex,2) == 3
        status = xlswrite(File.full,{'Posterior'},1,['A' num2str(cellIndex + 1)]);
    end
end
if status
    status = xlswrite(File.full,trackInfo,1,['B' num2str(cellIndex + 1)]);
end
if status
    status = xlswrite(File.full,depth,1,['A' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,neg,1,['B' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,pos,1,['C' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,freq,1,['D' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,amp,1,['E' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,pulse_width,1,['F' num2str(topRow)]);
end
if status
    status = xlswrite(File.full,comments,1,['G' num2str(topRow)]);
end

end