% Description : This function takes each dimension separately and use the
% given method to compute the marginal cdf. The output is an increasing
% ordered cdf function 

function [cdfs] = margicdf(M,methodk)
% INPUT
%             M:        n*p matrices n samples of p dimensions
%             methodk:    normal,box,triangle or epanechnikov
% OUTPUT
%             cdfs:     1*p cell of n*2 matrices representing 
%                       the cdf value of each sample

%dimensions
    n = size(M,1);
    p = size(M,2);
    
 
 %Get the cdfs
    C = zeros(n,p);
    for i=1:p
        C(:,i) = ksdensity(M(:,i),M(:,i),'function','cdf','kernel',methodk);
    end
    
 % Order the values and link them to their corresponding cdf values
    cdfs = cell(1,p);
    for i = 1:p
        [v,idx] = sort(M(:,i));
        cdfs{i} = [M(idx,i),C(idx,i)];
    end
