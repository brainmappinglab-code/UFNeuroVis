function [ color_vector, line_style] = get_line_color_and_style_fromid( idx1 )
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
            line_style='-';
        case 2
            %orange
            color_vector=[0.85,0.325,0.098];
            line_style='-';
        case 3
            %orangy yellow
            color_vector=[0.929,0.694,0.125];
            line_style='-';
        case 4
            %violet
            color_vector=[0.494,0.184,0.556];
            line_style='-';
        case 5
            %grass green
            color_vector=[0.466,0.674,0.188];
            line_style='-';
        case 6
            %light blue
            color_vector=[0.301,0.745,0.933];
            line_style='-';
        case 7
            %dark red
            color_vector=[0.635,0.078,0.184];
            line_style='-';
        case 8
            %black
            color_vector=[0,0,0];
            line_style='-';
        case 9
            %dark blue
            color_vector=[0,0.447,0.741];
            line_style='.-';
        case 10
            %orange
            color_vector=[0.85,0.325,0.098];
            line_style='.-';
        case 11
            %orangy yellow
            color_vector=[0.929,0.694,0.125];
            line_style='.-';
        case 12
            %violet
            color_vector=[0.494,0.184,0.556];
            line_style='.-';
        case 13
            %grass green
            color_vector=[0.466,0.674,0.188];
            line_style='.-';
        case 14
            %light blue
            color_vector=[0.301,0.745,0.933];
            line_style='.-';
        case 15
            %dark red
            color_vector=[0.635,0.078,0.184];
            line_style='.-';
        case 16
            %black
            color_vector=[0,0,0];
            line_style='.-';
    end
    
    
end

