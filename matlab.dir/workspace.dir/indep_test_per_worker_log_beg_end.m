function [] = indep_test_per_worker_log_beg_end(pathds,pathlistindep,beg,fin,alpha,N,S,pathlog)
%This function is to be run in parallel on several nodes, it allocate to a
%given node a list of independences to test and log the results in a
%dedicated directory for the HSIC+bootstrap
% Inputs:
%       pathds = path to csvfile containing the dataset (assumes header)
%       pathlistindep = path to the full list of independences to be tested
%       (assumes header)
%       beg = first independence index in the list of independences to test
%       fin = last independence index in the list of independences to test
%       alpha = significance value used in the tests
%       N = number of loops
%       S = subdataset size in the bootstrap method
%       pathlog = path to the directory to store results
% Output:
%       None, the results are directly stored in the directory, one
%       directory is created for each test and one global file given the
%       final pvalue and statistique of the test
%
% Usage:
%       indep_test_per_worker_log_beg_end(pathds,pathlistindep,beg,fin,alpha,N,S,pathlog)

if exist(pathlog,'dir') ~= 7
    error('The path %s does not redirect to an existing directory',pathlog)
end

verbose = 2;

ds = csvread(pathds,1,0);

listindep = csvread(pathlistindep,1,0);

condsetsize = size(listindep,2)-2;

ntestsf = fin - beg +1;

if verbose > 0
    fprintf('Node will perform %d tests begining: %d, end %d\n',ntestsf,beg,fin)
end

if ntestsf > 0
    listindep_node = listindep(beg:fin,:);
end

ntestsf = size(listindep_node,1);

for ii = 1:ntestsf    
    x = listindep_node(ii,1);
    y = listindep_node(ii,2);
    if condsetsize == 0
        z = [];
    else
        z = listindep_node(ii,3:end);
    end
    
    if verbose > 0
       fprintf('Node start the independence test between %d and %d',x,y)
       if condsetsize > 0
           fprintf(' conditionally on')
           for jj = 1:condsetsize
               fprintf(' %d',z(jj))
           end
       end
       fprintf('(test %d/%d\n',ii,ntestsf)
    end
    
    indtestimpl_nloop_pstat_logging(x,y,z,ds,alpha,S,N,pathlog)
    
    if verbose > 0
        fprintf('Node finished test %d/%d, results will be stored in:\n %s    \n',ii,ntestsf,pathlog)
    end
    
end

if verbose > 0
    fprintf('Node finished its %d tests\n',ntestsf)
end
