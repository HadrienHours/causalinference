function v = fhist(histo,edges,x)
% This function takes as input an histogram as a list of p-1 values
% corresponding to number of samples fallen in the bins defined by the list
% of p edges and a value x and output the corresponding value h(x). h being
% the step density function corresponding the continuous estimate of the
% samples density function.

% INPUTS
%     histo = 1*(p-1) vector: number of samples fallen into the (p-1) bins
%     edges = 1*p vector: edges of the p-1 bins
%     x = scalar : value to evaluate
% OUTPUT
%     v = scalar : the value of the estimated density continous function evaluated at x

nbins = size(histo,2);
nedges = size(edges,2);

if nbins ~= (nedges -1)
    error('The number of bins is %d while the number of edges is %d\n',nbins,nedges)
end

binw = edges(2) - edges(1);
dist = x-edges(1);

% We look for the bin in which the value falls. If it falls on the edge of
% a bin it goes in the one after
if dist == 0 || rem(dist,binw) == 0
    binidx = dist/bin+1;
else
    binidx = ceil(dist/binw);
end

v = histo(binidx)/(sum(histo)*binw);