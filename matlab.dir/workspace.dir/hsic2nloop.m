function [results] = hsic2nloop(X,Y,Z1,Z2,N,l,nloops,pathout,pathds)
%This function launches nloops conditional hsic tests and store the output
%INPUTS
%   X: dim x
%   Y: dim y
%   Z1: dim 1 of z
%   Z2: dim 2 of z
%   N: subdataset size in indtestimpl_nloop_sval
%   l: number of loops in indtestimpl_nloop_sval
%   nloops: number of time to run the tests
%   pathout: directory in which the results will be stored (must exist)
%   pathds:[optional] path to csv dataset (with header) default one created
%OUTPUTS
%   results : nloops*4 the results of the test for the N and l

if nargin < 8
    error('Wrong number of args, see help')
elseif nargin == 8
    pathds = '/datas/xlan/hours/blagny/dataset3_from_05182013.dir/aggregates.dir/TCPRENO_CNXS.dir/set2_modeltesting1.dir/blagnydataset_tstats_serverinfos_09112013_11282013_bt5MB_diffrtttstatintrabase_lt5%_nopkt_nomss_no0cap_no0hops_noduration_noobjsize_cleaned.csv';
elseif nargin > 9
    error('Wrong number of args, see help')
end

ds = csvread(pathds,1,0);

results = zeros(nloops,4);
results(:,1) = N*ones(nloops,1);
results(:,2) = l*ones(nloops,1);

for i = 1:nloops
    fprintf('Starting loop %d for indtestimpl_nloop_sval with subds %d and %d loops\n',i,N,l)
    [results(i,3),results(i,4)] = indtestimpl_nloop_sval(X,Y,[Z1,Z2],ds,0.05,N,l);
end

fname = strcat(pathout,'/hsic2_looptest_',num2str(nloops),'_subds_',num2str(N),'_loops_',num2str(l),'.csv');

csvwrite(fname,results);