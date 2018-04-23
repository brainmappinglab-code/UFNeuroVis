function hjsystem_monitor()
%HJSYSTEM_MONITOR v0.1
%   Monitors memory usage

r=java.lang.Runtime.getRuntime;
precision=2;
freeMemory=formatBytesString(r.freeMemory,precision);
totalMemory=formatBytesString(r.totalMemory,precision);
usedMemory =formatBytesString(r.totalMemory-r.freeMemory,precision);
fprintf('HJ System Monitor v0.1\n');
fprintf('\tTotalMemory: %s\n\tFree Momory: %s\n\tUsed Memory: %s\n',totalMemory,freeMemory,usedMemory);
end

