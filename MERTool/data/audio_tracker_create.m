function ret = audio_tracker_create(aH,ApmDataTable,iPass,iPoint)
%AUDIO_TRACKER_CREATE Summary of this function goes here
%   Detailed explanation goes here
    [path,name,~] = fileparts(char(ApmDataTable{iPass}.path(iPoint)));
    wavPath = sprintf('%s\\wav\\%s_Ch1.wav',path,name);
    f = ancestor(aH,'figure');
    handles = guidata(f);
    if exist(wavPath,'file')    % file existence
        ret = 1;
        [y, fs] = audioread(wavPath);
        handles.myPlayer = audioplayer(y,fs);
        handles.myPlayer.TimerFcn = {@audio_tracker_callback,handles.disp_axes};
        handles.myPlayer.StopFcn = {@audio_tracker_stop,handles.disp_axes};
        handles.myPlayer.TimerPeriod = 0.005;
    else
        ret = 0;
    end
    
    guidata(f,handles)
end

