function [result] = teststabilityindtestn(sized,alpha,minloop,maxloop,steploop,mainloop,X,Y,Z)
%This function looks for the stability in the percentage of conditional
%independence test
%Inputs
%   sized: The size of the dataset for the bootstrap method
%   alpha: The alpha value for indep test
%   minloop: the minimum number of test for bootstrap
%   maxloop: the maximum number of test for bootstrap
%   steploop: the step of increase in number test
%   mainloop: how many time the bootstrap is tested for one parameter set
%   X: first variable to test
%   Y: second variable to test
%   Z: conditional set
%Output
%   res: a N*mainloop+1 vector with percentage of success in indep test.
%       N = size(minloop:steploop:maxloop,2)
%       for each line the first value is the number of loop then the
%       percentages

if nargin ~= 9
    error('Wrong number of arguments, see help');
end

N = size(minloop:steploop:maxloop,2);
result = zeros(N,mainloop+1);

counter=0;
for s = minloop:steploop:maxloop
    fprintf('Starting the independence test series with %d loops for %d samples\n',s,sized);
    counter = counter+1;
    result(counter,1) = s;
    for i = 1:mainloop
        [r,p] = indtestimpl_nloop_sval(1,2,3,[X,Y,Z],alpha,sized,s);
        result(counter,i+1) = p;
        fprintf('At step %d the percentage of positive independence for %d loops and %d samples is %g\n',i,s,sized,p);
    end
end

ds = csvread('/datas/xlan/hours/blagny/dataset3_from_05182013.dir/aggregates.dir/TCPRENO_CNXS.dir/set2_modeltesting1.dir/blagnydataset_tstatstat_serverinfos_09112013_11282013_bt5MB_diffrtttstatintrabase_lt_5%_withnbpkts_cleaned_no0capacity.csv',1,0);
ts = ds(:,1);
capacity = ds(:,2);
dist_km = ds(:,3);
objsize = ds(:,4);
rwin = ds(:,5);
mss = ds(:,6);
nbhops = ds(:,7);
bufferingdelay = ds(:,8);
rtt = ds(:,9);
p = ds(:,10);
timeouts = ds(:,11);
retrscore = ds(:,12);
nbpkts = ds(:,13);
nbbytes = ds(:,14);
duration = ds(:,15);
tput = ds(:,16);
tor = timeouts./nbpkts;
X = tor;
Y = objsize;
Z = tput;
teststabilityindtestn(400,0.05,10,100,10,10,X,Y,Z)