function [ClusterClass,Index] = SpikeAndClus(data)
%Use of Get_spikes followed by Do_Clustering to retrieve clusters 
%and spikes for firing rate data. 
%Outputs ClusterClass N by 2 matrix in with column 1 indicating the neuron
%the spike belongs to and column 2 its index in the (N = # of spikes in data)

VarName = GetVarName(data); %convert data's variable name to string for use with save function
RDataFileName = strcat(VarName); 
save(RDataFileName,VarName)
RDataPath = strcat(VarName,'.mat');
SpikeIn = {(RDataPath)};
Get_spikes(SpikeIn);

SpikePath = strcat(VarName,'_spikes.mat');
ClusterIn = {SpikePath};
Do_clustering(ClusterIn);

ClusterData = strcat('times_',VarName,'.mat');
load(ClusterData,'cluster_class');
load(SpikePath,'index');
Index = index;
ClusterClass = cluster_class;

delete([VarName '_' VarName '.dg_01.lab']);
delete([VarName '_' VarName '.dg_01']);
delete('cluster_results.txt');
delete('spc_log.txt');
delete([VarName '_spikes.mat']);
delete([VarName '.mat']);
delete(['times_' VarName '.mat']);
delete(['fig2print_' VarName '.png']);
end