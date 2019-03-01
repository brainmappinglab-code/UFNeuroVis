function [neuron] = FiringRateAvg(cluster_class,spiketime)
neuron_cnt = max(cluster_class(:,1));
T = spiketime(1,length(spiketime)) - spiketime(1,1);
for i = 1:neuron_cnt
    neuron(i).spikes = find(cluster_class(:,1) == i);
    neuron(i).firerate = length(neuron(i).spikes)/T;
end
%Calculate avg firing rate of all neurons in data. 