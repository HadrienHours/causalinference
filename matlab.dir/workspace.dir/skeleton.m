function [skeleton,sepset] = skeleton(N,testindep,varargin)
%This function builds the skeleton of the caual graph using the
%independence test given as arguments
%Inputs
%       N: number of Nodes
%       testindep: independence test to use
%       vargin: The parameters for the test
%Output
%       skeleton: Matrix with 1 where there is an edge
%       sepset: The separating sets

G = ones(N,N);
G = G - eye(N);

MaxConnectivity = N;
setSize = 0;

sepset = cell(N,N);

while setSize < MaxConnectivity
    setxy = findConnectedNodes(G);
    
    for i = 1:size(setxy,2)
       if setSize == 0
          CI = feval(testindep,setxy{i}(1),setxy{i}(2),[],varargin{:});
          if CI > 0
             G(setxy{i}(1),setxy{i}(2)) = 0;
             G(setxy{i}(2),setxy{i}(1)) = 0;
          end
       else
%            setxy{i}(1)
%            setxy{i}(2)
           neigh_x = findNeighbors(G,setxy{i}(1));
           neigh_x = setdiff(neigh_x,setxy{i}(2));
           neigh_y = findNeighbors(G,setxy{i}(2));
           neigh_y = setdiff(neigh_y,setxy{i}(1));
           neigh_xy = unique(union(neigh_x,neigh_y));
           setNeighxy = findsetN(neigh_xy,setSize);
           
           for j = 1:size(setNeighxy,2)
              CI = feval(testindep,setxy{i}(1),setxy{i}(2),setNeighxy{j},varargin{:});
              if CI > 0
                  sepset{setxy{i}(1),setxy{i}(2)} = addtoset(sepset{setxy{i}(1),setxy{i}(2)},setNeighxy{j});
                  sepset{setxy{i}(2),setxy{i}(1)} = addtoset(sepset{setxy{i}(2),setxy{i}(1)},setNeighxy{j});
                  G(setxy{i}(1),setxy{i}(2)) = 0;
                  G(setxy{i}(2),setxy{i}(1)) = 0;
              end
           end
       end
    end
    setSize = setSize+1;
    MaxConnectivity = maxconnectivity(G);
end

skeleton = G;
