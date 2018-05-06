function fvc=sphere(c,r, resolution1)
    %[patch1,fvc]=hj3d.create.sphere(c, r [, resolution1])
    % - c: a 3d vector for the center coordinates e.g. [x0, y0, z0]
    % - r: radius of the sphere
    % optional:
    % - resolution1: resolution of the sphere (num of voxel used per dimension)
    
    if ~exist('resolution1','var') || isempty(resolution1)
        resolution1=20;
    end

    [x,y,z] = sphere(resolution1);

    x=x*r+c(1);
    y=y*r+c(2);
    z=z*r+c(3);

    fvc = surf2patch(x,y,z);

end