function spike = spike_getter(data,FS, std_min,time)


par.sr = FS;                      % sampling rate
par.tmax = 'all';                    % maximum time to load
%par.tmax= 180;                      % maximum time to load (in sec)
par.tmin= 0;                         % starting time for loading (in sec)
par.w_pre = 20;                      % number of pre-event data points stored (default 20)
par.w_post = 44;                     % number of post-event data points stored (default 44))
par.alignment_window = 10;           % number of points around the sample expected to be the maximum
par.stdmin = std_min;                      % minimum threshold for detection
par.stdmax = 50;                     % maximum threshold for detection
par.detect_fmin = 300;               % high pass filter for detection
par.detect_fmax = 3000;              % low pass filter for detection (default 1000)
par.detect_order = 4;                % filter order for detection
par.sort_fmin = 300;                 % high pass filter for sorting
par.sort_fmax = 3000;                % low pass filter for sorting (default 3000)
par.sort_order = 2;                  % filter order for sorting
par.ref_ms = 1.5;                    % detector dead time, minimum refractory period (in ms)
par.detection = 'pos';             % type of threshold
% par.detection = 'neg';
% par.detection = 'both';
par.channels = 1;
par.interpolation = 'n'; 
[spikes, thr,index, xf_detect, xf] = amp_detect(data,par);

spike.spikes = spikes;
spike.time = time(index);
spike.local_index = index;
spike.FS = FS;
spike.thr = thr;
spike.xf = xf;
spike.filtered_data = xf_detect;
end

