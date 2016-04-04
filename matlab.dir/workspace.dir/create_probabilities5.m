function [margins,multiprob] = create_probabilities5(M,methodk,methodc)
%This function takes as input the dataset of n observed samples of p
%dimension and output their estimated multidimensional density function
%evaluated at the points corresponding to the given samples. This function
%first use kernel to compute cumulative function of each marginal and then
%a copula to deduce the multivariate estimate of the density
% 
% INPUTS:
%         M: n*p matrix corresponding to n observation of p parameters
%         methodk: A string corresponding to the type of kernel to use for
%         marginals estimation (normal,box,triangle,epanechnikov)
%         methodc: A string corresponding to the type of copula to use for 
%         multidimensional estimation from marginals[t,Gaussian]
% OUTPUTS
%         margins: a cell of p matrix of 2*n matrices corresponding to the 
%         sample in each dimension and their corresponding density 
%         probability function
%         multiprob: a n*1 corresponding to the multidimensional density 
%         function evaluate for each sample

n = size(M,1);
p = size(M,2);

margins = cell(1,p);
cums = cell(1,p);
N = zeros(size(M));
Mn = zeros(size(M));
Mr = zeros(size(M));
Ms =  cell(1,p);

for i=1:p
   Mr(:,i) = sort(M(:,i)) 
end

for i=1:p
    if strcmp(methodk,'normal')
        margins{i} =[Mr(:,i)';ksdensity(Mr(:,i)',Mr(:,i)','function','pdf')];
        cums{i} = [Mr(:,i)';ksdensity(Mr(:,i)',Mr(:,i)','function','cdf')];
    elseif strcmp(methodk,'box')
        margins{i} = [ Mr(:,i)';ksdensity(Mr(:,i)',Mr(:,i)','function','pdf')];
        cums{i} = [Mr(:,i)';ksdensity(Mr(:,i)',Mr(:,i)','function','cdf')];
    elseif strcmp(methodk,'triangle')
        margins{i} = [ Mr(:,i)';ksdensity(Mr(:,i)',Mr(:,i)','function','pdf')];
        cums{i} = [Mr(:,i)';ksdensity(Mr(:,i)',Mr(:,i)','function','cdf')];
    elseif strcmp(methodk,'epanechnikov')
        margins{i} = [ Mr(:,i)';ksdensity(Mr(:,i)',Mr(:,i)','function','pdf')];
        cums{i} = [Mr(:,i)';ksdensity(Mr(:,i)',Mr(:,i)','function','cdf')];
    else
       error('Kernel type chosen not recognized (normal,box,triangle,epanechnikov')
    end
    N(:,i) = cums{i}(2,:)';
    Mn(:,i) = Mr(:,i)/norm(Mr(:,i));
end


if strcmp(methodc,'Gaussian')
    rho = copulafit('Gaussian',N);
    multiprob = copulapdf('Gaussian',Mn,rho);
elseif strcmp(methodc,'t') 
   [rho,nu] = copulafit('t',N);
   multiprob = copulapdf('t',Mn,rho,nu);
else
    error('Copula type chosen not recognized (Gaussian or t)')
end

nlines = ceil((p)/3);
    

figure()
for i=1:p
    subplot(nlines,3,i)
    plot(cums{1}(1,:),cums{i}(2,:))
    xlabel('Samples values')
    ylabel('Frequency')
    t=strcat('Marginal of the dimension ',num2str(i),' using ',methodk,' kernel ');
    title(t)
end

figure()
plot(multiprob)
xlabel('Sample sequence')
ylabel('Frequency')
t = strcat('Estimated multidimensional density function using a ',methodc,' copula and marginals estimated from ',methodk,' kernels');
title(t)