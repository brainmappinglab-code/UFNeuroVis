%% Connecting MATLAB to R 
%FOLLOW THESE INSTRUCTIONS TO INSTALL
%http://homepage.univie.ac.at/erich.neuwirth/php/rcomwiki/doku.php?id=wiki:how_to_install
%
% The statistical programming language R has a COM interface. We can use
% this to execute R commands from within MATLAB.

%% Connect to an R Session
openR

evalR('library(pwr)');
evalR('library(effsize)');
X1=[100,100,88,95,78];
X1=[82,90,55.5,65.5,66];
% Push data into R
putRdata('X1',X1)
putRdata('X2',X2)

%% Run a simple R command
evalR('cohen.d(X1,X2)');
evalR('b=b$estimate');
b = getRdata('b')

%% Run a series of commands and grab the result
evalR('b <- a^2');
evalR('c <- b + 1');
c = getRdata('c')

%% Close the connection
closeR
