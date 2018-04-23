function [ match_vector ] = vectorcmp(arg0, vect_tomatch, varargin)
%ARRCMP Summary of this function goes here
%   Detailed explanation goes here

    match_vector=zeros(size(arg0),'double');
    for i=1:length(vect_tomatch)
        match_vector=match_vector + double(arg0==vect_tomatch(i));
    end

    match_vector=match_vector>0;
end

