function hjimg_dcm2nii(Patient_DIR, NifTi_DIR)
    %matlab wrapper to call the DICOM to NifTi converter based on Unix tools
    % Enrico Opri 2018

    if ~any(strcmp(Patient_DIR(end),{'\','/'}))
        Patient_DIR = [Patient_DIR,''];
    end
    if ~any(strcmp(NifTi_DIR(end),{'\','/'}))
        NifTi_DIR = [NifTi_DIR,'/'];
    end

    
    if isempty(getenv('NEURO_VIS_PATH_UNIX'))
        NEURO_VIS_PATH_UNIX = getenv('NEURO_VIS_PATH');
    else
        NEURO_VIS_PATH_UNIX = getenv('NEURO_VIS_PATH_UNIX');
    end
    
    if ~any(strcmp(NEURO_VIS_PATH_UNIX(end),{'\','/'}))
        NEURO_VIS_PATH_UNIX = [NEURO_VIS_PATH_UNIX,'/'];
    end
    
    %hjimg__dcmsort = ['"',NEURO_VIS_PATH_UNIX,'dependencies/unixDCMtoNIFTI/hjimg__dcmsort"'];
    %hjimg__convert_tonii = ['"',NEURO_VIS_PATH_UNIX,'dependencies/unixDCMtoNIFTI/hjimg__convert_tonii"'];
    hjimg__dcmsort = [NEURO_VIS_PATH_UNIX,'dependencies/unixDCMtoNIFTI/hjimg__dcmsort'];
    hjimg__convert_tonii = [NEURO_VIS_PATH_UNIX,'dependencies/unixDCMtoNIFTI/hjimg__convert_tonii'];
    
    tempfolder1=hfullfile(fileparts(fileparts(NifTi_DIR)),'DICOMSORT/','-unix');

    %creating temp folder to store sorted DICOMs
    %mkdir(tempfolder1);
    
    %sort DICOM folders
    cmd1=[hjimg__dcmsort ' -D ' Patient_DIR ' -o ' tempfolder1];
    if isunix
        system(cmd1);
    else
        %use unix subsystem
        system(['wsl ' cmd1]);
    end
    
    %creating temp folder to store NIFTI files
    %mkdir(NifTi_DIR);
    
    %convert DICOM to NIFTI
    cmd1=[hjimg__convert_tonii ' ' NifTi_DIR ' ' tempfolder1];
    if isunix
        system(cmd1);
    else
        %use unix subsystem
        system(['wsl ' cmd1]);
    end
end