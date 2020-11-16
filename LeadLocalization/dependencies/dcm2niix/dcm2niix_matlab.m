function dcm2niix_matlab(source,target)
%% dcm2niix_matlab(source,target)
%   
%  Updated to the newest version of dcm2niix, which does not struggle with image
%  conversion and no longer produces image names with '_Eq' as a suffix. Consistent with
%  clinical usage for checking images. Currently only supported for Windows computers
%
%   Inputs:
%    - source: Absolute path to the DICOM images folder; specifically the root folder
%       where the DICOMDIR file resides
%    - target: Absolute path to the output NifTi folder
%
%   Outputs:
%    Command outputs defining the status of conversion, and a number of .nii files in the
%     target folder.
%
%  B. Parks, University of Florida, 2020

source_path=getenv('NEURO_VIS_PATH');

if ~strcmpi(source_path(end),filesep)
    source_path = [source_path,filesep];
end

str_dcm2niix = ['"',source_path,'dependencies',filesep,'dcm2niix',filesep,'dcm2niix.exe"'];

% str_cmd=[str_dcm2niix, ' -z n -x y -i y -b n -f "%p_%t_%s"', ' -o "', target, '" "', source, '"'];
str_cmd=[str_dcm2niix, ' -z n -x n -i y -b n -f "%p_%t_%s"', ' -o "', target, '" "', source, '"'];

system(str_cmd);

end

