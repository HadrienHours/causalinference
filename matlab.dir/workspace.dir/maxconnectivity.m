function [m] = maxconnectivity(G)
%This function returns the maximum connectivity of the graph G

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

%Count the number of neighbors per node
S = sum(M);

m = max(S);
