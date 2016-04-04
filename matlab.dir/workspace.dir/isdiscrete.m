function [r] = isdiscrete(D,i,p)
%Test if the ith dimension of dataset D is discrete
%
%   isdiscrete(D,i)
%
%Inputs
%   D: n*p dataset
%   i: scalar: dimension
%   p: [optional] relevance level
%Output
%   r: r=1 if discrete 0 otherwise

if nargin == 2
    p = 0.05;
end

n = size(D,1);
k = n*p/10;
rm = zeros(1,size(i,2));

for l = 1:size(i,2)
    %unique values
    s = size(intersect(D(:,i(l)),D(:,i(l))),1)/n;
    if s < p
        rm(l) = 1;
    end
end

if sum(rm) == size(i,2)
    r =1;
elseif sum(rm) == 0
    r = 0;
else
    r=2;
end

% else
%     for i = 1:k
%         try
%             kmeans(D(:,i),k);
%         catch
%             fprintf('fail at %d\n',i);
%             r = 1;
%             break;
%         end
%     end
% end


