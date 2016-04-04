function [CI,r,p] = cond_indep_fisher_z_resampling(i,j,k,D,alpha,loops,subsize)
%This function is applying the fisher-z independence criteria from the bnt
%tool box but in a averaged bootstrap maner. It reforms subdatasets and
%test independence on each of this subdataset and take the decision as an
%average decision over all the subdatasets
%INPUTS
%       i: column number corresponding to X
%       j: column number corresponding to Y
%       k: column number(s) corresponding to Z
%       D: dataset
%       alpha: significance level
%       loops: number of subdataset to create to test the independence
%       subsize: Size of the subdatasets

success = 0;
r = 0;
p = 0;
verbose=0;

for l = 1:loops
    ds = random_resampling(D,subsize);
    C = corr(ds);
    [CI,rI,pI] = cond_indep_fisher_z(i,j,k,C,subsize,alpha);
    if verbose > 0
        if CI > 0
            fprintf('Successfully detected independence between %d and %d',i,j);
            if ~isempty(k)
                fprintf(' conditionally on %d',k(1));
                w=1;
                while w <= size(k,2)
                    fprintf(' and %d',k(w));
                    w = w+1;
                end
            end
            fprintf('\n');
        end
    end
    r = r+rI/loops;
    p = p+pI/loops;
    success = success+CI;
end

p = success / loops;

if p >= 0.5 %(1-alpha)
    CI = 1;
    if verbose > 0
        fprintf('Independence accepted with success rate of %f\n',p);
    end
else
    if verbose > 0
        fprintf('Independence rejected with success rate of %f\n',p);
    end
    CI = 0;
end