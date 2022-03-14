function [ tonemappedCT ] = tonemapCT( CT, varargin )
%Tonemap the CT Images to increase visualization
%   [ tonemappedCT ] = tonemapCT( CT )

tonemappedCT = CT;

% LeadDBS Method
if nargin == 1
    brainWindow = [0 80];
    boneWindow = [80 1300];
    
    tonemappedCT(CT>brainWindow(1) & CT<brainWindow(2)) = (tonemappedCT(CT>brainWindow(1) & CT<brainWindow(2)) - brainWindow(1)) / diff(brainWindow);
    
    tonemappedCT(CT>=boneWindow(1) & CT<boneWindow(2)) = (tonemappedCT(CT>=boneWindow(1) & CT<boneWindow(2)) - boneWindow(1)) / diff(boneWindow);
    
    tonemappedCT(CT>=boneWindow(2)) = 1;
    tonemappedCT(CT<brainWindow(1)) = 0;
elseif nargin == 2
    % DBSArch tone mapping (empirical testing, not guaranteed to be generalizable)
    ind = CT > 0;
    brainWindow = [prctile(CT(ind),65) prctile(CT(ind),90)];
    boneWindow = [prctile(CT(ind),90)+1 prctile(CT(ind),99)];
    
    tonemappedCT(CT>brainWindow(1) & CT<brainWindow(2)) = (tonemappedCT(CT>brainWindow(1) & CT<brainWindow(2)) - brainWindow(1)) / diff(brainWindow);
    
    tonemappedCT(CT>=boneWindow(1) & CT<boneWindow(2)) = (tonemappedCT(CT>=boneWindow(1) & CT<boneWindow(2)) - boneWindow(1)) / diff(boneWindow);
    
    tonemappedCT(CT>=boneWindow(2)) = 1;
    tonemappedCT(CT<brainWindow(1)) = 0;
end

end

