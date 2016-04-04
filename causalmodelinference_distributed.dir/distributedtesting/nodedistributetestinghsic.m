function [] = nodedistributetestinghsic(pathmatlabresources,pathds,pathlistindependences,pathoutputdir,step_node,node_idx,alpha,N,l)
%This function is to be called at each node runing matlab to test a part of
%the already generated independences.
%   Each node will run a given amount of a list of independences to test,
%   in parallel with other nodes. The function, in addition to usual
%   parameters, assumes that, for testing X indep Y cond Z, csvfile
%   containing the list of dimensions for testing X, Y cond Z 
%   was already generated
%Inputs
%   pathmatlabresources = path to matlab source files
%   pathds = path to dataset
%   listx = list of dimensions corresponding to x
%   listy = list of dimensions corresponding to y
%   listz = list of dimensions corresponding to z 
%   pathoutputdir = path to dir to store results
%   step_node = how many test/node
%   node_idx = unique identifier for this worker
%   alpha = significance level in hsic sub test
%   N = subdataset size in hsic bootstrap test
%   l = number of loop in hsic bootstrap test
%Outputs
%       None, write result into file in the given dir

%amount of infos/warning
verbose = 1;

%set up environment
addpath(pathmatlabresources);
set_path_2(pathmaltbresources);

%set vars
dspath =pathds;
pathout1=pathoutputdir;
nodeidx = node_idx;
stepnode = step_node;

%compute range
%Node index 1 will start from 1 to 1000, node 2 from 1001 to 2000, if step
%node is 1000
begidx = (nodeidx-1)*stepnode+1;
endidx = nodeidx*stepnode;

%load x,y and potentiallyz
listindpce = csvread(pathlistindependences,1,0);
listx = listindpce(:,1);
listy = listindpce(:,2);
if size(listindpce,2) > 2
    listz = listindpce(:,[3:end]);
end
sz = size(listz,2);

%build input
listi = listx(begidx:endidx);
listj = listy(begidx:endidx);
if sz > 0
    listk = listz(begidx:endidx,:);
end
sl = size(listi,1);

%test each independence and store result in a file
for s = 1:sl
    i = listi(s);
    j = listj(s);
    pathout = strcat(pathout1,'results_test_',num2str(listi(s)),'_',num2str(listj(s)),'_cond');
    if verbose > 1
        fprintf('The result of the independence test between pars dim %d and %d ',i,j);
    end
    if sz > 0
        if verbose > 1
            fprintf('conditionally on ');
        end
        k = listk(s,:);
        sk = size(k,2);
        for c = 1:sk
            if verbose > 1
                fprintf('%d ',k(c));
            end
            pathout = strcat(pathout,'_',num2str(k(c)));
        end
        pathout = strcat(pathout,'.csv');
    else
        k = [];
        pathout = strcat(pathout,'_0.csv');
    end
    fprintf('will be stored in %s\n',pathout);
    nodecondtest(dspath,i,j,k,alpha,N,l,pathout);
    if verbose > 0
        fprintf('node %d finished testing indepdence between %d and %d ',nodeidx,i,j)
        if sz > 0
            fprintf('cond on {')
        end
        for c = 1:sk
            fprintf('%d ',k(c))
        end
        fprintf('} \n');
    end
end