function [r,p] = test_continuous(D,i,j,k,alpha)
% this function is testing X independent of Y depending on Z (Z can be
% empty in which case a normal independence test is led) when X, Y and Z
% are continuous
%Inputs
%       D: n*p dataset of n samples of p parameters
%       i: dimension of X
%       j: dimension of Y
%       k: dimension of Z
%       alpha: significance level
%Outputs
%       r: test outcome 1 if H0 (independence) accepted, 0 if rejected
%       p: p-value

n = size(D,1);
p = size(D,2);

H1 = chi2gof(D(:,i));
H2 = chi2gof(D(:,j));

if ~isempty(k)
    if size(k,2) == 1
        H3 = chi2gof(D(:,k));
    else
        H3 = 1;
        for s = 1:size(k,2)
            H3 = chi2gof(D(:,k(s)));
        end
    end
    H = H1+H2+H3;
else
    H = H1+H2;
end

H = 0;

if H == 0
   C = corr(D); 
   [r, r0, p] = cond_indep_fisher_z(i, j, k, C, n, alpha);
else
    if ~isempty(k)
        [p,stat] = indtest_new(D(:,i),D(:,j),D(:,k),[]);
        r = p > alpha;
    else
        [thresh1,stat1] = hsicTestBootIC(D(:,i),D(:,i),alpha,floor(size(D,1)/5));
        r = stat1 < thresh1;
        p = [thresh1,stat1];
    end
end