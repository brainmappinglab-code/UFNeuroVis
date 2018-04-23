function out_vars=evalin__subbase(expression1)
%evalin__subbase(expression1)
%   useful to eval a function or script or a piece of code and keep
%   variables separate from the base workspace

%eval expression inside this function workspace
%do not suppress output (just in case I want to see it)
eval(expression1);

list_vars=who();
out_vars=struct();
for var_i=1:length(list_vars)
    evalc(['out_vars.' list_vars{var_i} '=' list_vars{var_i}]);
end
%condering to remove expression1 field (if it is not needed in the output)
%rmfield(out_vars,'expression1');

