function [res,p] = indtestimpl_logging(i,j,k,ds,alpha,pathdir)
%This function is a wrapper of indtest_new to return 1 in independence case 0 otherwise
%usage
%   indtestimpl_logging(i,j,k,ds,alpha,pathdir)
%   i: dimension of x in ds
%   j: dimension of y in ds
%   k: dimension(s) of z in ds
%   ds: matrix with each line representing an observation (sample)
%   alpha: significance level for indep test
%   pathdir: directory in which the results of the different tests will be
%   stored (pvalues and statistics)

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
    try
        [p,s] = indtest_new(ds(:,i),ds(:,j),[],[]);
    catch E
        E
        p = 0;
    end
    ti = toc;
	res = p > alpha;
    if res > 0 && verbose > 0
        fprintf('Independence detected for the previously mentionned parameters\n');
    end
else
    tic;
    try
        [p,s] = indtest_new(ds(:,i),ds(:,j),ds(:,k),[]);
    catch E
        E
        p = 0;
    end
    ti = toc;
	res = p > alpha;
    if res > 0 && verbose > 0
        fprintf('Independence detected for the previously mentionned parameters\n');
    end
end
if verbose > 0
    fprintf('The test took %g seconds\n' ,ti);
end

if isempty(k)
    fileout=strcat(pathdir,'/independence_',num2str(i),'_',num2str(j),'_cond_0.csv');
else
    fileout=strcat(pathdir,'/independence_',num2str(i),'_',num2str(j),'_cond');
    for d = 1:size(k,2)
        fileout = strcat(fileout,'_',num2str(k(d)));
    end
    fileout = strcat(fileout,'.csv');
end

csvwrite(fileout,[i,j,k,p,s]);