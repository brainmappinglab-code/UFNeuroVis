function [DbsData,CrwData] = build_mer_structs(dbs,crw)
%BUILD_MER_STRUCTS Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    [file,path] = uigetfile('*.dbs','Dbs File');
    dbs = [path file]
    [file,path] = uigetfile('*.crw','Crw File');
    crw = [path file]
end

% load DbsData
DbsData = load(dbs,'-mat');

% load CrwData
CrwData = extract_crw_data(crw);

end

