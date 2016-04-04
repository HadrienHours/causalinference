function [r,p] = test_disc_cont_cont(D,i,j,k,alpha)
%This function test the independence of X and Y conditionally on Z in the
%case where X is discrete and Y and Z are continous
%INPUTS
%       D: n*p dataset of n samples of p parameters
%       i: dimension corresponding to X
%       j: dimension corresponding to Y
%       k: dimension corresponding to Z
%       alpha: significance level
%OUTPUTS
%       r: test outcome (1 if independent 0 otherwise)
%       p: p value

n = size(D,1);
p = size(D,2);

clusterization = 1;

% Better quantization if clusterization but losing too much variation     
%    %Clusterization


s0 = size(D,1)+1;
s1 = size(D,1);
c = 0;
while s1 < s0
    s0 = s1;
    c = c+1;
    flag = 0;
    while flag == 0
        try
            [idx,b,s] = kmeans(D(:,k),c);
            flag = 1;
        catch
            flag = 0;
        end
    end
   s1 = sum(s);
   if c == 1
       s0 = s1+1;
   end
end

p = 0;

q = size(unique(idx),1);

fprintf('%d clusters for discretization of Z in disc_cont_cont test\n',q);

for l = 1:q
    I = find(idx==l);
    D1 = D(I,[i,j]);
    [r1,p1] = test_half_discrete(D1,1,2,alpha);
    %In case the cluster is too small the next step of quantization will be
    %meaningless
    if p1 >= 0
        p = p+size(I,1)/n*p1;
        fprintf('Cluster %d gave p = %f\n',l,p1);
    else
        p = p*(1+size(I,1)/n);
        fprintf('Cluster %d of size %d not considered\n',l,size(I,1));
    end
end

r = p > alpha;