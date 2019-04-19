function audio_tracker_stop(myPlayer,event,aH)
%AUDIO_TRACKER_STOP Summary of this function goes here
%   Detailed explanation goes here
    if (isappdata(aH,'marker'))
        marker = getappdata(aH,'marker');
        delete(marker);
    end
end

