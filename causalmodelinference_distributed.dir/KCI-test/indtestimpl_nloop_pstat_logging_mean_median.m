function [Pmean,Pmedian] = indtestimpl_nloop_pstat_logging_mean_median(i,j,k,ds,alpha,S,N,pathdir)
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
%       pathdir: The path to directory to store results
%Output
%       Pmean = Statistics with [mean pvalue,min pvalue, max pvalue, std
%       pvalue, mean stat, min stat, max stat, std stat]
%       Pmedian = Statistics with [median pvalue,min pvalue, max pvalue, std
%       pvalue, median stat, min stat, max stat, std stat]
verbose = 1;

if isunix()
    set_path_2()
elseif ispc()
    set_path_2_win()
else
    error('Not recognized OS')
end

Pvals = zeros(N,1);
Stats = zeros(N,1);

if k == 0
    k = [];
end

if exist(pathdir,'dir') ~= 7
    error('The path %s does not exist',pathdir)
end

namedir = strcat('independence_',num2str(i),'_',num2str(j));

if ~ isempty(k)
    namedir = strcat(namedir,'_cond');
    for ii = 1:size(k,2)
        namedir = strcat(namedir,'_',num2str(k(ii)));
    end
end

namedir = strcat(namedir,'_nloops_',num2str(N),'_subsize_',num2str(S),'.dir');

mkdir(pathdir,namedir);

pathlogdir = strcat(pathdir,'/',namedir);

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
    for l = 1:N
        ds_n = random_resampling(ds,S);
        try
            [p,s] = indtest_new(ds_n(:,i),ds_n(:,j),[],[]);
            fileout=strcat(pathlogdir,'/independence_',num2str(i),'_',num2str(j),'_cond_0_test_',num2str(l),'.csv');
            csvwrite(fileout,[i,j,k,S,N,p]);
            Pvals(l) = p;
            Stats(l) = s;
        catch
            fprintf('Error detected in step %d while testing %d ind %d\n',l,i,j);
            Pvals(l) = nan;
            Stats(l) = nan;
        end
        clear ds_n;
    end
    Pvals = Pvals(~isnan(Pvals));
    Stats = Stats(~isnan(Stats));
    
    Pmean = [mean(Pvals),min(Pvals),max(Pvals),std(Pvals),mean(Stats),min(Stats),max(Stats),std(Stats)];
    Pmedian = [median(Pvals),min(Pvals),max(Pvals),std(Pvals),median(Stats),min(Stats),max(Stats),std(Stats)];
    %log result global
    log_glob = strcat(pathlogdir,'/mean_global_test_statistics_',num2str(i),'_',num2str(j),'_cond');
    log_glob = strcat(log_glob,'_subsize',num2str(S),'_loops_',num2str(N),'.csv');
    csvwrite(log_glob,[i,j,0,S,N,Pmean]);
        log_glob = strcat(pathlogdir,'/median_global_test_statistics_',num2str(i),'_',num2str(j),'_cond');
        log_glob = strcat(log_glob,'_subsize',num2str(S),'_loops_',num2str(N),'.csv');
    csvwrite(log_glob,[i,j,0,S,N,Pmedian]);
    ti = toc;
    res = Pmedian(1) > alpha;
    if res > 0 && verbose > 0
        fprintf('Independence detected for the previously mentionned parameters\n');
    end
else
    tic;
    for l = 1:N
       ds_n = random_resampling(ds,S);
       try
           [p,stat] = indtest_new(ds_n(:,i),ds_n(:,j),ds_n(:,k),[]);
           fileout=strcat(pathlogdir,'/independence_',num2str(i),'_',num2str(j),'_cond');
           for d = 1:size(k,2)
               fileout = strcat(fileout,'_',num2str(k(d)));
           end
           fileout = strcat(fileout,'_test_',num2str(l),'.csv');
           fprintf('About to save the file as %s\n',fileout)
           csvwrite(fileout,[i,j,k,S,N,p]);
           Pvals(l) = p;
           Stats(l) = stat;
       catch E
           E
           fprintf('Error detected in step %d while testing %d ind %d cond {',l,i,j);
           for w = 1:size(k,2)
               fprintf('%d',k(w));
           end
           fprintf('}\n');
           Pvals(l) = nan;
           Stats(l) = nan;
       end
       clear ds_n;
    end
    
    Pvals = Pvals(~isnan(Pvals));
    Stats = Stats(~isnan(Stats));
    %log result global
    Pmean = [mean(Pvals),min(Pvals),max(Pvals),std(Pvals),mean(Stats),min(Stats),max(Stats),std(Stats)];
    Pmedian = [median(Pvals),min(Pvals),max(Pvals),std(Pvals),median(Stats),min(Stats),max(Stats),std(Stats)];
        %median
    log_glob = strcat(pathlogdir,'/mean_global_test_statistics_',num2str(i),'_',num2str(j),'_cond');
    for ii = 1:size(k,2)
        log_glob = strcat(log_glob,'_',num2str(k(ii)));
    end
    log_glob = strcat(log_glob,'_subsize',num2str(S),'_loops_',num2str(N),'.csv');
    csvwrite(log_glob,[i,j,k,S,N,Pmean]);
    
        %median
    log_glob = strcat(pathlogdir,'/median_global_test_statistics_',num2str(i),'_',num2str(j),'_cond');
    for ii = 1:size(k,2)
        log_glob = strcat(log_glob,'_',num2str(k(ii)));
    end
    log_glob = strcat(log_glob,'_subsize',num2str(S),'_loops_',num2str(N),'.csv');
    csvwrite(log_glob,[i,j,k,S,N,Pmedian]);
    
    ti = toc;
	res = Pmedian(1) > alpha;
    if res > 0 && verbose > 0
        fprintf('Independence detected for the previously mentionned parameters\n');
    end
end

fprintf('The test took %g seconds\n' ,ti);
clear ti;