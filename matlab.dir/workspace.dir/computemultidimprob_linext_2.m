function [x,fx] = computemultidimprob_linext(ds,dimx,N,methodk,methodc)
%This function uses kernel to compute marginals and copula for computing
%the multidimensional probability 
%input
%           ds: dataset
%           dimx: the dimesions for the multivariate
%           N: The number of points for density support
%           methodk: kernel type [default: normal]
%           methodc: copula type [default: t]
%output
%       [x,fx]

n = size(ds,1);
p = size(ds,2);
nx = size(dimx,2);

if nargin < 3
    error('Not enough args, see help');
elseif nargin == 3
    methodk = 'normal';
    methodc= 't';
elseif nargin == 4
    methodc = 't';
else
    error('Too many args, see help');
end

%compute marginals
margins_1c = zeros(n,nx);
margins_1p = zeros(n,nx);
support_1 = zeros(n.mx);
margins_2c = zeros(N,nx);
margins_2p = zeros(N,nx);
support_2 = zeros(N,nx);

for i = 1:nx
    d = dimx(i);
    support_2(i,:) = linspace(min(ds(:,d)),max(ds(:,d)),N);
    [margins_1c(i,:),support_1(i,:)] = ksdensity(ds(:,d),ds(:,d),'method',methodk,'function','cdf');
    margins_1p(i,:)= ksdensity(ds(:,d),ds(:,d),'method',methodk,'function','pdf');
    margins_2c(i,:) = ksdensity(ds(:,d),support_2(i,:),N,'method',methodk,'function','cdf');
    margins_2p(i,:) = ksdensity(ds(:,d),support_2(i,:),N,'method',methodk,'function','pdf');
end

%compute multidim
if strcmp(methodc,'t')
    [rho,nu] = copulafit('t',margins_1c);
    cx = copulapdf('t',margins_2c,rho,nu);
    fx = cx;
    for i = 1:nx
        fx=fx.*margins_2p(i,:);
    end
elseif strcmp(methodc,'Gaussian')
    [rho] = copulafit('Gaussian',margins_1c);
    cx = copulapdf('Gaussian',margins_2c,rho);
    fx = cx;
    for i = 1:nx
        fx=fx.*margins_2p(i,:);
    end
else
    error('Only t and Gaussian copulae supported');
end

x = support_2;