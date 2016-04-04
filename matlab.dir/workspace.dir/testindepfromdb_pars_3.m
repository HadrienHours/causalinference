function [result] = testindepfromdb_pars_3(i,j,k,pathlistindep,alpha)
%This function takes as input a csvfile with the independence test and
%results as p-value and return 1 in case X,Y and Z are independent and 0
%otherwise
%INPUTS
%       i: dimension of x
%       j: dimension of y
%       k: dimension of z (possibly empty)
%       pathlistindependence: the full path to csvfile in the format
%       X,Y,Z1,Z2,...Zmax,S,N,pval
%       alpha : percentage of positive outcomes in the test to be considered
%       as positive
%OUTPUT
%       result: 1 if X indep Y cond Z
%               0 otherwise

headerflag = 1;

x = i;
y = j;
if isempty(k)
    z = 0;
else
    z = k;
end

if headerflag > 0 
    testlist = csvread(pathlistindep,1,0);
else
    testlist = csvread(pathlistindep);
end

%in the testlist we have x y z1 z2 ... zn pval
ncol = size(testlist,2);
maxcondset = ncol - 3;%minus x,y pval

indep = zeros(1,maxcondset);

indep(1) = x;
indep(2) = y;
for i = 1:size(z,2)
    indep(i+2) = z(i);
end

if maxcondset-2 < size(k,2)
    result = 0;
    %fprintf('No test for conditioning set size bigger than %d\n',maxcondset-2)
    return
end

I = find(testlist(:,1) == x & testlist(:,2) == y & testlist(:,end) > alpha);
%Safety measure in case we test X indep Y cond... and X > Y
if (size(I,1) == 0)
    I = find(testlist(:,1) == y & testlist(:,2) == x & testlist(:,end) > alpha);
    indep(1) = y;
    indep(2) = x;
end

if size(I,1) == 0
    result = 0;
    return
else
    testlistind = testlist(I,1:maxcondset);%list of all independence with X = x and Y = y
end
% 
% if size(indep,2) ~= size(testlistind,2)
%     fprintf('Error while testing independence between %d and %d',i,j)
%     if size(k,2) > 0
%         fprintf(' conditionally on')
%         for ii = 1:size(k,2)
%             fprintf(' %d',k(ii))
%         end
%     end
%     fprintf('\n')
%     fprintf('Max cond set computed as %d\n',maxcondset);
%     fprintf('Z size is %d\n',size(k,2))
%     error('Dimension mismatch when looking for independence test of size %d in the tested independences of size %d\n',size(indep,2),size(testlistind,2));
% end

Idx = strmatch(indep,testlistind);

if isempty(Idx)
    result = 0;
else
    result = 1;
end
end