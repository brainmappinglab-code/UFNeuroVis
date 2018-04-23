function InplaceArray_install
% function InplaceArray_install
% Installation by building the C-mex files for InplaceArray package
%
% Author Bruno Luong <brunoluong@yahoo.com>
% History: 28-Jun-2009 built inplace functions
%          17-July-2012, improve the installation with separate folder for
%          different MATLAB versions

arch=computer('arch');
mexopts = {'-v' '-O' ['-' arch]};
% 64-bit platform
if ~isempty(strfind(computer(),'64'))
    mexopts(end+1) = {'-largeArrayDims'};
end

% Internal representation of mxArray
buildInternal_mxArrayDef('Internal_mxArray.h');

here = fileparts(mfilename('fullpath'));
MatlabRelease = version('-release');
MexPathname = [here filesep() MatlabRelease];
if ~exist(MexPathname, 'dir')
     mkdir(MexPathname);
end
% mex Inplace tools, place it on MexPathname
mex(mexopts{:},'inplacearray.c','-output',[MexPathname filesep 'inplacearray.' mexext]);
mex(mexopts{:},'releaseinplace.c','-output',[MexPathname filesep 'releaseinplace.' mexext]);

% Update the search path
fprintf('Add %s in searchpath\n', MexPathname);
addpath(MexPathname,here,'-begin');
savepath();