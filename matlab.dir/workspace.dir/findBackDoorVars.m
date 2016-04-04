function [blockingset] = findBackDoorVars(x,y,G)
%This function return the variables verifying the back-door criterion for
%predicting the effect on y of intervening on x
%Input
%       x: dim of x
%       y: dim of y
%       G: A graph were G(i,j) = -1 means that there is an edge X_i -> X_j
%                       G(i,j) = G(j,i) = 1 X_i <-> X_j
%Output
%       blokcingset: a cell where each matrix is a set of indices blocking
%       the path between X and Y

p = size(G,1);

if size(G,2) ~= p
    error('The matrix must be square');
end

if size(find(diag(G)==0),1) ~= p
    error('G must have a 0 diagonal');
end

incoming_vert = find(G(:,x)==-1);

    