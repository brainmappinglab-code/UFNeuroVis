function [patch1,fvc]=sphere(c,r, resolution1, opt_patch)
%[patch1,fvc]=hj3d.draw.sphere(c, r [, resolution1, opt_patch])
% - c: a 3d vector for the center coordinates e.g. [x0, y0, z0]
% - r: radius of the sphere
% optional:
% - resolution1: resolution of the sphere (num of voxel used per dimension)
% - opt_patch: additional parameters (follows the format fo patch method)

    if ~exist('resolution1','var') || isempty(resolution1)
        fvc=hj3d.create.sphere(c,r);
    else
        fvc=hj3d.create.sphere(c,r, resolution1);
    end

    if ~exist('opt_patch','var') || isempty(opt_patch)
        opt_patch={'facecolor','b','facealpha',0.6,'edgecolor','none'};
    end
    
    %parse string
    opt_patch_str=[char(39) strjoin(cellfun(@val2str,opt_patch,'UniformOutput',false),''',''')  char(39)];
    
    %make the patch
    patch1=eval(['patch(fvc,' opt_patch_str ')']);
end

