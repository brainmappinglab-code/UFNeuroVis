function [cv_indexes] = kfoldindexes_withlabels(labels, Kfolds, varargin)
%[cv_indexes] = kfoldindexes_withlabels(labels, Kfolds [, split_method])
% INPUT
%   -labels
%   -Kfolds: number of folds (need to be at least 1)
%   -split_method (optional): the method to distribute the samples in
%   folds
%      ~distribute(default): distribute every samples (folds may
%              not have equal number of elements)
%      ~equal: divide samples in folds with an equal number of
%              labels across the folds. Excluded samples will have an index 0
%      ~equallbl: divide samples in folds with an equal number of
%              labels in each folder and across all the folds.
%              Excluded samples will have an index 0
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
    
    %Nsamples is number of labels
    cv_indexes = zeros(length(labels),1);
    if strcmp(split_method,'distribute')
        lbl_typs=unique(labels);

        for lbl_i=1:length(lbl_typs)
            lbl_sel=(labels==lbl_typs(lbl_i));
            cv_idxs=zeros(sum(lbl_sel),1);
            [randInd2, pq2, q2] = kfoldindexes_distribute(sum(lbl_sel), Kfolds);
            cv_idxs(randInd2)=pq2(q2);
            cv_indexes(lbl_sel)=cv_idxs; 
        end

    elseif strcmp(split_method,'equal')
        lbl_typs=unique(labels);

        for lbl_i=1:length(lbl_typs)
            lbl_sel=(labels==lbl_typs(lbl_i));
            cv_idxs=zeros(sum(lbl_sel),1);
            [randInd2, pq2, q2] = kfoldindexes_equal(sum(lbl_sel), Kfolds);
            cv_idxs(randInd2)=pq2(q2);
            cv_indexes(lbl_sel)=cv_idxs; 
        end
    elseif strcmp(split_method,'equallbl')
        lbl_typs=unique(labels);
        min_subs=length(labels);
        for lbl_i=1:length(lbl_typs)
            sub_len=sum(labels==lbl_typs(lbl_i));
            if min_subs>sub_len
                min_subs=sub_len;
            end
        end

        for lbl_i=1:length(lbl_typs);
            lbl_sel=(labels==lbl_typs(lbl_i));
            pos_sub=find(lbl_sel);
            pos_sub=pos_sub(randperm(length(pos_sub),min_subs));
            
            cv_idxs=zeros(length(pos_sub),1);
            [randInd2, pq2, q2] = kfoldindexes_equal(length(pos_sub), Kfolds);
            cv_idxs(randInd2)=pq2(q2);
            cv_indexes(pos_sub)=cv_idxs; 
        end
    else 
        error ('splitting method not valid');
    end
    
end

function [randInd, pq, q] = kfoldindexes_distribute(nsampl, kflds)
    % compute fold id's for every sample
    q = ceil(kflds*(1:nsampl)/nsampl);
    % and permute the folds to balance them
    pq = randperm(kflds);
    % randomly assign the id's to the observations of this group
    randInd = randperm(nsampl);
end 

function [randInd, pq, q] = kfoldindexes_equal(nsampl, kflds)
    %compute the samples to exclude to equally divide samples in folds
    excl_samples=mod(nsampl, kflds);
    q = ceil(kflds*(1:nsampl-excl_samples)/(nsampl-excl_samples));
    pq = randperm(kflds);
    randInd = randperm(nsampl,nsampl-excl_samples);
end
