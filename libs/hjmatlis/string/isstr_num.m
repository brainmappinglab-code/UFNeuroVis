function [boolOut] = isstr_num(potentialnumber)
%isstr_num(potentialnumber)
%   check if the string cointains a number

    boolOut=all(ismember(potentialnumber, '0123456789+-.eEdD'));
end

