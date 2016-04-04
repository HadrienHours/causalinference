function [results,results2] = testconditional_distr(ds,x,y,alpha,N,l,nnodes,nodeidx,names,flagwriteresults)
%This function computes all the conditional test of size 2 (conditioning set size) between x and y assuming that these tests are run in parallel on different nodes
% Input
%	ds = the dataset
%	x = the dimension of the first variable
%	y = the dimension of the second variable
%	alpha = significance level for independence test
%	N = number of samples in the subdatasets used for bootstraps
%	l = number of loops for testing independence
%	nnodes = number of nodes on which the function will be ran
%	nodeid = value between 1 and nnodes
%	names [optional] = a cell containing the names of the parameters
%	flagwriteresults [optional] = if set to 1 will write a txt file with results of the tests
% Output
%	results = results of all the conditional tests x ind y: cell containing as first elements the conditional set second percentage of positive outcome
%	results2 = results of all positive the conditional tests (percentage > 0.5) x ind y: cell containing as first elements the conditional set second percentage of positive outcome

if nargin < 8
	error('Not enough arguments, see help');
elseif nargin == 8
	names = cell(1,p);
	for i = 1:p
		names{i} = strcat('X',num2str(i));
	end
elseif nargin == 9
	flagwriteresults = 0;
elseif nargin > 10
	error('Too many arguments, see help');
end

n = size(ds,1);
p = size(ds,2);

%creating list index for conditional tests
listindex = 1:size(ds,2);
listindex(x) = [];
if x < y
	listindex(y-1) = [];
else
	listindex(y) = [];
end

listcond = nchoosek(listindex,2);

%if the number of tests to run is not divisible by the number of nodes we add the remaining tests to the first nodes till reaching a number dividable
sl = size(listcond,1);
sx = floor(sl/nnodes);
rx = sl/nnodes - floor(sl/nnodes);%The portion of test to distribute in the first nodes
nx = ceil(nnodes*rx)

if nodeidx <= nx
	beg = 1+(nodeidx-1)*sx+(nodeidx-1)
	fin = beg + sx %length sx+1
	listcond = listcond(beg:fin,:);
else
	beg = 1+(nodeidx-1)*sx+nx
	fin = beg + sx -1
	listcond = listcond(beg:fin,:);
end

s = size(listcond,1);
results = cell(s,2);

fprintf('Starting the %d tests between %s and %s with %d subtests on subset of size %d and alpha %g\n',s,names{x},names{y},l,N,alpha);

for i = 1:s
	results{i,1} = names(listcond(i,:));
	[r,p] = indtestimpl_nloop_sval(x,y,listcond(i,:),ds,alpha,N,l);
	results{i,2} = [p];
	fprintf('The test %d on a total of %d is finished\n',i,s);
end

if flagwriteresults > 0
	tit = strcat('conditionaltest_',num2str(alpha),'_',num2str(N),'samples_',num2str(l),'loops_',num2str(x),'_',num2str(y),'_node_',num2str(nodeidx));
	fid = fopen(tit,'w');

	for i = 1:size(results,1)
		fprintf(fid,'%s,%s,%.2g\n',results{i,1}{1},results{i,1}{2},results{i,2});
	end
	fclose(fid);
end


I = find([results{:,2}]' > 0.5);
results2 = results(I,:);

if flagwriteresults > 0
	tit = strcat('positive_conditionaltest_',num2str(alpha),'_',num2str(N),'samples_',num2str(l),'loops_',num2str(x),'_',num2str(y),'_node_',num2str(nodeidx));
	fid = fopen(tit,'w');
	for i = 1:size(results2,1)
		fprintf(fid,'%s,%s,%.2g\n',results2{i,1}{1},results2{i,1}{2},results2{i,2});
	end
	fclose(fid);
end
