function hj_PC_sleep()
	%put the computer to sleep
	if ispc
		system('rundll32.exe powrprof.dll,SetSuspendState 0,1,0');
	elseif ismac
    % Code to run on Mac plaform
	elseif isunix
    % Code to run on Linux plaform
	end