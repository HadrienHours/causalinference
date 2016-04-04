function [results] = testcond_distr(ds,nodeidx,N,l,alpha,listcond,nnodes)
%This function operates some tests from a series of test between different
% nodes.
%Input
%   ds : the dataset
%   nodeidx: the node index (>0)
%   N : the size of subdatasets for test indtestimpl_nloop_sval
%   l : the number of loops for test indtestimpl_nloop_sval
%   alpha : the significance level for test indtestimpl_nloop_sval
%   listcond : the full list of test
%   nnodes : the total number of nodes
%Output
%   results : the outcome of the share of test operated by the node

if nargin ~= 7
    error('Wrong number of arguments, see help');
end

if nodeidx < 0 || nodeidx > nnodes
    error('Wrong value for node index')
end

sl = size(listcond,1);
s = floor(sl/nnodes);
r = sl-s*nnodes;
if nodeidx ~= nnodes
    if nodeidx <= r
        beg = (nodeidx-1)*s+1+(nodeidx-1);
        fin = nodeidx*s+nodeidx;
    else
        beg = (nodeidx-1)*s+1+r;
        fin = nodeidx*s+r;
    end
    listcondn = listcond(beg:fin,:);
else
    beg = (nodeidx-1)*s+1+r;
    fin = size(listcond,1);
    listcondn = listcond(beg:fin,:);
end
fprintf('The node %d is going to operate test from %d to %d (on a total of %d)\n',nodeidx,beg,fin,sl);
results = testcond2(ds,listcondn,alpha,N,l);