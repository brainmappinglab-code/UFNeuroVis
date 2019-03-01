function [psth,trialAvg] = GetTimeHistData(binwidth,Datatime,index)
%index = from SpikeAndClus 
%Datatime = time variable from raw data
%bin_width = bin (ms) for PSTH calculation. Default = 10 (ms).

index = index/1000; %convert to seconds
DataTimeLength = (Datatime(length(Datatime))-Datatime(1)); %calculate time of recording in seconds
Spiketimes = {index};
[psth,trialAvg] = CalculatePSTH(Spiketimes,0,0,DataTimeLength,binwidth,'',0);
end

