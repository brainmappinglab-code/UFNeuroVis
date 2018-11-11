function ReadGLR_Exporter( filename, destinationPath, fileFormat, depthDisplay )
% Parses a .glr file using the export tool command line version;
% filename: .glr file name, please provide the complete path.
% destinationPath: destinationFolder, please provide the complete path.
% fileFormat: apm, plx, wav; default: plx
% depthDisplay: the exported file name shows the drive depth as either
%   1. Distance to Target, parameter: distancetotarget
%   2. Distance from Zero, parameter: distancefromzero
%   3. Distance Traveled, parameter: distancetraveled
%   Defaullt: distancetotaget
% USAGE:
% 1. Convert all data to Plexon format (note that 1 plexon file contains
% data of all channels recorded as part of the same snapshot on all tracks). 
% ReadGLR_Exporter( 'C:\Patients\patient.glr', 'C:\DestinationFolder', 'plx', 'distancetotarget' );
% 2. Convert all data to WAVE format: ( note that a file is created for
% each channel, even if channels belong to different snapshots).
% ReadGLR_Exporter( 'C:\Patients\patient.glr', 'C:\DestinationFolder', 'wav', 'distancetotarget' );
%
% The GLR parser provides methods to extract spike and  auxiliary
% waveforms from the .glr file.
% CS, 2018

try
    filename;
catch
    [filename, pathname] = uigetfile('*.glr', 'Patient Record File (*.glr)');
    filename = strcat(pathname, filename);
end
if isempty(filename)
    [filename, pathname] = uigetfile('*.glr', 'Patient Record File (*.glr)');
    filename = strcat(pathname, filename);
end;

if(nargin< 2)
    destinationPath = pwd;
end

if(nargin < 3)
    fileFormat = 'plx';
    %fileFormat = 'wav';
end

if(nargin < 4)
    depthDisplay = 'distancetotarget';
end

exePath = '"C:\Program Files (x86)\FHC\FHC Exporter\exporter_cmd.exe"';
system( [ exePath ' ' filename ' ' destinationPath ' ' fileFormat ' ' depthDisplay] );

end