function dcm2nifti_matlab(source, target)
fprintf('Loading DICOM Directory...');
[~, dcmPatient, ~, ~, ~, ~] = loaddcmdir(source, 0);
fprintf('Done.\n\n');

for studyID = 1:length(dcmPatient.Study)
    fprintf('Currently processing study: %s\n',dcmPatient.Study(studyID).StudyDescription);
    for seriesID = 1:length(dcmPatient.Study(studyID).Series)
        dcmSeries = dcmPatient.Study(studyID).Series(seriesID);
        fprintf('\tSeries ID: %s --- %s\n',dcmSeries.Modality,dcmSeries.SeriesDescription);
        if length(dcmSeries.ImageNames) > 100
            NifTi = constructNifTi(dcmSeries);
            filename = sprintf('%s_%s',dcmSeries.Modality,dcmSeries.SeriesDescription);
            filename(notAlphabet(filename)) = '_';
            save_nii(NifTi, [target,filesep,filename,'.nii']);
        end
    end
end
fprintf('Done.\n\n');

function NifTi = constructNifTi(dcmSeries)
img = [];
sliceLocation = zeros(length(dcmSeries.ImageNames),1);
for n = 1:length(dcmSeries.ImageNames)
    info = dicominfo(dcmSeries.ImageNames{n},'UseDictionaryVR',true);
    slice = dicomread(dcmSeries.ImageNames{n});
    if strcmpi(dcmSeries.Modality,'MR')
        sliceLocation(n) = info.ImagePositionPatient(3);
    elseif strcmpi(dcmSeries.Modality,'CT')
        sliceLocation(n) = info.ImagePositionPatient(3);
    else
        sliceLocation(n) = n;
    end
    if isempty(img)
        img = single(zeros(size(slice,2),size(slice,1),length(dcmSeries.ImageNames)));
        if isfield(info,'PixelSpacing') && isfield(info,'SliceThickness')
            dimension = [info.PixelSpacing',info.SliceThickness];
        else
            dimension = [1 1 1];
        end
    end
    img(:,:,n) = slice(end:-1:1,end:-1:1)';
end
if mean(diff(sliceLocation)) < 0
    img = img(:,:,end:-1:1);
end
NifTi = make_nii(img,dimension,round(info.ImagePositionPatient' ./ dimension),16);

function result = notAlphabet(string)
result = false(length(string));
for n = 1:length(string)
    result(n) = ~isalpha_num(string(n));
end