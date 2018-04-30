function [ tonemappedCT ] = tonemapCT( CT, varargin )
%Tonemap the CT Images to increase visualization
%   [ tonemappedCT ] = tonemapCT( CT )

tonemappedCT = CT;
brainWindow = [0 80];
boneWindow = [80 1300];

% LeadDBS Method
if nargin == 1
    % brain window: center = 40, width = 80
    tonemappedCT(CT>brainWindow(1) & CT<brainWindow(2)) = (tonemappedCT(CT>brainWindow(1) & CT<brainWindow(2)) - brainWindow(1)) / diff(brainWindow);
    % bone window: center = 300, width = 1300
    tonemappedCT(CT>=boneWindow(1) & CT<boneWindow(2)) = (tonemappedCT(CT>=boneWindow(1) & CT<boneWindow(2)) - boneWindow(1)) / diff(boneWindow);
    % saturate above and below levels:
    tonemappedCT(CT>=boneWindow(2)) = 1;
    tonemappedCT(CT<brainWindow(1)) = 0;
elseif nargin == 2
end

end

