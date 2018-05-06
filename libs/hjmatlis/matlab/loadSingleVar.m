function [out] = loadSingleVar(filepath)
    %[out] = loadSingleVar(filepath)

    foo = load(filepath);
    whichVariables = fieldnames(foo);
    if numel(whichVariables) == 1
        out = foo.(whichVariables{1});
    else
        error('there are multiple vars stored in the mat file');
    end
end

