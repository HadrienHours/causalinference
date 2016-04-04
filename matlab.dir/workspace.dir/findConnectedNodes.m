function [nodes] = findConnectedNodes(G)
%This function returns the connected nodes from the graph G
%Input
%       Squared matrix of 0 and 1
%Output
%       list of nodes


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

%Put the lower part of the matrix to zero, x-y = y-x
T = triu(ones(N),1);
M = G.*T;

[x,y] = find(M);

nodes = cell(1,size(x,1));

for i = 1:size(x,1)
    nodes{i} = [x(i),y(i)];
end