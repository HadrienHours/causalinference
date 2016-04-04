% Description : This function takes each dimension separately and use the
% given method to compute the marginal pdf. The output is an increasing
% ordered pdf function 

function [pdfs] = margipdf(M,methodk)
% INPUT
%             M:        n*p matrices n samples of p dimensions
%             methodk:  normal,box,triangle or epanechnikov
% OUTPUT
%             cdfs:     1*p cell of n*2 matrices representing 
%                       the pdf value of each sample

%dimensions
    n = size(M,1);
    p = size(M,2);
    
 
 %Get the pdfs
    P = zeros(n,p);
    for i=1:p
        P(:,i) = ksdensity(M(:,i),M(:,i),'function','pdf','kernel',methodk);
    end
    
 % Order the values and link them to their corresponding pdf values
    pdfs = cell(1,p);
    for i = 1:p
        [v,idx] = sort(M(:,i));
        pdfs{i} = [M(idx,i),P(idx,i)];
    end
