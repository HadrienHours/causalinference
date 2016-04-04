function [coeffs,stats,header] = multivarcoefflinearregression(ds,maxdegree,maxset,labels)
%This function is operating a linear regression on combinatorial set of
%size up to maxset for degree up to maxdegree
%usage
%   [coeffs] = multivarcoefflinearregression(ds,maxdegree,maxset)
%   [coeffs] = multivarcoefflinearregression(ds,maxdegree,maxset,labels)
% labels is optional to give the name of the parameters of the set

n = size(ds,1);
p = size(ds,2);

alpha = 0.05;

if nargin < 3
    error('The function needs the dataset, maximum polynomial degree and maximum set size');
elseif nargin == 3
    labels = cell(1,p-1);
    for i = 1:p-1
        labels{i} = strcat('X',num2str(i));
    end
end

if maxset > p-1
    error('Cannot create set of size bigger than the number of parameters');
end

[X,header] = createmultidegreesizesets(ds(:,1:p-1),maxdegree,maxset,labels);
    

[coeffs,stats] = regressAndTest(X,ds(:,p),alpha);

% Sx = size(X,2);
% 
% stats = zeros(Sx,2);
% 
% for i = 1:Sx
%     c = corr([X(:,i),ds(:,p)]);
%     stats(i,1) = cond_indep_fisher_z(1,2,[],c,n,alpha);
%     stats(i,2) = indtestimpl(1,2,[],[X(:,i),ds(:,p)],alpha);
% end
% 
% coeffs = zeros(Sx+1,1);
% 
% size(X)
% size(ds(:,p))
% 
% cx = regress(ds(:,p),X);
% 
% coeffs = cx';
% 
% clear cx;