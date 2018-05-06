function [ndata, avgs, stds] = znorm(data, varargin)
%[ndata, avgs, stds] = znorm(data[, dir_norm=1])
%compute z-normalization
%   INPUT
%      - data: data to be normalized
%      - dir_norm: Optional. Default is 1. Ex. dir_norm=1, normalize 
%                  respect to rows (considering columns as channels)
%
%   OUTPUT
%      - ndata: normalized data (in the direction selected)
%      - avgs: mean of the data (in the direction selected)
%      - stds: std of the data (in the direction selected)
%   NOTES
%      special cases in ndatan (the advice is to exclude data with std equal to 0)
%      - NaN is 0/0
%      - Inf is N/0

    if nargin==1
        dir_norm=1;
    elseif nargin==2
        dir_norm=varargin{1};
    end
    %{
    if dir_norm==1
        [ndata,sout]=mapstd(data');
        avgs=sout.xmean';
        stds=sout.xstd';
        ndata=ndata';
    else
        [ndata,sout]=mapstd(data);
        avgs=sout.xmean;
        stds=sout.xstd;
    end
    %}
    
    stds=sqrt(var(data, 0, dir_norm));
    avgs=mean(data, dir_norm);
    ndata=bsxfun(@times,bsxfun(@minus,data,avgs),1./stds);
end

