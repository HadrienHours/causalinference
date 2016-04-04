function [result] = testindepfromsimpledb(i,j,k,pathindep)
%This function is returning the indepedence between i and j conditionally
%on k querying an oracle csvfile where x,y,z1,z2,....,results
%input
%   i : dimension of x
%   j : dimension of y
%   k : possibly empty dimension(s) of z
%   pathindep: csvfiles path containing oracles
%output
%   0 if dep, 1 if indep

x = i;
y = j;

listindep = csvread(pathindep,1,0);

maxcond = size(listindep,2)-3;%removing column x,y and result;

if isempty(k)
    z = 0;
else
    z = k;
    sz = size(k,2);
end

if z == 0
    I = find(listindep(:,1) == x & listindep(:,2) == y & listindep(:,3) == 0);
    if size(I,1) == 0
        result = 0;
        return
    end
    
    if size(I,1) == 1
        result = listindep(I,end) > 0.5;
    else
        result = mean(listindep(I,end)) > 0.5;
    end
else
    I = find(listindep(:,1) == x & listindep(:,2) == y);
    list_t = listindep(I,:);
    for d = 1:sz
        I = find(list_t(:,d+2)==z(d));
        list_t = list_t(I,:);
    end
    if sz < maxcond
        for d = sz+1:maxcond
            I = find(list_t(:,2+d)==0);
            list_t = list_t(I,:);
        end
    end
    if size(list_t,1) == 1
        result = list_t(1,end) > 0.5;
    else
        result = mean(list_t(:,end)) > 0.5;
    end
end

