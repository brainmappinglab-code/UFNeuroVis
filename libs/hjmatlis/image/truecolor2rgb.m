function [ rgb1 ] = truecolor2rgb( truecol1 )
%TRUECOLOR2RGB transform truecolor to RGB 
    %TODO: need testing
    rgb1 = mod([truecol1 floor(truecol1/256) floor((truecol1)/256^2)],256) /255;
end