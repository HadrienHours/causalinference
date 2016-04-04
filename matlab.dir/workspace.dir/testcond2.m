function [results] = testcond2(ds,listxyz,alpha,N,l)
%This function operates all the conditional test of x indep y cond z with
%the conditional hsic nloop test
%inputs
%       ds : the dataset containing all the samples
%       listxyz : a list of r*s sequence of numbers, the first colum being
%       the x, the second the y and the rest the z
%       alpha: significance level for independence test
%       N: the size of the subsets taken for testing the independences
%       l: the number of loops for independence tests
%output
%       results: r*2 with the outcome (0 or 1) and percentage of positive
%       tests

if nargin ~= 5
    error('Wrong number of arguments, see help');
end

n = size(ds,1);
p = size(ds,2);
r = size(listxyz,1);
s = size(listxyz,2);

if max(max(listxyz)) > p
    error('Some parameters index are bigger than the number of parameters')
end

if s < 2
    error('The list of independences to test must contain at least two variables')
end

results = zeros(r,s+2);

for i = 1:r
    fprintf('Starting test %d on a total of %d\n',i,r)
    results(i,1:s) = listxyz(i,:);
    if s >=3
        [o,p] = indtestimpl_nloop_sval(listxyz(i,1),listxyz(i,2),listxyz(i,3:end),ds,alpha,N,l);
    else
        [o,p] = indtestimpl_nloop_sval(listxyz(i,1),listxyz(i,2),[],ds,alpha,N,l);
    end
    results(i,s+1:end) = [o,p];
    fprintf('Finished test %d on a total of %d\n',i,r)
end