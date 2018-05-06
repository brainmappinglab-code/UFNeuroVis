function [ theta_values1 ] = hjtotal_rotation_angle( theta_values1 )
%[ theta_values_continous1 ] = hjtotal_rotation_angle( theta_values1 ) ( theta_values1 )
%   the functiomn parse the angle data and makes it continous (avoiding the
%   step every 2pi
    theta_values1=theta_values1-cumsum(sign(theta_values1).*[0 (abs(diff(theta_values1))>=3/2*pi)])*2*pi;

end

