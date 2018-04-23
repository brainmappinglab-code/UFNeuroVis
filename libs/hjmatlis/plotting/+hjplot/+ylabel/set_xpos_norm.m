function set_xpos_norm(ylabel_handle, x__normalized_units)
%set the position of the ylabel to x__normalized_units

    unit1=ylabel_handle.Units;
    
    %change temporarily units to normalized and set position
    ylabel_handle.Units='normalized';
    ylabel_handle.Position(1)=x__normalized_units;
    
    %set units to the original value
    ylabel_handle.Units=unit1;