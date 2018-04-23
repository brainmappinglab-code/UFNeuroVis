function [ effect_size, S, x1_mean,x2_mean ] = cohen_d( X1, X2 )
%[ effect_size ] = cohen_d( X1, X2 )
%   Detailed explanation goes here
    
    n1=length(X1);
    n2=length(X2);
    
    %mode 1
    if n1~=n2
        [S] = pooledmeanstd(X1,X2);

        x1_mean=mean(X1);
        x2_mean=mean(X2);
        effect_size=abs(x1_mean-x2_mean)/S;
    else
        
        nd=n1;
        
        x1_mean=mean(X1);
        x2_mean=mean(X2);
        %x1_mean=n1/(n1-1)*(X1);
        %x2_mean=n2/(n2-1)*mean(X2);
        S=sqrt(sum((X1-X2).^2)/nd);
        
        effect_size=abs(x1_mean-x2_mean)/S;
        
        
    end
end

