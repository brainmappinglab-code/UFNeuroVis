function times = spike_times(times_max_spike,sample_rate)
spike_data_length = 64;
number_of_spikes = length(times_max_spike);
times = zeros(number_of_spikes,spike_data_length);

for i = 1:number_of_spikes    
    for j = 1:spike_data_length
        times(i,j) = (times_max_spike(i)-((21-j)/sample_rate));
        %times(i,j) + j + 
    end
end
