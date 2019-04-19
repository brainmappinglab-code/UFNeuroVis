function ApmDataTable = build_apm_table_from_old(path)
%BUILD_APM_TABLE_FROM_OLD Summary of this function goes here
%   Detailed explanation goes here

%assume path = <name>/<surgery>
%files are located: ./Pass n/Snapshot - nnnn.n sec <N>/WaveformData-Chn.apm

    % get the number of passes
    dirPass = dir(path);
    expr = 'Pass [0-9]';
    dirPass = regexp([dirPass.name],expr,'match');
    nPass = length(dirPass);
    
    %pre-allocate the table
    ApmDataTable = cell(1,nPass);
    
    for iPass = 1:nPass
        %get the number of recordings
        PassPath = [path '\' dirPass{iPass} '\C'];
        dirApm = dir(PassPath);
        expr = 'Snapshot - [0-9]+.[0-9] sec [0-9]+';
        dirApm = regexp([dirApm.name],expr,'match');
        
        %sort the recording directories to make things easier
        dirApm = natsort(dirApm);
        nApm = length(dirApm);
        
        %pre-allocate the table
        if verLessThan('matlab','9.4') % older than 2018a
            depth = zeros(nApm,1);
            path = strings(nApm,1);
            duration = zeros(nApm,1);
            x = zeros(nApm,1);
            y = zeros(nApm,1);
            z = zeros(nApm,1);
            match = zeros(nApm,1);
            tempTable = table(depth,path,duration,x,y,z,match);
        else
            tempTable = table('Size',[nApm 7],'VariableTypes',{'double', 'string', 'double', 'double', 'double', 'double','double'},'VariableName',{'depth','path','duration','x','y','z','match'});
        end
        
        for iApm = 1:nApm
            %read the apm file
            ApmPath = [PassPath '\' dirApm{iApm} '\WaveformData-Ch1.apm'];
            t = APMReadData(ApmPath);
            
            tempTable.path(iApm) = ApmPath; %path
            
            dur = size(t.channels.continuous,2)/t.channels.sampling_frequency; %divide no. of samples by sample frequency
            tempTable.duration(iApm) = dur;
            
            dist = t.drive_data(1).depth; %sometimes multiple drive_data are recorded in each section if there are multiple passes activated at once
            % if depth is empty, skip them
            if ~isempty(dist)
                if size(dist,1) > 1
                    msgbox('There are two depth values associated with this section. This is a known issue that Cosmin from FHC is aware of. Please report to him with this example.');
                    tempTable.depth(iApm) = dist(1,2);
                else
                    tempTable.depth(iApm) = dist(2)/1000; %depth value at the second location (timestamp at first location); convert to millimeters
                end
            end
        end
        
        ApmDataTable{iPass} = tempTable;
    end

end

