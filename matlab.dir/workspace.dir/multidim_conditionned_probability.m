function [ds_c,pr] = multidim_conditionned_probability(ds,dim,value,delta)
%This functions conditionned on a given value the dataset with its
%probability
%input
%       ds = n*(p+1) matrix, n samples, p parameter, probability for each
%       sample
%       dim = vector of k values for the dimension on which conditionned
%       value = vector of k values for the value on which conditionned
%       delta[optional] = values (percentage) to condition on an interval
%       around 'value' parameter
%output
%       ds_c: The dataset obtained by conditioning
%       p:    The probability of the conditioning set

n = size(ds,1);
p = size(ds,2)-1;
k1 = size(dim,2);
k2 = size(value,2);

if nargin < 3
    error('Not enough arguments provided. See help');
elseif nargin == 3
    delta = 0;
end

if k1 ~= k2
    error('Dim and Values must have the same dimension, See help');
else
    k = k1;
end

ds_c = ds;

for i = 1:k
    d = dim(i);
    val = value(i);
    val_l = val-delta*val;
    val_r = val+delta*val;
    %find P(X,Z=z)
    I = find(ds_c(:,d) <= val_r & ds_c(:,d) >= val_l);
    ds_c = ds(I,:);
    ds_c(:,d) = val;
end

%normalize it to obtain P(X/Z=z)(**)
    pr = sum(ds_c(:,end));
    ds_c(:,end) = ds_c(:,end)/pr;
    
%(**) We have Pr(X/Z=z) = Pr(X,Z=z)/Pr(Z=z)
%Pr(Z=z) = sum_{X}Pr(x,z)