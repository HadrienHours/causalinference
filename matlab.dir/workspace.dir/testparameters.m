function [coefflin,coeffpoly,testind,correlation,variances] = testparameter(ds,y,degree,names)
%This function test for each parameter of the dataset if it is impacting the variable of interest by linear and polynomial regression
%inputs
%	ds: n*p dataset of p parameters n samples
%	y: target variable position in the dataset
%	degree: polynom degree
%	names[option]: cell containing names
%output
%	coefflin: linear coefficients in regression (p*2), first value a, second b in Y = aX+b
%	coeffpoly: polynomial coefficients (p*(degree+1)) returned in decreasing degree order
%	variances
%	correlation
%	testindependence: hsic p val in independence test of var with y
%usage
%	[coefflin,coeffpoly,testind,correlation,variances] = testparameter(ds,y,degree)

if nargin < 3
	error('incorrect number of arguments, see help');
end

if size(y,1)*size(y,2) ~= 1
	error('y must be scalar, see help');
end

n = size(ds,1);
p = size(ds,2);

coefflin = zeros(p,2);
coeffpoly = zeros(p,degree+1);
testind = zeros(p,1);
correlation = zeros(p,1);
variances = zeros(p,1);

for i = 1:p
	if i ~= y
		correlation(i) = corr(ds(:,i),ds(:,y));
		coefflin(i,:) = polyfit(ds(:,i),ds(:,y),1);
		coeffpoly(i,:) = polyfit(ds(:,i),ds(:,y),degree);
		testind(i) = indtest_new(ds(:,i),ds(:,y),[],[]);
		variances(i) = var(ds(:,i));
	end
end

for i = 1:p
	if nargin == 4
		fprintf('%s\n',names{i})
	else
		fprintf('Parameter number %d\n',i)
	end
	fprintf('Correlation: %.3g\n',correlation(i))
	fprintf('Linear coefficient %.3g\n',coefflin(i));
	fprintf('Variance: %.3g\n',variances(i));
	fprintf('Product: %.3g\n',coefflin(i)*variances(i));
	fprintf('P-val HSCIC: %.3g\n',testind(i));
	fprintf('*****************************\n\n')
end
