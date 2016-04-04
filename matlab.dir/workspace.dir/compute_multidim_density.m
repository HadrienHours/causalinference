function probability = compute_multidim_density(M,flag_filter,flag_t,method)
% This function take as input a dataset corresponding to the observations
% of p dimensions and compute the corresponding multidimensional
% probability. First using histogram for each dimension individually it
% computes the marginals. Then, from these marginals, using different
% families of copulas compute the multidimensional
% 
% INPUTS
%         M = n*p matrix representing the n samples of the p dimensions observed
%         flag_filter = set to 1 if the Interquantile filtering is applied on the data for creating histogram and IQRS is used instead of standard deviation
%         flag_t = set to 1 if the approximate Maximum Likelihood is used
%         method = the type of copula to use (Gaussian,t,clayton,frank,gumble. The last three only for p = 2
% OUTPUTS
%         probability = n*1 vectore : the multi dimensional probability function estimated for each input point

nsamples = size(M,1);
ndims = size(M,2);

%Get the histogram computed marginals
[margins,histos,edges,axis,binsw] = create_probabilities2(M,flag_filter);

cumulatives = zeros(nsamples,ndims);


for i=1:ndims
    for j = 1:nsamples
%         fprintf('Entering cum_fhist function with the following inputs for sample %d on dimension %d:\n',j,i)
%         fprintf('Histogram:\n')
%         histos{i}
%         fprintf('Edges:\n')
%         edges{i}
%         fprintf('The value to evaluate:\n')
%         M(j,i)
%         pause
        cumulatives(j,i) = cum_fhist(histos{i},edges{i},M(j,i));
    end
end


% probs = zeros(size(M));
% 
% for i=1:ndims
%     probs(:,i) = margins{i}(2,:)';
%     probs(:,i) = probs(:,i)/norm(probs(:,i));
%     
%         
% end
 
% for i=1:ndims
%     fprintf('The cumulative density function for dimension %d is:\n',i)
%     cumulatives(:,i)
%     pause
% end



if strcmp(method,'Gaussian')
    %Get parameters of the gaussian copula
    RHOHAT_g = copulafit('Gaussian',cumulatives);
    cumulatives
    pause
    probability = copulapdf('Gaussian',cumulatives,RHOHAT_g);

elseif strcmp(method,'t')
    %Get parameters of the t-copula
    if flag_t
        [rhohat_t,nuhat_t,nuci] = copulafit('t',cumulatives,'Method','ApproximateML');
    else
        [rhohat_t,nuhat_t,nuci] = copulafit('t',cumulatives);
    end
    fprintf('The 95%% confidence interval for the degree of freedom parameters estimated in nuhat is:\n')
    nuci
    probability = copulapdf('t',cumulatives,rhohat_t,nuhat_t);

elseif strcmp(method,'Clayton') || strcmp(method,'Frank') || strcmp(method,'Gumble')
    if ndims  ==2
        %Get parameter for an archimede copula
        if strcmp(method,'Clayton')
            [paramhat_c,paramci_c] = copulafit('Clayton',cumulatives);
            fprintf('The 95%% confidence interval in Clayton is:\n')
            paramci_c
            probability = copulapdf('Clayton',cumulatives,paramhat_c);
        elseif strcmp(method,'Frank')
            [paramhat_f,paramci_f] = copulafit('Frank',cumulatives);
            fprintf('The 95%% confidence interval in Frank is:\n')
            paramci_f
            probability = copulapdf('Frank',cumulatives,paramhat_f);
        elseif strcmp(method,'Gumble')
            [paramhat_g,paramci_g] = copulafit('Gumble',cumulatives);
            fprintf('The 95%% confidence interval in Gumble is:\n')
            paramci_g
            probability = copulapdf('Gumble',cumulatives,paramhat_g);
        end
    else
        error('The method chosen only work in 2 dimensions\n')
    end
else
    error('The method chosen has not been recognized. Choose in [Gaussian,t,Clayton,Frank,Gumble]')
end


figure()
nf = ndims+1;
nl = ceil(nf/3);
for i=1:ndims
    subplot(nl,3,i)
    plot(M(:,i)')
    t = strcat('Samples on dimension',num2str(i));
    xlabel('Samples number');
    ylabel('Samples values');
    title(t);
end
subplot(nl,3,nf)
plot(probability')
xlabel('Samples numbers')
ylabel('Evaluated function of the multidimensional probability')
t = strcat('Result of the multidimensional estimation of the probability using a ',method,' copula')
title(t)
