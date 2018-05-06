function [hh1, mm1, ss1]=get_time_from_string(datestring1)
%get time from string
% format can be hh:mm:ss or mm:ss
    %{
    if length(datestring1)>5
        ss1=str2double(datestring1(7:8));
        mm1=str2double(datestring1(4:5));
        hh1=str2double(datestring1(1:2));
    else
        ss1=str2double(datestring1(4:5));
        mm1=str2double(datestring1(1:2));
        hh1=0;
    end
    %}

    split1=strsplit(datestring1,':');
    if length(split1)>2
        ss1=str2double(split1{3});
        mm1=str2double(split1{2});
        hh1=str2double(split1{1});
    else
        ss1=str2double(split1{2});
        mm1=str2double(split1{1});
        hh1=0;
    end
end