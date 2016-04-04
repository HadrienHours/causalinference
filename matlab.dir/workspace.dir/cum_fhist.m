function v = cum_fhist(histo,edges,x)
% This function takes as input an histogram as a list of p-1 values
% corresponding to number of samples fallen in the bins defined by the list
% of p edges and a value x and output the corresponding cumulative density
% evaluated in x.

% INPUTS
%     histo = 1*(p-1) vector: number of samples fallen into the (p-1) bins
%     edges = 1*p vector: edges of the p-1 bins
%     x = scalar : value to evaluate
% OUTPUT
%     v = scalar : the value of the cumulative estimated density continous function evaluated at x

nbins = size(histo,2);
nedges = size(edges,2);

v = 0;

if nbins ~= (nedges -1)
    error('The number of bins is %d while the number of edges is %d\n',nbins,nedges)
end

if x > edges(end)
    error('The value is out of histogram range (%g > %g)\n',x,edges(end));
end

binw = edges(2) - edges(1);
dist = x-edges(1);

h = histo/(sum(histo)*binw);

% We look for the bin in which the value falls. If it falls on the edge of
% a bin it goes in the one after unless it's the maximal value
if x == edges(end)    
    binidx = size(histo,2);
elseif dist == 0 || rem(dist,binw) == 0
    binidx = dist/binw+1;
else
    binidx = min(ceil(dist/binw),size(histo,2));
end

for i=1:(binidx-1)
    v=v+h(i) ;
end
% fprintf('Before adding the last value the cumulative function evaluated for sample %g is:\n',x)    
v = v*binw;
% pause

r = find(edges <= x);
ed = edges(r(end));
distx = x- ed;
r = v+distx*h(binidx);
% fprintf('The edges:\n')
% edges
% fprintf('Histogram:\n')
% h
% fprintf('Value to be returned is: %g = %g + %g*%g (final = previous + dist * histo)\n',r,v,distx,h(binidx));
% pause
v = r;
