function [sec_tot1]=get_seconds_from_time(hh1, mm1, ss1)
    sec_tot1=ss1+mm1*60+hh1*3600;
end