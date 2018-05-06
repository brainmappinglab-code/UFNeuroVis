function fileList = lfrdir(varargin)
  %fileList = lfrdir(dirPath[, typepath])
  %List File Recursive Dir
  % get all files recursively inside specified folders
  %
  %   dirPath   directory to scan
  %   typepath  'relative' (-r) or 'full' (-f)
  %
  % 
  % by Opri Enrico
  % idea from unknown author

  if length(varargin)>2
    error('too much arguments');
    return;
  end

  %OPTIONS MODULE
  option_found = @(x, y) sum(strcmp(x, y))>0;

  %options available
  options_available_r = {'relative','-r'};
  options_available_f = {'full','-f'};
  num_option_found = 0;
  %defaults
  basepath = ''; %default 'relative'

  if option_found(options_available_r, varargin)
    basepath = '';
    num_option_found = num_option_found + 1;
  elseif option_found(options_available_f, varargin)
    basepath = pwd;
    num_option_found = num_option_found + 1;
  elseif length(varargin)>1
    error('one or more options are not valid');
    return;
  end

  %get base dirpath
  if length(varargin)>num_option_found
    dirPath = varargin{1};
    dirData = dir(dirPath);      %# Get the data for the current directory
  else
    dirPath = '';
    dirData = dir;      %# Get the data for the current directory
  end


  dirIndex = [dirData.isdir];  %# Find the index for directories
  fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
  if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(basepath, dirPath,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
  end
  subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirPath,subDirs{iDir});    %# Get the subdirectory path
    if nargin>1
        fileList = [fileList; lfrdir(nextDir, varargin{end})];  %# Recursively call lfrdir with same options
    else
        fileList = [fileList; lfrdir(nextDir)];  %# Recursively call lfrdir with same options
    end
  end

end
