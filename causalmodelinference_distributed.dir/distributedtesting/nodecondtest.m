function [result] = nodecondtest(dspath,i,j,ks,alpha,N,l,pathout)
%run an indep test with the given input
%input
%   dspath: path to csvfile containing dataset with header
%   i : x dim
%   j : y dim
%   k : dim(s) for z
%   alpha : significance level
%   N : subdataset size for indtestimpl_nloop_sval
%   l : number of loops for indtestimpl_nloop_sval
%   pathout [optional]: csvfilepath to write results
%output
%   result = 1*(2+size(k,2)+2): [i,j,k,res,perc]

verbose = 0;

if verbose > 0
    fprintf('k is %d\n',ks);
end

if ks == 0
    k = [];
else
    k = ks;
end
   
if verbose > 0
    fprintf('Size k is %d\n',size(k,2));
end
addpath('/homes/hours/PhD/matlab/kpc/');
set_path_2();

ds = csvread(dspath,1,0);

result = zeros(1,size(k,2)+4);
result(1:size(k,2)+2) = [i,j,k];
[r,p] = indtestimpl_nloop_sval(i,j,k,ds,alpha,N,l);
result(size(k,2)+3:end) = [r,p];

if nargin == 8
    csvwrite(pathout,result);
end

if verbose > 0
    fprintf('The result of independence between %d and %d ',i,j)
    if ~isempty(k)
        fprintf('conditionally on ');
        for t = 1:size(k,2)
            fprintf('%d ',k(t))
        end
    end
    fprintf('is %g\n',p);
end