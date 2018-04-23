function That=breakestimatek(y,m,k)

% This file is for the estimation of the break date.
% For the precise description of the procedure,
% see Kim and Perron (2009) equation (7).

% "y" is a column vector of observations.

% m=:1 I1 crash model, 3: I3 mixed model. No changing growth model!

% k is the number of the dummy variables as defined in equation (7).

% The output "That" is the estimated break date.


T=size(y,1);
II=eye(T);

z1=[ones(T,1),(1:T)'];

SSR=zeros(T,1);
for Tb=3:T-2-k;
    D=II(:,Tb+1:Tb+k);
    switch m;
        case 1
            z2search=[zeros(Tb+k,1);ones(T-Tb-k,1)];
            zsearch=[z1,z2search,D];
        case 3
            z2search=[zeros(Tb+k,1);ones(T-Tb-k,1)];
            z3search=[zeros(Tb+k,1);(1:T-Tb-k)'];
            zsearch=[z1,z2search,z3search,D];
    end
    
    ysearch=y-zsearch*((zsearch'*zsearch)\(zsearch'*y));
    ssr=ysearch'*ysearch;
    SSR(Tb,1)=ssr;
end
SSR=SSR(3:T-2-k,1);
[MinSSR,That]=min(SSR);
That=That+2; % The estimate of break date