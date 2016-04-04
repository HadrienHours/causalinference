function [margins,cums,multiprob,cmultiprob,rho,nu] = create_probabilities4(M,methodk,methodc,nfig,fontsize,labels)
%This function takes as input the dataset of n observed samples of p
%dimension and output their estimated multidimensional density function
%evaluated at the points corresponding to the given samples. This function
%first use kernel to compute cumulative function of each marginal and then
%a copula to deduce the multivariate estimate of the density
% 
% INPUTS:
%         M:       n*p matrix corresponding to n observation of p parameters
%         methodk: A string corresponding to the type of kernel to use for
%                  marginals estimation (normal,box,triangle,epanechnikov)
%         methodc: A string corresponding to the type of copula to use for 
%                  multidimensional estimation from marginals[t,Gaussian]
%         nfig:    The number of figures per line in the plots
%         fontisze:The size of the font for the graphs label/titles/axis
%         labels (optional) : The list of the name of each dimension
% OUTPUTS
%         margins:   a cell of p matrix of 2*n matrices corresponding to the 
%                    sample in each dimension and their corresponding density 
%                    probability function
%         multiprob: a n*1 corresponding to the multidimensional density 
%                    function evaluate for each sample
%         cmultiprob: a n*1 vector corresponding to the multidimensional
%                    cumulative distribution evaluated for each input sample

n = size(M,1);
p = size(M,2);

margins = cell(1,p);
cums = cell(1,p);
N = zeros(size(M));
Mn = zeros(size(M));
Ms =  cell(1,p);

%Use kernel method to estimate the CDF and DF for each marginal
for i=1:p
    if strcmp(methodk,'normal')
        margins{i} =[M(:,i)';ksdensity(M(:,i)',M(:,i)','function','pdf','kernel','normal')];
        cums{i} = [M(:,i)';ksdensity(M(:,i)',M(:,i)','function','cdf','kernel','normal')];
    elseif strcmp(methodk,'box')
        margins{i} = [ M(:,i)';ksdensity(M(:,i)',M(:,i)','function','pdf','kernel','box')];
        cums{i} = [M(:,i)';ksdensity(M(:,i)',M(:,i)','function','cdf','kernel','box')];
    elseif strcmp(methodk,'triangle')
        margins{i} = [ M(:,i)';ksdensity(M(:,i)',M(:,i)','function','pdf','kernel','triangle')];
        cums{i} = [M(:,i)';ksdensity(M(:,i)',M(:,i)','function','cdf','kernel','triangle')];
    elseif strcmp(methodk,'epanechnikov')
        margins{i} = [ M(:,i)';ksdensity(M(:,i)',M(:,i)','function','pdf','kernel','epanechnikov')];
        cums{i} = [M(:,i)';ksdensity(M(:,i)',M(:,i)','function','cdf','kernel','epanechnikov')];
    else
       error('Kernel type chosen not recognized (normal,box,triangle,epanechnikov')
    end
    
    %Store the results
    N(:,i) = cums{i}(2,:)';
    %Normalized value of M
    Mn(:,i) = M(:,i)/norm(M(:,i));
end


%Compute the muldimensional density and CDF using Copula of the chosen type
if strcmp(methodc,'Gaussian')
%     N
%     pause
    rho = copulafit('Gaussian',N);
    multiprob = copulapdf('Gaussian',N,rho);
    cmultiprob = copulacdf('Gaussian',N,rho);
    nu = 0;
elseif strcmp(methodc,'t') 
   [rho,nu] = copulafit('t',N);
   multiprob = copulapdf('t',N,rho,nu);
   cmultiprob = copulacdf('t',N,rho,nu);
else
    error('Copula type chosen not recognized (Gaussian or t)')
end

nlines = ceil((p)/nfig);

cdfMs = cell(1,p);
for i=1:p
    [V,I] = sort(cums{i}(1,:));
    cdfMs{i} = cums{i}(:,I);
end
    

figure()
for i=1:p
    subplot(nlines,nfig,i)
    x = cdfMs{i}(1,:);
    y = cdfMs{i}(2,:);
    plot(x,y,'linewidth',2)
    xlabel('Samples values','Fontsize',fontsize)
    ylabel('Frequency','Fontsize',fontsize)
    if nargin == 6
        t=strcat('CDF dimension ',labels{i},' (*',methodk,'* kernel)');
    else
        t=strcat('CDF dimension ',num2str(i),' (*',methodk,'* kernel)');
    end
    title(t,'Fontsize',fontsize)
    set(gca,'FontSize',fontsize)
end


figure()
for i=1:p
    subplot(nlines,nfig,i)
    x = margins{i}(1,:);
    [v,xs] = sort(x);
    y = margins{i}(2,:);
    ys = y(xs);
    plot(v,ys,'linewidth',2)
    xlabel('Samples values','Fontsize',fontsize)
    ylabel('Frequency','Fontsize',fontsize)
    if nargin == 6
        t=strcat('   Marginal dimension ',labels{i},' (*',methodk,'* kernel)');
    else
        t=strcat('   Marginal dimension ',num2str(i),' (*',methodk,'* kernel)');
    end
    title(t,'Fontsize',fontsize)
    set(gca,'FontSize',fontsize)
end

[v,I] = sort(M(:,1));
figure()
plot(multiprob(I),'linewidth',2)
hold all
v = cums{1}(2,I);
w = cums{1}(1,I);
plot(v*max(multiprob),'r','linewidth',2)
legend('Multidim density', 'Dimension 1 CDF','Fontsize',fontsize,'Location','NorthWest')

for i=1:100:n
    t = strcat('\leftarrow ',num2str(w(i)),' sample *',num2str(i));
    tf=fontsize-4;
    text(i,v(i)*max(multiprob),t,'HorizontalAlignment','left','Fontsize',tf)
end
xlabel('Sample sequence','Fontsize',fontsize)
ylabel('Frequency','Fontsize',fontsize)
if nargin == 6
    t = strcat('Estimated multidimensional density function using a *',methodc,'* copula and marginals estimated from  *',methodk,'* kernels ordered for dimension ',labels{1});
else
    t = strcat('Estimated multidimensional density function using a *',methodc,'* copula and marginals estimated from  *',methodk,'* kernels ordered for dimension 1');
end
title(t,'Fontsize',fontsize)
set(gca,'FontSize',fontsize)