function [res,p] = indtestimpl_nloop_sval(i,j,k,ds,alpha,S,N)
%This function is a wrapper of indtest_new to return 1 in independence case 0 otherwise
% This function returns 1 if the PERCENTAGE of times p > alpha is greater
% than 50%
%Usage [res,p] = indtestimpl_nloop(i,j,k,ds,alpha,S,N)
%		i: first dim
%		j: second dim
%		k: conditional set dim(s)
%		ds: dataset
%		alpha: significance level
%		S: subdataset size 
%		N: number of trials
verbose = 0;

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
    P = 0;
    flag1 = 0;
    for l = 1:N
        ds_n = random_resampling(ds,S);
        flag2 = 0;
        try
            [p,s] = indtest_new(ds_n(:,i),ds_n(:,j),[],[]);
        catch E
            E
            %fprintf('Error detected in step %d while testing %d ind %d\n',l,i,j);
            flag1 = flag1+1;
            flag2 = 1;
        end
        if flag2 == 0
            if p > alpha
                P=P+1;
                %fprintf('Independence test positive at loop %d with p-val %g\n',l,p);
            else
                %fprintf('Independence test negative at loop %d with p-val %g\n',l,p);
            end
        end
        clear ds_n;
    end
    if flag1 > 0
        p = (P/(N-flag1));
    else
        p = P/N;
    end
    ti = toc;
    res = p > 0.5;
    if verbose > 0
        if res > 0 && verbose > 0
            fprintf('Independence detected for the previously mentionned parameters with percentage %g\n',p);
        elseif res == 0 && verbose > 0 
            fprintf('Independence failed for the previously mentionned parameters with percentage %g\n',p);        
        end
    end
else
    tic;
    P = 0;
    flag1=0;
    for l = 1:N
       ds_n = random_resampling(ds,S);
       flag2 = 0;
       try
           [p,s] = indtest_new(ds_n(:,i),ds_n(:,j),ds_n(:,k),[]);
       catch E
	   E
       if verbose > 0
           fprintf('Error detected in step %d while testing %d ind %d cond {',l,i,j);
           for w = 1:size(k,2)
               fprintf('%d',k(w));
           end
           fprintf('}\n');
       end
	   flag1 = flag1+1;
	   flag2 = 1;
       end
       if flag2 == 0
            if p > alpha
                P = P+1;
                %fprintf('Independence test positive at loop %d with p-val %g\n',l,p);
            else
                %fprintf('Independence test negative at loop %d with p-val %g\n',l,p);
            end
       end
       clear ds_n;
    end
    if flag1 > 0
        p = P/(N-flag1);
    else
        p = P/N;
    end

    ti = toc;
	res = p > 0.5;
    if res > 0 && verbose > 0
        fprintf('Independence detected for the previously mentionned parameters with percentage of %g\n',p);
    elseif res == 0 && verbose > 0 
        fprintf('Independence failed for the previously mentionned parameters with percentage %g\n',p);
    end
end
if verbose > 0
    fprintf('The test took %g seconds\n' ,ti);
end
clear ti;
