function [G] = compute_adjacency_matrix(npars,condset,pathlisttestedindeps,alpha)
%This function perform the first step of the PC algorithm until a given
%condset size and return the skeleton of the matrix
%
%Inputs
%       npars: number of parameters
%       condset: maximum conditioning set size to test for independence
%       pathlistindependences: path to csvfile (with header) containing the
%       tested independences in the format X,Y,Z1...Zcondset,S,N,pval
%       alpha: significance level for the independence test
%
%Output
%       G: adjacency matrix

if nargin ~= 4
    error('Not enough arguments, see help')
end

sep = cell(npars,npars);
ord = 0;
done = 0;
G = ones(npars,npars);
G=setdiag(G,0);

while ~done
  done = 1;
  [X,Y] = find(triu(G)); 
  for i=1:length(X)
    x = X(i); y = Y(i);
    nbrs = mysetdiff(myunion(neighbors(G, x), neighbors(G,y)), [x y]);
    if length(nbrs) >= ord & G(x,y) ~= 0
      done = 0;
      SS = subsets1(nbrs, ord);
      for si=1:length(SS)
        S = SS{si};
        if feval('testindepfromdb_pars_4', x, y, S, pathlisttestedindeps,alpha)
          G(x,y) = 0;
          G(y,x) = 0;
          sep{x,y} = myunion(sep{x,y}, S);
          sep{y,x} = myunion(sep{y,x}, S);
          break;
        end
      end
    end 
  end
  ord = ord + 1;
  if ord > condset
      done = 1;
  end
end