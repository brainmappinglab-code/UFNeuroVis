function newMask = shrinkMask(mask, n, threshold)

newMask = mask;
kernel = ones(n,n,n)/(n*n*n);
newMask.img = convn(mask.img,kernel,'same');
newMask.img(newMask.img < threshold) = 0;
newMask.img(newMask.img >= threshold) = 1;