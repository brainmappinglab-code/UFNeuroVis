function [arrayout popitem popindex] = array_pop(array)
	%[arrayout popitem popindex] = array_pop(array)
	
	popindex = length(array);
	popitem = array(popindex);
	array(popindex) = [];
	arrayout = array;