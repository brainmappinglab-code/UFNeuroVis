function [cv_indexes] = kfoldindexes(Nsamples, Kfolds, varargin)
    %[cv_indexes] = kfoldindexes(Nsamples, Kfolds [, split_method])
    % INPUT
    %   -Nsamples: number of samples
    %   -Kfolds: number of folds
    %   -split_method (optional): the method to distribute the samples in
    %   folds
    %      ~distribute(default): distribute every samples (folds may
    %              not have equal number of elements)
    %      ~equal: divide samples in folds with an equal number of
    %              elements. Excluded samples will have an index 0
    % OUTPUT
    %   -cv_indexes: indexes for each fold. They range from 1 to Kfold
    
    %validation
    if Kfolds<1
        error('kfoldindexes_withlabels: Need at least 1 fold.')
    end
    
    if nargin>2
        split_method=varargin{1};
    else
        split_method='distribute';
    end

    cv_indexes = zeros(Nsamples,1);
    if strcmp(split_method,'distribute')
        % compute fold id's for every sample
        q = ceil(Kfolds*(1:Nsamples)/Nsamples);
        % and permute the folds to balance them
        pq = randperm(Kfolds);
        % randomly assign the id's to the observations of this group
        randInd = randperm(Nsamples);
    elseif strcmp(split_method,'equal')
        %compute the samples to exclude to equally divide samples in folds
        excl_samples=mod(Nsamples, Kfolds);
        q = ceil(Kfolds*(1:Nsamples-excl_samples)/(Nsamples-excl_samples));
        pq = randperm(Kfolds);
        randInd = randperm(Nsamples,Nsamples-excl_samples);
    else
        error ('splitting method not valid');
    end
    cv_indexes(randInd)=pq(q); 
end
