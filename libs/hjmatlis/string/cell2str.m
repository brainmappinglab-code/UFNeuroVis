function [str_val] = cell2str(cell_val)
%[str_val] = cell2str(cell_val)
%convert single cell value to string (useful to parse some outputs in one
%liner code)
val1=cell_val{1};

[str_val] = val2str(val1);