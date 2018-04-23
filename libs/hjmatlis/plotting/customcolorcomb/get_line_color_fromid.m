function [ color_vector ] = get_line_color_fromid( idx1 )
%[ color_vector ] = get_line_color_fromid( idx1 )
%   
%to test colors:
%   plot(1:100,'color',get_line_color_fromid(6),'linewidth',4)
%
%colors available:
% - dark blue     : [0.000,0.447,0.741]
% - orange        : [0.850,0.325,0.098]
% - orangy yellow : [0.929,0.694,0.125]
% - violet        : [0.494,0.184,0.556]
% - grass green   : [0.466,0.674,0.188]
% - light blue    : [0.301,0.745,0.933]
% - dark red      : [0.635,0.078,0.184]
% - black         : [0.000,0.000,0.000]

    switch(idx1)
        case 1
            %dark blue
            color_vector=[0,0.447,0.741];
        case 2
            %orange
            color_vector=[0.85,0.325,0.098];
        case 3
            %orangy yellow
            color_vector=[0.929,0.694,0.125];
        case 4
            %violet
            color_vector=[0.494,0.184,0.556];
        case 5
            %grass green
            color_vector=[0.466,0.674,0.188];
        case 6
            %light blue
            color_vector=[0.301,0.745,0.933];
        case 7
            %dark red
            color_vector=[0.635,0.078,0.184];
        case 8
            %black
            color_vector=[0,0,0];
    end
    
    
end

