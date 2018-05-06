

[user1,pwd1]=get_auth([]);

host_name1='hpg2.rc.ufl.edu';
ssh2_conn = ssh2_config(host_name1,user1,pwd1);
clear pwd1;
clear user1;
%%


ssh2_conn = ssh2_command(ssh2_conn, 'module load screen;screen -ls');
% or to suppress the output from being displayed I can run
% Reusing Advanced Connection: 
ssh2_conn = ssh2_command(ssh2_conn, 'ls -la *ninjas*',1);
% the output is available in cell array ssh2_conn.command_result.
% if I want to run multiple commands, I can just string them together with 
% the command seperator, the semicolon
% RETRIEVING THE COMMAND RESPONSE:
% the command response can be accessed easily through the
% ssh2_command_response() method. 
command_response = ssh2_command_response(ssh2_conn);
% to access the first response, one can use:
command_response{1}
% to get the number of lines returned
size(command_response,1);


% Multiple Commands, Advanced Connection: 
ssh2_conn = ssh2_command(ssh2_conn, 'ls *dogs*; ls *cats*',1);
% when I'm done, I need to make sure to close an advanced connection
% Close Advanced Connection: 
ssh2_conn = ssh2_close(ssh2_conn);

