function results = adftest_mine(x)
% 
% ADF test optimal lag length selection. Three alternative model specifications: Basic AR, AR w/drift, AR w/drift + trend
% MEMO: null hypothesis is UR given alpha; hx=0: failure to reject null ==> series is nonstationary, hx=1: rejection of null ==> series is stationary
%
% INPUT:
% x:(T x 1) time series
%
% OUTPUT:
% results: (2 x 3) matrix. Row 1 reports nonrejection (0) rejection (1) of null hypothesis by the three alternative model specifications, 
% Row 2 reports optimal lag selected
%   
% 
   maxlag=25;
   oplbic = oplag_arpyule(x,maxlag);
   [ha,~,~,~,rega] = adftest(x,'Lags',0:oplbic); [~,ia]=min([rega.BIC]); % Basic AR
   [hd,~,~,~,regd] = adftest(x,'model','ARD','lags',0:oplbic); [~,id]=min([regd.BIC]); % Drift
   [ht,~,~,~,regt] = adftest(x,'model','TS','lags',0:oplbic); [~,it]=min([regt.BIC]); % Drift & trend
   results=[ha(ia),hd(id),ht(it);ia id it];
   %
end

