function [mr,ct]=removePaddedZeroes(Processed_DIR,mr,ct)

%% Load in data

if nargin == 1
    mr=load_nii(fullfile(Processed_DIR,'anat_t1.nii'));
    ct=load_nii(fullfile(Processed_DIR,'rpostop_ct.nii'));
end

%% Save a copy of the original anat_t1
% The CT is already modified, so a copy of the original already exists

save_nii(mr,fullfile(Processed_DIR,'anat_t1_original.nii'));

%% Modify files to remove all zeroes

img_mr=mr.img;
img_ct=ct.img;

% X
x_dim = size(img_mr,1);
ind_to_remove_x=false(x_dim,1);

for i=1:floor(x_dim/2)
    if all(all(img_mr(i,:,:) == 0)) && all(all(img_mr(end-i+1,:,:) == 0)) && ...
            all(all(img_ct(i,:,:) == 0)) && all(all(img_ct(end-i+1,:,:) == 0))
        ind_to_remove_x([i,end-i+1])=true;
    end
end

% Y
y_dim = size(img_mr,2);
ind_to_remove_y=false(y_dim,1);

for i=1:floor(y_dim/2)
    if all(all(img_mr(:,i,:) == 0)) && all(all(img_mr(:,end-i+1,:) == 0)) && ...
            all(all(img_ct(:,i,:) == 0)) && all(all(img_ct(:,end-i+1,:) == 0))
        ind_to_remove_y([i,end-i+1])=true;
    end
end

% Z
z_dim = size(img_mr,3);
ind_to_remove_z=false(z_dim,1);

for i=1:floor(z_dim/2)
    if all(all(img_mr(:,:,i) == 0)) && all(all(img_mr(:,:,end-i+1) == 0)) && ...
            all(all(img_ct(:,:,i) == 0)) && all(all(img_ct(:,:,end-i+1) == 0))
        ind_to_remove_z([i,end-i+1])=true;
    end
end

%% Modify the two Nifti files 

img_mr(ind_to_remove_x,:,:)=[];
img_mr(:,ind_to_remove_y,:)=[];
img_mr(:,:,ind_to_remove_z)=[];

mr.img=img_mr;

mr.hdr.dime.dim(2:4)=size(img_mr);

mr.hdr.hist.srow_x(4) = mr.hdr.hist.srow_x(4) + sum(ind_to_remove_x)/2;
mr.hdr.hist.srow_y(4) = mr.hdr.hist.srow_y(4) + sum(ind_to_remove_y)/2;
mr.hdr.hist.srow_z(4) = mr.hdr.hist.srow_z(4) + sum(ind_to_remove_z)/2;

mr.hdr.hist.originator(1) = mr.hdr.hist.originator(1) - sum(ind_to_remove_x)/2;
mr.hdr.hist.originator(2) = mr.hdr.hist.originator(2) - sum(ind_to_remove_y)/2;
mr.hdr.hist.originator(3) = mr.hdr.hist.originator(3) - sum(ind_to_remove_z)/2;

img_ct(ind_to_remove_x,:,:)=[];
img_ct(:,ind_to_remove_y,:)=[];
img_ct(:,:,ind_to_remove_z)=[];

ct.img=img_ct;

ct.hdr.dime.dim(2:4)=size(img_ct);

ct.hdr.hist.srow_x(4) = ct.hdr.hist.srow_x(4) + sum(ind_to_remove_x)/2;
ct.hdr.hist.srow_y(4) = ct.hdr.hist.srow_y(4) + sum(ind_to_remove_y)/2;
ct.hdr.hist.srow_z(4) = ct.hdr.hist.srow_z(4) + sum(ind_to_remove_z)/2;

ct.hdr.hist.originator(1) = ct.hdr.hist.originator(1) - sum(ind_to_remove_x)/2;
ct.hdr.hist.originator(2) = ct.hdr.hist.originator(2) - sum(ind_to_remove_y)/2;
ct.hdr.hist.originator(3) = ct.hdr.hist.originator(3) - sum(ind_to_remove_z)/2;

%% Save them without the padded zeroes

save_nii(mr,fullfile(Processed_DIR,'anat_t1.nii'));
save_nii(ct,fullfile(Processed_DIR,'rpostop_ct.nii'));

%% Don't return variables if they aren't requested

if nargout == 0
    clear mr ct
end

end