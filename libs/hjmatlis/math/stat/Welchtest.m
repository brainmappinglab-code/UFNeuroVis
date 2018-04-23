function [ hw, wp,wt] = Welchtest(x1,x2,alpha )
% Welch's t test is an adaptation of Student's t-test intended for use with two samples (x1 ,x2 ) having possibly unequal variances
%   
v1=var(x1);v2=var(x2);n1=length(x1);n2=length(x2);
wt=(mean(x1)-mean(x2))/sqrt( (v1/n1)+(v2/n2) );
wnum= ((v1/n1)+(v2/n2))^2;
wden=v1^2/(n1^2*(n1-1))+v2^2/(n2^2*(n2-1));
wdof=wnum/wden;
wp= tpdf(wt,wdof);
hw=wp<alpha;
%
end

