function plot_traj_data(aH,ApmDataTable,DbsData)
%PLOT_TRAJ_DATA Summary of this function goes here
%   Detailed explanation goes here

cla(aH,'reset');

OG_ApmDataTable = ApmDataTable;

hold(aH,'on');

f = ancestor(aH,'figure');
cell_type_filter_menu = findobj(f,'Tag','cell_type_filter_menu');
cell_type_filter_value = get(cell_type_filter_menu,'Value');
duration_filter_menu = findobj(f,'Tag','duration_filter_menu');
duration_filter_value = get(duration_filter_menu,'Value');

%get number of passes
nPass = size(ApmDataTable,2);

%filter out cell types that don't match selection
if (cell_type_filter_value ~= 1)
    filter = num2str(cell_type_filter_value - 1);
    for iPass = 1:nPass
        N = size(ApmDataTable{iPass},1);
        toDelete = [];
        for i = 1:N
            match = ApmDataTable{iPass}.match(i);
            if (match == 0)
                toDelete = [toDelete i];
            elseif DbsData.data1{match,3,iPass} ~= filter
                toDelete = [toDelete i];
            end
        end
        ApmDataTable{iPass}(toDelete,:) = [];
    end
end

%filter out durations
if (duration_filter_value ~= 1)
    for iPass = 1:nPass
        N = size(ApmDataTable{iPass},1);
        toDelete = [];
        for i = 1:N
            duration = ApmDataTable{iPass}.duration(i);
            switch duration_filter_value
                case 2 % '> 1s'
                    if duration < 1
                        toDelete = [toDelete i];
                    end
                case 3 % '> 5s'
                    if duration < 5
                        toDelete = [toDelete i];
                    end
                case 4 % '> 10s'
                    if duration < 10
                        toDelete = [toDelete i];
                    end
                otherwise
                    error('Value of duration_filter_menu is undefined. Define in plot_traj_data')
            end
        end
        ApmDataTable{iPass}(toDelete,:) = [];
    end
end

for iPass = 1:nPass
    fprintf('plotting pass %d\n',iPass)
    lH = plot3(aH,ApmDataTable{iPass}.x,ApmDataTable{iPass}.y,ApmDataTable{iPass}.z,'-s');
    set(lH,'hittest','off');
end

%label axes of traj_axes
xlabel(aH,'LT');
ylabel(aH,'AP');
zlabel(aH,'AX');

grid(aH,'on');

ApmDataTable = OG_ApmDataTable;

%set the button down function of traj_axes
set(aH,'ButtonDownFcn',{@mer_plot_callback,ApmDataTable});

