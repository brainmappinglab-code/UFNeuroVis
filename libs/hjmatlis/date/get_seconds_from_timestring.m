function [sec_tot1]=get_seconds_from_timestring(datestring1)
    [hh1, mm1, ss1]=get_time_from_string(datestring1);
    [sec_tot1]=get_seconds_from_time(hh1, mm1, ss1);
end