function [neighbors] = findNeighbors(G,x)
%This function returns the neighbors of x
%Inputs
%   G: N*N matrix representing the graph
%   x: The node
%Output:
%   Neighbors: list of neigbors of x

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

Gx = G(x,:);
neighbors = find(Gx);