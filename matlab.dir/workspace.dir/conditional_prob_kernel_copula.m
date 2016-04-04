function [fy] = estimate_conditional_probability(ds,names,x,y,Dx,filter,N,method,pathout)
%This function return the probability of f_y(y / x \in Dx)
%INPUTS
%	ds: dataset
%	names: cell containing labels (mandatory put to [] and X1,... will be used)
%	x: dim of x
%	y: dim of y
%	Dx: conditioning set domain
%	filter: must be a value between 0 and 1 (<1) for removing out of IQR values
%	N: number of points to estimate the densities
%	method: Gaussian or t
%	pathout[optional] if given the plots and data will be saved at this location
%OUTPUTS
%	fy : N*2 matrix representing for each y the value of f_y(y / x \in Dx)
%Usage
%	[fy] = estimate_conditional_probability(ds,names,x,y,Dx,filter,N,method,pathout)

if filter >= 1 || filter < 0
	error('Filter value must be in [0,1[');
end

if size(Dx,2) ~= 2 || Dx(1) > Dx(2)
	error('Dx must be an interval, see help');
end

if isempty(pathout)
	[xmi,mpi,xpi,marginalspdf,xci,marginalscdf] = multidimdensitykernelcopula(ds,names,[x,y],filter,N,method);
else
	[xmi,mpi,xpi,marginalspdf,xci,marginalscdf] = multidimdensitykernelcopula(ds,names,[x,y],filter,N,method,pathout);
end

m = max(max(2*xmi - xpi - xci));

if m > 0
	error('The support of marginals and multidimensional do not match');
end

x1 = Dx(1);
x2 = Dx(2);
Ix = find(xmi(:,1) <= x2 && xmi(:,1) >= x1);
sx = size(Ix,1)

f1 = zeros(sx,3);
for i = 1:sx
	f1(i,1) = xmi(Ix(i),1);
	f1(i,2) = xmi(Ix(i),2);
	f1(i,3) = mpi(Ix(i))/marginalspdf(Ix(i),1); %f(Y=y/X=x) = f_{y,x}(Y = y, X= x)/f_{x}(X=x)
end


