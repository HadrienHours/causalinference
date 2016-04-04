function [m] = subset2d(M,i,j);
%This function outputs the sub matrix of M consisting in the values indexed by i and j
%If the values are not consecutives then there will be 0 padding

dim_i = size(i,1);
dim_j = size(j,1);

if dim_i ~= dim_j
	error('i and j must be of same dimension');
end

x_m = min(i);
x_M = max(i);
y_m = min(j);
y_M = max(j);

dim_x = x_M - x_m + 1;
dim_y = y_M - y_m + 1;

m = zeros(dim_x,dim_y);

for idx = 1:dim_i
	xi = i(idx)-x_m+1;
	yi = j(idx)-y_m+1;
	m(xi,yi) = M(i(idx),j(idx));
end
