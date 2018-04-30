function recursiveAddPath(path)

addpath(path);
folders = dir(path);
for n = 1:length(folders)
    if strcmpi(folders(n).name,'.') || strcmpi(folders(n).name,'..')
        continue;
    elseif folders(n).isdir
        addpath([path,filesep,folders(n).name])
        recursiveAddPath([path,filesep,folders(n).name]);
    end
end
