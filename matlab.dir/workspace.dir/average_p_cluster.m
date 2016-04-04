function [clusters, pvals,sigvals] = average_p_cluster(M,minsize,alpha,shuffles)
% For each dimension, cluster the data reducing the variance on this
% dimension and compute the p-value independence test for each variable
% INPUT : M n*p matrix, n samples, p dimensions
%         MINSIZE  the minimum size for the cluster
%         alpha    relevance value to test independence
%         shuffles number of permutation to test null distribution of HSIC
% output    
%           . clusters : cells containing. for each dimension the corresponding
%                   clusterization
%           . pvals : m cells of for each create cluster the p value for independence
%           teste between variables
%           . sigvals : results for each independence test between each
%           couple of dimensions for each cluster of each clustering
%

n=size(M,1);
p=size(M,2);

%Define the maximum number of clusters if all the cluster had the same size
N = floor(size(M,1)/minsize);

%will store the cluster index of each sample for each clustering
clusterind = cell(1,p);

%will store the number of cluster for each dimension
clust_n = zeros(1,p);

%contains cell which contain each cluster for each clusterization for each
%dimension : 1*p
clusters = cell(p,1);

%contains the independence test p value between each dimension of each
%cluster of each clustering
pvals = cell(p,1);

%contains the independence test results between each dimension of each
%cluster of each clustering
sigvals = cell(p,1);

for i=1:p
    %cluster with Ward method for each dimension
   clusterind{i} = clusterdata(M(:,i),'linkage','ward','maxclust',N);
   k=1;
   while(size(find(clusterind{i}==k),1) ~= 0)
       k=k+1;
   end
   k=k-1;
   fprintf('For clustering on dimension %d the number of clusters found is %d\n',i,k);
   clust_n(i)=k;
%    for each clustering corresponding to reducing variance in one
%    dimension we create a cell which will contain each cluster
   clusters{i} = cell(1,k);
   for j=1:k
      clusters{i}{j}=M(find(clusterind{i}==j),:);
      fprintf('The size of cluster numer %d in clustering of dimension %d is %d\n',i,j,size(clusters{i}{j},1));
   end
end

%For each dimension
for i=1:p
    pvals{i} = cell(clust_n(i),1);
    %For each cluster in this clustering of this dimension
   for j=1:clust_n(i)
       pvals{i}{j} = zeros(p,p);
       sigvals{i}{j} = ones(p,p)*(-1);
       %for each dimension in this cluster
       for k=1:p
          %for each other dimension
          for h=1:p
             if h ~= k
                [q,p] = hsicTestBootIC(clusters{i}{j}(:,k),clusters{i}{j}(:,h),alpha,shuffles);
                pvals{i}{j}(k,h) = p;
                sigvals{i}{j}(k,h) = q;
             end
          end
       end
   end
end