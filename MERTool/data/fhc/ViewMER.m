clear all;
close all;
N = 128;
startN = 1;
sections = startN:N;
fulldists = [];
fulldistst = [];
figure
a=subplot(2,1,1);
for i = 1:3
    section = sections(i);
    t = APMReadData(['./First_Last/GPi Left/Pass 1/C/Snapshot - 3600.0 sec ' num2str(section) '/WaveformData-Ch1.apm']);
    dist = t.drive_data.depth;
    ch = 1;
    channel = t.channels(1);
    FS = channel.sampling_frequency;
    data = channel.continuous * channel.voltage_calibration;
    start_trial = channel.start_trial;
    time = (start_trial:(length(data)+start_trial-1))/FS;
    plot(time,data)
    hold on;
    disp(dist)
    if(dist(1) ~= 0) %sometmes the timestamp is just wrong...
        fulldists = [fulldists dist(2)];
        fulldistst = [fulldistst dist(1)/FS];
    end
end
hold off;
title('MER')
b=subplot(2,1,2);
scatter(fulldistst,fulldists)
linkaxes([a b],'x');
xlabel('Time (s)')
title('Depth')