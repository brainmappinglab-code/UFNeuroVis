function [ out ] = movingvar(x,m)
%MOVINGVAR moving variance
%   x: vector
%   m: window size

    if size(x,1)==1
        windw=ones(1,m);
        out=conv(x.^2,windw,'valid')./m-(conv(x,windw,'valid')./m).^2;
    elseif size(x,2)==1
        windw=ones(m,1);
        out=conv(x.^2,windw,'valid')./m-(conv(x,windw,'valid')./m).^2;
    else
        error('input has to be a vector');
    end
end

