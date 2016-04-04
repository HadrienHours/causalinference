function [dsc] = remove_extremes(ds,perc)
%   This function is removing the extreme for each direction so that the
%   total number of samples removed is approximately the percentage p
% INPUTS
%       ds: n*p matrix, dataset of n samples recording p parameter
%       p: scalar, percentage of values to be removed (to the whole
%       dataset)
% OUTPUT
%       dsc:(n*(1-perc))*p matrix being the original ds w/o extreme values

if nargin ~= 2
    error('The function requires two arguments. See help')
end

if perc < 0.0 || perc >= 1.0
    error('The second argument must be a percentage ( \in [0.1[)')
end

n = size(ds,1);
p = size(ds,2);

percs = perc/p;

dsc = ds;

for i = 1:p
    Z1 = quantile(dsc(:,i),percs/2);
    Z2 = quantile(dsc(:,i),(1-percs/2));
    I = find(dsc(:,i) >= Z1 & dsc(:,i) <= Z2);
    dsc = dsc(I,:);
end