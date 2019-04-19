function audio_tracker_callback(myPlayer,event,aH)
%AUDIO_TRACKER_CALLBACK Summary of this function goes here
%   Detailed explanation goes here

if (myPlayer.Running == 'on')
    if (isappdata(aH,'marker'))
        marker = getappdata(aH,'marker');
        delete(marker);
    end
    n = myPlayer.CurrentSample;
    lH = findobj(aH,'Type','Line');
    x = get(lH,'Xdata');
    marker = line(aH,[x(n) x(n)],get(aH,'YLim'),'color',[1 0 0]);
    setappdata(aH,'marker',marker);
end



