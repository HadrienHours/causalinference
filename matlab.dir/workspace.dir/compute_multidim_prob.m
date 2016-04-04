function [prob] = compute_multidim_prob(rho,nu,copula,kernel,ds,val,delta)
% This function takes as inputs the parameters of the kernels and copula adn output the multidimensional probability corresponding to the vector val
% INPUTS: rho:    copula rho
%         nu:     copula nu
%         copula: string descrbing the type of Copula used ('Gaussian','t')
%         kernel: string describing the type of kernel used ('normal','box','triangle','epanechnikov')
%         ds:     dataset (n*p matrix corresponding to n samples of the p parameters)
%         val:    a r*p matrix corresponding to r values (of p dimension) of which we wants the probability
%         delta:  [optional] value defining an interval around each scalar of p to compute probability
% OUTPUT
%         prob:   r*2 column vector containing Pr(X < val), f(val)

if nargin < 6
    error('You need to give at least 6 arguments');
elseif nargin == 6
    delta = 0;
end

n = size(ds,1);
p = size(ds,2);
r = size(val,1);
cums = zeros(r,p);
prob = zeros(r,2);

for j = 1:p
    tmp = ksdensity(ds(:,j)',val(:,j)','function','cdf','kernel',kernel);
    cums(:,j) = tmp';
    fprintf('For dimension %d the size of cumulatives are %d, %d\n',j,size(cums(:,j)))
end

fprintf('The sizes of cums are %d, %d\n',size(cums))

%Compute the muldimensional density and CDF using Copula of the chosen type
if strcmp(copula,'Gaussian')
    multiprob = copulapdf('Gaussian',cums,rho);
    cmultiprob = copulacdf('Gaussian',cums,rho);
elseif strcmp(copula,'t') 
   multiprob = copulapdf('t',cums,rho,nu);
   cmultiprob = copulacdf('t',cums,rho,nu);
else
    error('Copula type chosen not recognized (Gaussian or t)')
end

fprintf('The sizes of cmultiprob are %d, %d\n',size(cmultiprob));
fprintf('The sizes of multiprob are %d, %d\n',size(multiprob));

prob = [cmultiprob,multiprob];