function dcm2niftix( source, target )
%Convert DICOM images to NifTi using DCM2NIIX.exe
%   dcm2niftix( source, target )
%       source is the path to the DICOM images
%       target is the path to the output NifTi files
%
%   J. Cagle, University of Florida, 2017

SourcePath = getenv('NEURO_VIS_PATH');
if ~strcmpi(SourcePath(end),filesep)
    SourcePath = [SourcePath,filesep];
end
dcm2niix = ['"',SourcePath,'dependencies\dcm2nii\dcm2niix.exe"'];
cmd=[dcm2niix, ' -z n -x n -i y -b n -f "%p_%t_%s"', ' -o "', target, '" "', source, '"'];

if ~ispc
    system(['bash -c "', cmd, '"']);
else
    system(cmd);
end

end

