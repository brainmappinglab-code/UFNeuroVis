function [psth,psthTrialAvg,varTrialAvg] = CalculatePSTH(SpikeTimes,start,varargin)
% ---------[psth] = CalculatePSTH(SpikeTimes,EventTimes,varargin)-------------
%
%   Calculates peri-stimulus time histograms (PSTHs) from a matrix or cell
%   array of spiketimes (in seconds), given a user-defined bin-width. Plots
%   PSTHs and saves in current directory.
%
%               >>> INPUTS >>>
% Required:
%   SpikeTimes = matrix or cell of spiketimes in SECONDS
%           If matrix, will assume columns are trials, rows are spiketimes.
%           If cell, will assume each cell is a trial, and in each cell
%           columns are channels, rows are spiketimes.
%   start = n-element vector containing times of events (in seconds)...if
%           spiketimes are relative (i.e. blocks of spikeitmes, each block relative
%           to stim onset), then user should define "start" as the time of the
%           onset of the stim relative to the start of the block. For instance, if
%           stim is 6 seconds into the start of each block, then set "start" = 6.
%           * if spikes NOT relative, start = nx1 array of starting times.
% Optional:
%   pre_time = time (in SECONDS) to subtract from starting time...
%           makes plots relative to stim onset (default = 1s);
%   post_time = time (in SECONDS) to add to starting time...
%           (default = 1s);
%   bin_width = bin (ms) for PSTH calculation. Default = 10ms.
%   name = name to save figure (default = "psth.pdf")
%   saving = 0 or 1 (default 1). If 1, saves figures to current directory.
%   
%               <<< OUTPUTS <<<
%   psth = bin-counts of spiketimes occuring within specified time range.
%           If SpikeTimes is a cell array, psth is an nxtrialsxchan matrix.
%           If SpikeTimes is a matrix, psth is an nxtrials matrix
%   psthTrialAvg = average of psth across trials per channel
%   varTrialAvg = average variance of psth across trials per channel
%
% Example:
%   SpikeTimes{1} = sort(rand(100)); % fake spiketimes for ch1
%   SpikeTimes{2} = sort(rand(100)); % fake spiketimes for ch2
%   [psth,trialAvg,varAvg] = CalculatePSTH(SpikeTimes,.5,.2,.5,10,'control',1)
%       % plots histogram and variances for each channel, from -0.2s : 0.5s
%       % around the starting point, (here 0.5s into the SpikeTimes). Save
%       % the figures and appends "control" to the figure name
%   
% By JMS, 11/13/2015
%-------------------------------------------------------

% check optionals
if nargin>2 && ~isempty(varargin{1})
    pre_time = varargin{1};
else pre_time = 1; end % default 1s before start
if nargin>3 && ~isempty(varargin{2})
    post_time = varargin{2};
else post_time = 1; end % default 1s after start
if nargin>4 && ~isempty(varargin{3})
    bw = varargin{3}; else bw = 10; end % default 10s bin width
if nargin>5 && ~isempty(varargin{4})
    name = varargin{4}; end % default no name for saving figs
if nargin>6 && ~isempty(varargin{5})
    saving = varargin{5};
else saving = 1; end

% compute plotting times
lastBin = ceil((post_time*1000)); % last bin edge in ms
edge = EdgeCalculator(bw,-pre_time*1000,lastBin); % extract edges for psth
xmin = edge(1); % for plotting
xmax = edge(end); % for plotting

% check if SpikeTimes is cell or matrix
if iscell(SpikeTimes)
     chans = max(size(SpikeTimes));
     ntrials = size(SpikeTimes{1},2);
else
    ntrials = size(SpikeTimes,2);
    chans = 1;
end

% error check if size(start) ~= ntrials....if so, repeat "start" so that it
% has same dimension as ntrials
if numel(start) == 1 && ntrials > 1
    start = ones(ntrials,1)*start;
else
    assert('Error: starting times and # trials not same dimension');
end


