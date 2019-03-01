function TimeHistIndex = GetTimeHistIndex(ClusterClass,NeuronNumber)

i = find(ClusterClass(:,1) == NeuronNumber);

for i = i
    TimeHistIndex = ClusterClass(i,2)';
end

end

%Function to pull out spike indices for individual neurons group to plot on histogram .