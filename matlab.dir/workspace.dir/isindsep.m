function [ ispresent] = isindsep(i,j,k,dspath,headerflag)
%isindsep this function tests if Z is in the d-separation set of X and Y
%Inputs
%   i: dim x
%   j: dim y
%   k: dim(s) z
%   dspath: path to independence list
%   headerflag:[optional] if set to 0 no header in the csv file (default 1)
%Output
%   presence: 1 if yes, 0 either

if nargin > 5 || nargin < 4
    error('Wrong number of arguments, see help')
end

if nargin == 4
    flag = 1;
else
    flag = headerflag;
end

if isempty(k)
    k = 0;
end

if flag > 0
    listindep = csvread(dspath,1,0);
else
    listindep = csvread(dspath);
end

ispresent = 0;

I = find((listindep(:,1) == i & listindep(:,2) == j) | (listindep(:,1)==j & listindep(:,2)==i));
listtestxy = listindep(I,:);
I = listtestxy(:,end) > 0.5;
listindepxy = listtestxy(I,:);
%fprintf('The number of independence tests where %d independent of %d is %d\n',i,j,size(listindepxy,1))
ncond = size(listindep,2) - 4;%removing N,l,alpha and p
dsepsetxy = listindepxy(:,3:ncond);%only the Zs




if size(k,2) == 1
    for i = 1:size(dsepsetxy,2)
        pres = size(find(dsepsetxy(:,i)==k),1);
        if pres > 0
            ispresent = 1;
            break;
        end
    end
else
    listz = nchoosek(1:size(dsepsetxy,2),size(k,2));%form all the subsets of indices in the conditional set to form subset of the size of Z
    zs = perms(k);%Test if z1,z2,z3 are in the d-sep is equivalent to test z2,z1,z3
    for r = 1:size(listz,1)
       l = listz(r,:);
       %fprintf('Creating a subset of the conditional set of size %d with the indexes:',size(k,2))
       %l
       dsepsetxy_size_z = dsepsetxy(:,l);%creating a subset, of the conditionning variables rendering x and y independent, of size z
       %fprintf('The subset of the conditional sets rendering %d and %d independent of size %d and indexes %d %d is of size %d\n',i,j,size(k,1),l(1),l(2),size(dsepsetxy_size_z,1))
       for s = 1:size(zs,1)%for each permutation of z
           dsepsetxy_size_z_f = reshape(dsepsetxy_size_z',1,[]);%convert into a vector
           vx = zs(s,:);%takes the permutation of Z
           ri = strfind(dsepsetxy_size_z_f,vx);
           if isempty(ri) || ri == 0
               ispresent = 0;
           else
               idx = ((ri-1)/size(k,2))+1;%locating the string k (=[k1,k2...]) in the reshaped matrix of all conditional set separating x and y subset to have size of z
               if idx == floor(idx)%check that the index we found corresponds to the begining of a row in dsepsetxy_size_z
                   ispresent = 1;
                   break;
               end
           end
       end
       if ispresent > 0
           break;
       end
    end
end
end