function [p1,stat1,p,stat] = indtestimpl_nloop_pstat(i,j,k,ds,alpha,S,N)
%This function implements the bootstrap method in combination with HSIC
%implementation. It cannot be used in combination with bnt learning
%bayesian model. It's a test function to get all the pvalues and statistics
%of the sub tests
%Usage [res,p] = indtestimpl_nloop(i,j,k,ds,alpha,S,N)
%		i: first dim
%		j: second dim
%		k: conditional set dim(s)
%		ds: dataset
%		alpha: significance level
%		S: subdataset size 
%		N: number of trials
%Output
%       stat = test statistic (average value over the N tests, remove failures)
%       pvalue = pvalue (average value over the N tests, remove failures)
verbose = 1;


p = zeros(N,1);
stat = zeros(N,1);

if verbose > 0
    fprintf('HSIC testing independence of %d %d',i,j);
    if ~isempty(k)
        fprintf(' conditionally on %d',k(1));
        r = 2;
        l = size(k,2);
        while r <= l
            fprintf(' and %d',k(r));
            r = r+1;
        end
    end
    fprintf('\n');
end
if isempty(k)
    tic;
    p1 = 0;
    stat1 = 0;
    flag1 = 0;
    for l = 1:N
        ds_n = random_resampling(ds,S);
        flag2 = 0;
        try
            [p(l),stat(l)] = indtest_new(ds_n(:,i),ds_n(:,j),[],[]);
        catch
            fprintf('Error detected in step %d while testing %d ind %d\n',l,i,j);
            flag1 = flag1+1;
            flag2 = 1;
            p(l) = nan;
        end
        if flag2 == 0
            p1=p1+p(l);
            stat1 = stat1+stat(l);
        end
        clear ds_n;
    end
    if flag1 > 0
        p1 = (p1/(N-flag1));
        stat1 = (stat1/(N-flag1));
    else
        p1 = p1/N;
        stat1 = stat1/N;
    end
    ti = toc;
    res = p > alpha;
    if res > 0 & verbose > 0
        fprintf('Independence detected for the previously mentionned parameters\n');
    end
else
    tic;
    p1 = 0;
    stat1 = 0;
    flag1=0;
    for l = 1:N
       ds_n = random_resampling(ds,S);
       flag2 = 0;
       try
           [p(l),stat(l)] = indtest_new(ds_n(:,i),ds_n(:,j),ds_n(:,k),[]);
       catch E
           E
           fprintf('Error detected in step %d while testing %d ind %d cond {',l,i,j);
           for w = 1:size(k,2)
               fprintf('%d',k(w));
           end
           fprintf('}\n');
           flag1 = flag1+1;
           flag2 = 1;
           p(l) = nan;
       end
       if flag2 == 0
           p1 = p1+p(l);
           stat1 = stat1+stat(l);
       end
       clear ds_n;
    end
    if flag1 > 0
	p1 = p/(N-flag1);
    stat1 = stat1/(N-flag1);
    else
	p1 = p1/N;
    stat1 = stat1 / N;
    end

    ti = toc;
	res = p1 > alpha;
    if res > 0 & verbose > 0
        fprintf('Independence detected for the previously mentionned parameters\n');
    end
end

fprintf('The test took %g seconds\n' ,ti);
clear ti;