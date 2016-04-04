function p = probhistbin(S,edges,h,N)
% This function gives the probabilities of a given samples by finding the
% corresponding bin in the corresponding histogram in which this sample
% falls. Then the probability of this bin is given to the sample. The
% probability is computed as : Number of samples from the original dataset
% that falls into this bin divided by the total number of samples. As we
% are trying to modelize a continuous distribution and so that, when
% integrating on the corresponding histogram, it sums to one we divide this
% result by the bin width.

% INPUTS
%     S : a scalar being the sample we want to find the probability
%     edges : a 1*p vector representing the edges of the bins of the corresponding histograms
%     h : a 1*(p-1) vector representing the number of samples falling in each interval in the original dataset,
%     N : Number of samples in the original dataset
% 
% OUTPUT
%     p : the corresponding probability of the sample, being its value on the normalized histogram function
    

p = size(edges,2);
nint = p-1;

% fprintf('The size of the histogram is %d while the edges list size is %d \n',size(h,2),p);

%the interval width is supposed to be constant
binw = edges(2) - edges(1);

%interval in which the sample falls
% fprintf('Look for the bin of the value %g with bin width of %g\n',S, binw);
r = (S-edges(1))/binw;
if ( r == 0)
    idx=1;
else
    idx = ceil((S-edges(1))/ binw);
end


% fprintf('The bin found is the %dth\n',idx);

if(idx > nint)
    fprintf('The histogram:\n')
    h
    fprintf('The list of edges:\n')
    edges
    error('The sample %d is outside the range with bin number %d', S, idx)
end


p = h(idx)/(N*binw);