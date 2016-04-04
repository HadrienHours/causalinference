function [sets] = findsetN(list,N)
%This function creates all the set of size N from a given list
%Input
%       list: list of of number
%       N: set size
%output
%       sets: sets of size N

sl = size(list,2);

if sl < N
%    fprintf('The list does not have enough element (%d) for creating sets of size %d\n',sl,N)
   sets = {};
else
    out1 = combnk(list,N);
    n = size(out1,1);
    sets = cell(1,n);
    for i = 1:n
        sets{i} = out1(i,:);
    end
end