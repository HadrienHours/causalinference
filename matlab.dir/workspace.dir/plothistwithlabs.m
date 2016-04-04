function [] = plothistwithlabs(x,N)
%This function plot the histogram of X with label of each bar
% Input
%       x : the list of values
%       N : The number of bin (default = 10)
% Output
%       plot

if nargin == 1
    N = 10;
end

[C,B] = hist(x,N);

figure
bar(B, C)
ylim([0, max(C) * 1.2]);  %# Resize the y-axis
bx = B(2)-B(1);
%# Add a text string above each bin
for i = 1:numel(B)
    text(B(i) - 0.2*bx, C(i) + 0.1*C(i), ['y = ', num2str(C(i))], 'VerticalAlignment', 'top', 'FontSize', 8)
end