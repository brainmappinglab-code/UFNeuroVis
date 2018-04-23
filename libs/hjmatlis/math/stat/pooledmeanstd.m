function [pooled_std,pooled_mean,pooled_n] = pooledmeanstd(X1,X2)
% Calculate pooled std and mean (unbiased) from two groups X1 and X2

    n1=length(X1);
    n2=length(X2);
    
    x1_mean=n1/(n1-1)*(X1);
    x2_mean=n2/(n2-1)*mean(X2);
    
    std1=n1/(n1-1)*std(X1);
    std2=n2/(n2-1)*std(X2);
    
    pooled_n=n1+n2;
    pooled_mean=((n1-1)*x1_mean+(n2-1)*x2_mean)/(n1+n2-2);
    pooled_std=sqrt(((n1-1)*std1^2+(n2-1)*std2^2)/(n1+n2-2)); 