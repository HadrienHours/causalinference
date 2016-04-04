function [neighbors] = findNeighborsN(G,x,y,N)
%This function returns the neighbors common to X and Y to form set of size
%N. The difference for this function is that if N >= 2 we can have X and Y
%separated by a set of nodes some of which are not direct neighbor of X or
%Y
%Inputs
%   G: N*N matrix representing the graph
%   x: The first node
%   y: The second node
%   N: The set size [depth]
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
neighborsx = find(Gx);
Gy = G(y,:);
neighborsy = find(Gy);

if N == 1
    neighborsxy = intersect(neighborsx,neighborsy);
elseif N >= 2
    neighborsxy = setdiff(setdiff(unique(union(neighborsx,neighborsy)),x),y);
    %It is useless to check the neighbors of nodes which were already added
    %in previous steps
    addedlist = neighborsxy;
    c = 1;
    while c < N
        for i = 1:size(addedlist,2)
            Gn = setdiff(setdiff(G(neighborsxy(i),:),x),y);
            In = interesct(Gn,neighborsxy);
            addedlist = In; %only the lastly added nodes will be checked at the next step
            neighborsxy = [neighborsxy,In];
        end
        c = c+1;
    end
end

neighbors = findsetN(neighborsxy,N);