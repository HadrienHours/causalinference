function [result] = testindepfromsimpledb_pars(i,j,k,pathindep,perc)
%This function is returning the indepedence between i and j conditionally
%on k querying an oracle csvfile where x,y,z1,z2,....,results
%input
%   i : dimension of x
%   j : dimension of y
%   k : possibly empty dimension(s) of z
%   pathindep: csvfiles path containing oracles
%   perc: gives the percentage threshold for assuming parameters as
%   independent
%output
%   0 if dep, 1 if indep

x = i;
y = j;

listindep = csvread(pathindep,1,0);

maxcond = size(listindep,2)-3;%removing column x,y and result;

if size(k,2) > maxcond
    result = 0;
    return
end

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
        result = listindep(I,end) > perc;
    else
        result = mean(listindep(I,end)) > perc;
    end
else
    I = find(listindep(:,1) == x & listindep(:,2) == y);
    list_t = listindep(I,:);
    for d = 1:sz
        try
            I = find(list_t(:,d+2)==z(d));
            list_t = list_t(I,:);
        catch E
            E
            fprintf('Error while testing independence between %d and %d conditioning on ',x,y)
            for r=1:sz
                fprintf('%d,',z(r))
            end
            fprintf('\n')
            fprintf('Error happened while look for values equal to %d (dim %d of z) in the db\n',z(d),d)
            result = -1;
            return
        end
    end
    if sz < maxcond
        for d = sz+1:maxcond
            I = find(list_t(:,2+d)==0);
            list_t = list_t(I,:);
        end
    end
    if size(list_t,1) == 1
        result = list_t(1,end) > perc;
    else
        result = mean(list_t(:,end)) > perc;
    end
end

