function [coll] = findcolliders(skeleton)
%This function returns the triplets {x,y,z} where x is connected to z, y is
%connected to z but x and y are not connected
%Usage
%       [x,y,z] = findcolliders(skeleton);

G = skeleton;

if size(G,1) ~= size(G,2)
    error('The matrix must be square');
end

%Test symetry
[ix,iy] = find(G);
[iX,iY] = find(G');

if ~isequal([ix,iy],[iX,iY])
    error('The matrix is not symetric');
end

I = find(diag(G));

if ~isempty(I)
    error('Not taking retro action into account, the diagonal must be zero');
end

N = size(G,1);

% %Put the lower part of the matrix to zero, x-y = y-x
% Tu = triu(ones(N),1);
% Td = tril(ones(N),-1);
% Md = G.*Td;
% Mu = G.*Tu;

[X,Y] = find(G);

coll = [];

for i = 1:size(X,1)
   x = X(i);
   y = Y(i);
   %Contains y neighbors
   Z = find(G(y,:));
% %    Z = find(Mu(y,:));
% %    if isempty(Z)
% %        Z = find(Md(y,:));
% %    end
   Z = setdiff(Z,[x]);
   if ~isempty(Z)
       for j = 1:size(Z,2)
          z = Z(j);
          if G(x,z) == 0 && G(y,z) == 1 && G(x,y) == 1
              coll = [coll;x y z];
          end
       end
   end
end

s = size(coll,1);
c = 1;

while c < s
    li = coll(c,end:-1:1);
    [pres,idx] = ismember(li,coll,'rows');
    if pres > 0
        coll = removerows(coll,idx);
    else
        c = c+1;
    end
    s = size(coll,1);
end