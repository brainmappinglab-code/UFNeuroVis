function status = mer_to_xls_setup()
%MER_TO_XLS_SETUP Summary of this function goes here
%   Detailed explanation goes here

status = 1;

%build data folder
if ~exist('data','dir')
    fprintf(['creating data folder' newline])
    mkdir data;
end

%build headers
if ~exist('data\Headers.mat','file')
    fprintf(['creating Headers.mat' newline])
    create_headers();
end

end

