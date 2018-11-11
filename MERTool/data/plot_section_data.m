function plot_section_data(aH,sectionPath,style)
%{
PLOT_SECTION_DATA
    After selecting point in traj_axes, display the APM channel data
    on disp_axes in the user-selected style.
ARGS
    aH: handle of axes to plot 3D trajectory on
    sectionPath: path to APM file (from column 2 of ApmDataTable)
    style: int, selection value from drop-down menu
RETURNS
    None
%}

% open and read the APM file
t = APMReadData(sectionPath);

% get data necessary for plotting
channel = t.channels(1);
FS = channel.sampling_frequency;
data = channel.continuous * channel.voltage_calibration;
start_trial = channel.start_trial;
time = (start_trial:(length(data)+start_trial-1))/FS;

% spike calculations
std_min = 4;
spike_section = spike_getter(data,FS,std_min,time); 
while length(spike_section.local_index) < 10
    std_min = std_min -1;
    spike_section = spike_getter(data,FS,std_min,time); 
end
sampled_spike_times = spike_times(spike_section.time,FS);

if style == 1
    %full
    plot(aH,time,data)
elseif style == 2
    %spike peaks
    scatter(aH,spike_section.local_index,spike_section.spikes(:,20),'r')
elseif style == 3
    %spike line
    plot(aH,sampled_spike_times',spike_section.spikes')
end

set(gca,'Tag','disp_axes');
xlabel(gca,'Seconds');

end

