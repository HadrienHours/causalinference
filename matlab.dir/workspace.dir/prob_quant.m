function p = prob_quant(X,x,delta)
% This function compute the probability of X = x by taking the average
% frequency on the interval of width 2*delta around x
% INPUTS
%     .X: 1*n matrix : The total sample space
%     .x: scalar: the value which probability we are looking for
%     .delta: scalar: the width of the interval
% OUTPUT:
%     .p: scalar: the probability we are looking for

x1 = abs(X - ones(size(X,1),1)*x) <= delta;
p = size(find(x1>0),1)/size(X,1)/(2*delta);
