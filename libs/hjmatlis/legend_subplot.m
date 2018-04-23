%This script solves matlab problem of creating one legend 
% for many subplots in one figure 
% for example
%     we will create a sample of two subplots and one legend 
% use your legends instead of x1 and x2 and as many as you need 
% for example I will plot two sample series x1 and x2 in 2 sub-plots 
subplot(1,2,1);
x1=[15 25 35];
plot(x1,'ro-');
hold on
x2=[55 1 60];
plot(x2,'bx:');
subplot(1,2,2);
x1=[1 2 3];
plot(x1,'ro-');
hold on
x2=[6 5 4];
plot(x2,'bx:');
% add  the customized legend
% Use h1=legend('x1','x2') if you want a vertical legend
h1=legend('x1','x2','Orientation','horizontal');
% Retrieve the position of the legend
p = get(h1,'Position');
% p(1) is the location along the x-axis[0,0.5,0.9] for left, center, right 
% respectively
p(1) = 0;
% p(2) is the location along the y-axis [0,0.5,0.9] for bottom, center, top 
% respectively
p(2) = 0.5;
% the two zeros of p(1) and p(2) will put the legend in the bottom 
% left of the figure 
% the following table shows guidlines for using p(1) and p(2) in most 
% common  problems 

% p(1)	p(2)	Vertical alignment	Horizontal alignment
% 0       0           Bottom              Left
% 0.5     0           Bottom              Center
% 0.9     0           Bottom              Right
% 0       0.5         Center              Left
% 0.5     0.5         Center              Center
% 0.9     0.5         Center              Right
% 0       0.9         Top                 Left
% 0.5     0.9         Top                 Center
% 0.9     0.9         Top                 Right
% set the new location of the legend 
set(h1,'Position',p);

% For inquires and problems 
% contact Eng. Ahmed Badr 
% amabadr@idsc.net.eg
% eng.badr86@gmail.com
% 0020118380567