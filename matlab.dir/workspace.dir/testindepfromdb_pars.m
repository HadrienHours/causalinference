function [result] = testindepfromdb_pars(i,j,k,pathlistindep,perc)
%This function takes as input a csvfile with the independence test and
%results as percentage and return 1 in case X,Y and Z are independent and 0
%otherwise
%INPUTS
%       i: dimension of x
%       j: dimension of y
%       k: dimension of z (possibly empty)
%       pathlistindependence: the full path to csvfile
%       perc : percentage of positive outcomes in the test to be considered
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

%in the db we have x y z1 z2 ... zn N l alpha perc
ncol = size(testlist,2);
maxcondset = ncol - 4;

indep = zeros(1,maxcondset);

indep(1) = x;
indep(2) = y;
for i = 1:size(z,2)
    indep(i+2) = z(i);
end
if (size(z,2)+3) < maxcondset
    for j = size(z,2)+3:maxcondset
        indep(j) = 0;
    end
end

I = find(testlist(:,1) == x & testlist(:,2) == y & testlist(:,end) > perc);

if (size(I,1) == 0)
    I = find(testlist(:,1) == y & testlist(:,2) == x & testlist(:,end) > perc);
    indep(1) = y;
    indep(2) = x;
end

if size(I,1) == 0
    result = 0;
    return
else
    testlistind = testlist(I,:);
end

%As we reshape the matrix as a vector, the index should correspond to the
%begining of a row so the index we find in the vector should be
%real_index*sizerow+1 => real_index = (results - 1)/size(row). Then we add
%for the difference between difference of position and difference in
%interval.
ri = strfind(reshape(testlistind(:,1:maxcondset)',1,[]),indep);
if isempty(ri) | ri == 0
    result = 0;
else
    idx = ((ri-1)/maxcondset)+1;

    if idx ~= floor(idx)
       %independence not present so we consider it invalid %%%Limitation of the
       %                                                   %%%approach but all
       %                                                   %%%the useful
       %                                                   %%%independences
       %                                                   %%%should be in the
       %                                                   %%%db
       result = 0;
    else
        result = 1;
    end
end
end