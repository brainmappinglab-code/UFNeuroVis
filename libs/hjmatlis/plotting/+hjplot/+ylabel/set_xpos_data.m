function set_xpos_data(ylabel_handle, x__data_units)
%set the position of the ylabel to x__data_units

    unit1=ylabel_handle.Units;
    
    %change temporarily units to data and set position
    ylabel_handle.Units='data';
    ylabel_handle.Position(1)=x__data_units;
    
    %set units to the original value
    ylabel_handle.Units=unit1;