% -------- begin loop ------------
disp('calculating PSTHs...');
clear psth
try % compute PSTH and plot
   if iscell(SpikeTimes)
        psth = zeros(numel(edge),ntrials,chans);
        for ch = 1:chans
            for trial = 1:ntrials
                if ~isempty(SpikeTimes{ch})
                    psthSpikes = SpikeTimes{ch}(SpikeTimes{ch}(:,trial) > start(trial)-pre_time & SpikeTimes{ch}(:,trial) < start(trial)+post_time,trial); % extract spikes occuring within pre/post times of start time
                    psth(:,trial,ch) = histc((psthSpikes-start(trial))*1000,edge) / (bw/1000) / ntrials; % make spikes relative to start and extract spike count per bin, divide by bw in seconds to get firing rate 
                    clear psthSpikes
                end
            end
        end
        psthTrialAvg = squeeze(mean(psth,2)); % take mean across trials, squeeze into nxchan array
        varTrialAvg = squeeze(var(psth,0,2));
        psthylim = [0 max(max(psthTrialAvg))]; % for plotting
        varylim = [0 max(max(varTrialAvg))];

   else % if not a cell array
       psth = zeros(numel(edge),ntrials);
       for trial = 1:ntrials
           psthSpikes = SpikeTimes(SpikeTimes(:,trial) > start(trial)-pre_time & SpikeTimes(:,trial) < start(trial)+post_time,trial); % extract spikes occuring within pre/post times of start time
           psth(:,trial) = histc((psthSpikes-start(trial))*1000,edge) / (bw/1000) / ntrials; % make spikes relative to start and extract spike count per bin, divide by bw in seconds to get firing rate 
           clear psthSpikes
       end
       psthTrialAvg = mean(psth,2); % take mean across trials
       varTrialAvg = var(psth,0,2); % take variance across trials
       psthylim = [0 max(psthTrialAvg)]; % for plotting
       varylim = [0 max(varTrialAvg)];
   end

   % --- PSTH bar plots ---
   pH = figure;
   if iscell(SpikeTimes)
       for ch = 1:chans
            if chans>6
                subplot(3,3,ch);
                bar(edge,psthTrialAvg(:,ch),'histc');
                set(gca,'xlim',[xmin xmax],'ylim',psthylim,...
                    'box','off','tickdir','out');
                title(['Ch: ',num2str(ch)])
                ylabel('SpikeRate');
            elseif chans>4
                subplot(3,2,ch);
                bar(edge,psthTrialAvg(:,ch),'histc');
                set(gca,'xlim',[xmin xmax],'ylim',psthylim,...
                    'box','off','tickdir','out');
                title(['Ch: ',num2str(ch)])
                ylabel('SpikeRate');
            elseif chans>2
                subplot(2,2,ch); 
                bar(edge,psthTrialAvg(:,ch),4,'histc');
                set(gca,'xlim',[xmin xmax],'ylim',psthylim,...
                    'box','off','tickdir','out');
                title(['Ch: ',num2str(ch)])
                ylabel('SpikeRate');
            else 
                plot(1,ch);
                bar(edge,psthTrialAvg(:,ch),'histc');
                set(gca,'xlim',[xmin xmax],'ylim',psthylim,...
                    'box','off','tickdir','out');
                title(['Ch: ',num2str(ch)])
                ylabel('SpikeRate');
            end
       end
   else
       % plot variance and psth in same figure if only one channel
       subplot(2,1,1);
       bar(edge,psthTrialAvg,'histc');
       set(gca,'xlim',[xmin xmax],'ylim',psthylim,...
                    'box','off','tickdir','out');   
       title('PSTH');
       ylabel('Spike Rate');
       subplot(2,1,2);
       plot(edge,varTrialAvg);
       set(gca,'xlim',[xmin xmax],'ylim',varylim,...
                    'box','off','tickdir','out');
        title('Variance');
   end

   % print the psth, append "name" if it exists
   if exist('name','var')
        print([name,'_psth.pdf'],'-dpdf');
   else
        print('psth.pdf','-dpdf');
   end 

   % plot variance for channels in separate figure if Spiketimes is cell array
  % if iscell(SpikeTimes) 
   %    vH = figure; 
    %    for ch = 1:chans
     %       if chans>6
      %          subplot(3,3,ch);
       %         plot(edge,varTrialAvg(:,ch));
        %        set(gca,'xlim',[xmin xmax],'ylim',varylim,...
         %           'box','off','tickdir','out');
          %      title(['Ch: ',num2str(ch)])
           % elseif chans>4
            %    subplot(3,2,ch);
             %   plot(edge,varTrialAvg(:,ch));
              %  set(gca,'xlim',[xmin xmax],'ylim',varylim,...
               %     'box','off','tickdir','out');
                %title(['Ch: ',num2str(ch)])
 %           elseif chans>2
 %               subplot(2,2,ch); 
 %               plot(edge,varTrialAvg(:,ch));
 %               set(gca,'xlim',[xmin xmax],'ylim',varylim,...
 %                   'box','off','tickdir','out');
 %               title(['Ch: ',num2str(ch)])
 %           else 
 %               subplot(1,ch);
 %               plot(edge,varTrialAvg(:,ch));
 %               set(gca,'xlim',[xmin xmax],'ylim',varylim,...
 %                   'box','off','tickdir','out');
 %               title(['Ch: ',num2str(ch)])
 %           end
 %       end
 %  end



catch            
    disp('Error in file:...problem computing PSTH');
    msg = lasterr;
    disp(msg);
end % catch loop

end
