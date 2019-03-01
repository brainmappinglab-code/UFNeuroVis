function [spikes1] = int_spikes(spikes,par)
%Interpolates with cubic splines to improve alignment.

w_pre = par.w_pre;
w_post = par.w_post;
ls = w_pre + w_post;
detect = par.detection;
int_factor = par.int_factor;
nspk = size(spikes,1);
extra = (size(spikes,2)-ls)/2;

s = 1:size(spikes,2);
ints = 1/int_factor:1/int_factor:size(spikes,2);

if nspk>0
    intspikes=spline(s,spikes,ints);
else
    iaux = [];
end
switch detect
    case 'pos'
        for i=1:nspk
            [maxi iaux] = max(intspikes(:,(w_pre+extra-1)*int_factor:(w_pre+extra+1)*int_factor),[],2); 
        end
    case 'neg'
        for i=1:nspk
            [maxi iaux] = min(intspikes(:,(w_pre+extra-1)*int_factor:(w_pre+extra+1)*int_factor),[],2); 
        end
    case 'both'
            [maxi iaux] = max(abs(intspikes(:,(w_pre+extra-1)*int_factor:(w_pre+extra+1)*int_factor)),[],2); 
end

iaux = iaux + (w_pre+extra-1)*int_factor -1;
spikes1 = zeros(nspk,ls);
for i=1:nspk
    spikes1(i,:)= intspikes(i,iaux(i)-w_pre*int_factor+int_factor:int_factor:iaux(i)+w_post*int_factor);
end