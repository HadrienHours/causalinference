function y_out = sliding_window_2(y,N)
% Recompute the output of the given vector by applying a sliding window of width N
% 
% INPUTS
%             y: vector
%             N : Window size
% OUTPUT
%             v : vector
n = ceil(N/2);
y_out = zeros(size(y));
y_out(1) = y(1);
y_out(end) = y(end);
%take the mean overwindow centered on iith value
for ii = 2:n
    y_out(ii) = mean(y(1:2*ii-1));
end

for ii=n+1:length(y)-n
    y_out(ii) = mean(y(ii-n:ii+n)); 
end

for ii = length(y)-n:length(y)-1
   iu = length(y);
   il = 2*ii-length(y);%the distance between ii and end is length(y) - ii, so to have same number on left side of the window ii - (length(y)-ii) 
   y_out(ii) = mean(y(il:iu));
end