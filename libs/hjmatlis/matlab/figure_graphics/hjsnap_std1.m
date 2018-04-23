function hjsnap_std1(cli_working_folder1,cli_file_name1)

    persistent working_folder1;
    if ~exist('cli_working_folder1','var')
        if isempty(working_folder1)
            working_folder1=pwd;
        end
    else
       %if a value is passed, override folder
       working_folder1=cli_working_folder1;
    end
    
    if ~exist('cli_file_name1','var')
        [file_name1,base_path_snap1] = uiputfile(fullfile(working_folder1,'*.*'), 'Save Plot Snap');
    else
        %if a value is passed, override file
        base_path_snap1=working_folder1;
        file_name1=cli_file_name1;
    end
    
    if isempty(file_name1) || isequal(file_name1,0)
        %if no file was selected, exit
         return
    end
    
    %update working folder
    working_folder1=base_path_snap1;
    if strcmp(file_name1(end-3),'.')
        [~,file_name1,~] = fileparts(file_name1);
    end
    
    if ~exist(base_path_snap1,'dir')
        mkdir(base_path_snap1)
    end
    set(gcf,'PaperPositionMode','auto');
    %iptsetpref('ImshowBorder','tight');
    %set(gcf,'LooseInset',get(gcf,'TightInset'));
    %gcf_noborders2(gcf);
    
    %% trim borders
    %gcf_noborders3(gcf);
    
    %% finally save
    file_name1=fullfile(base_path_snap1,file_name1);

    disp(['images saved as: ' hfullfile(file_name1,'-a') ' .*']);
    saveas(gcf,[file_name1 '.fig']);
    %print([file_name1 '.eps'],'-depsc2', '-painters');
    print([file_name1 '.png'],'-dpng','-r300','-opengl')
    print([file_name1 '.jpg'],'-djpeg','-r300','-opengl')
    %print([file_name1 '.png'],'-dpng','-r0')
    %export_fig([file_name1 '.png']);
    
end