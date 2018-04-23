function [ truecol1 ] = rgb2truecolor( rgb1 )
%TRUECOLOR2RGB transform RGB to truecolor
    %TODO: need testing
    truecol1 = hex2dec(sprintf(dec2hex(255*flip(rgb1,2))'));
end

