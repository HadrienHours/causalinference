function w = sliding_window(y,N)
% Recompute the output of the given vector by applying a sliding window of width N
% 
% INPUTS
%             y: vector
%             N : Window size
% OUTPUT
%             v : vector
n = ceil(N/2);

w = ones(n,1)*mean(y(1:n));

for i=n+1:size(y,1)-n
    w=[w;mean(y(i-n:i+n))];
end

w=[w;mean(y(size(y,1)-n:end))*ones(n,1)];