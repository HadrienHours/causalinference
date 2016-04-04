function [coeffs,stats] = regressAndTest(X,Y,alpha)
%This function test indpendence of each parameter of X with Y and compute
%the linear regression coefficients of Y on X.
%Usage
%       [coeffs,stats] = regressAndTest(X,Y,alpha)

if nargin ~= 3
    error('Wrong number of arguments, see help');
end

n = size(X,1);

Sx = size(X,2);

stats = zeros(Sx,2);

for i = 1:Sx
    c = corr([X(:,i),Y]);
    fprintf('Testing independence for the %d column\n',i);
    stats(i,1) = cond_indep_fisher_z(1,2,[],c,n,alpha);
    stats(i,2) = indtestimpl(1,2,[],[X(:,i),Y],alpha);
end

coeffs = zeros(Sx+1,1);

cx = regress(Y,X);

coeffs = cx';

clear cx;