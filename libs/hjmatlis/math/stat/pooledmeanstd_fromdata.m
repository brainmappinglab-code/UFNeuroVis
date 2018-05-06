function [npool,meanpool,stdpool] = pooledmeanstd(X1,X2)
% Calculate pooled n, mean and std from n, mean and std of two groups
%  (to calculate it to N groups (N>2), repeat it N-1 times)
%
% [npool,meanpool,stdpool] = pooledmeanstd(n1,mean1,std1,n2,mean2,std2)
% 
% downloaded from http://www.mathworks.com/matlabcentral/fileexchange/37233-pooled-mean-and-standard-deviation
%
% based on http://www.talkstats.com/showthread.php/7130-standard-deviation-of-multiple-sample-sets
%
% Example:
%
%     n1=32;
%     sample1 = randi(100,n1,1);
%     mean1= mean(sample1);
%     std1= std(sample1);
%     n2=20;
%     sample2 = randi(100,n2,1);
%     mean2= mean(sample2);
%     std2= std(sample2);
%     n3=9;
%     sample3 = randi(100,n3,1);
%     mean3= mean(sample3);
%     std3= std(sample3);
%     pool_sample=[sample1;sample2;sample3];
%     meanpool_real= mean(pool_sample);
%     stdpool_real= std(pool_sample);
% 
%     [npooltemp,meanpooltemp,stdpooltemp] = pooledmeanstd(n1,mean1,std1,n2,mean2,std2);
%     [npool_estimated,meanpool_estimated,stdpool_estimated] = pooledmeanstd(npooltemp,meanpooltemp,stdpooltemp,n3,mean3,std3);
% 
%     disp(['meanpool_real=',num2str(meanpool_real),' meanpool_estimated=',num2str(meanpool_estimated)])
%     disp(['stdpool_real=',num2str(stdpool_real),' stdpool_estimated=',num2str(stdpool_estimated)])

n1=length(X1)
mean1=mean(X1)
std1=std(X1)
n2=length(X2);
mean2=mean(X2);
std2=std(X2);
[npool,meanpool,stdpool] = pooledmeanstd(npooltemp,meanpooltemp,stdpooltemp,n3,mean3,std3);

    n1=length(X1);
    n2=length(X2);
    
    u1=mean(X1);
    u2=mean(X2);
    
    std1=std(X1);
    std2=std(X2);
    
    pooled_std=sqrt(((n1-1)*std1^2+(n2-1)*std2^2)/(n1+n2-2));