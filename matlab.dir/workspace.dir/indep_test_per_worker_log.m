function [] = indep_test_per_worker_log(pathds,pathlistindep,nodeidx,nNodes,alpha,N,S,pathlog)
%This function is to be run in parallel on several nodes, it allocate to a
%given node a list of independences to test and log the results in a
%dedicated directory for the HSIC+bootstrap
% Inputs:
%       pathds = path to csvfile containing the dataset (assumes header)
%       pathlistindep = path to the full list of independences to be tested
%       (assumes header)
%       nodeidx = unique identifier (index) given to the node
%       nNodes = the total number of working nodes
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
%       indep_test_per_worker_log(pathds,pathlistindep,nodeidx,nNodes,alpha,N,S,pathlog)

if exist(pathlog,'dir') ~= 7
    error('The path %s does not redirect to an existing directory',pathlog)
end

verbose = 2;

ds = csvread(pathds,1,0);

listindep = csvread(pathlistindep,1,0);

Nindep = size(listindep,1);
condsetsize = size(listindep,2)-2;

ntests = floor(Nindep/nNodes);
resid = Nindep - (ntests*nNodes);

if verbose > 1
    fprintf('The number of residual tests to distribute among the first nodes is %d\n',resid);
end

%We distribute the additional tests (to reach Nindep) to the first nodes
if nodeidx <= resid
    beg = ntests*(nodeidx-1) + nodeidx;
    fin = ntests*(nodeidx)+nodeidx; %range is ntests+1
    ntestsf=ntests+1;
else
    if ntests ~= 0
        beg = ntests*(nodeidx-1)+resid+1;
        fin = ntests*(nodeidx)+resid; %range is ntests
    else
        beg = 0;
        fin = 0;
    end
        ntestsf = ntests; 
end

if verbose > 0
    fprintf('Node with index %d will perform %d tests begining: %d, end %d (default number of test is %d)\n',nodeidx,ntestsf,beg,fin,ntests)
end

if ntestsf > 0
    listindep_node = listindep(beg:fin,:);
end

for ii = 1:ntestsf    
    x = listindep_node(ii,1);
    y = listindep_node(ii,2);
    if condsetsize == 0
        z = [];
    else
        z = listindep_node(ii,3:end);
    end
    
    if verbose > 0
       fprintf('Node index %d start the independence test between %d and %d',nodeidx,x,y)
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
        fprintf('Node index %d finished test %d/%d, results will be stored in:\n %s    \n',nodeidx,ii,ntestsf,pathlog)
    end
    
end

if verbose > 0
    fprintf('Node idx %d finished its %d tests\n',nodeidx,ntestsf)
end

