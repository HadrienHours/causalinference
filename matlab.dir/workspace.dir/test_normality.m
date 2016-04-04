function [] = test_normality(M,clustern)
%this function takes the observations, cluster it into zones of homogeneous
%variations and for each cluster and dimension test wether it following the
%normal distribution. The test used is Kolmogorov Smirnov at 5%
%significance level
%
%INPUT  M: n*p matrix (n samples, p dimensions)
%       cluster_n: number of clusters

T = clusterdata(M,'linkage','ward','maxclust',clustern);
n = 1;
s=[];
while size(find(T==n),1) ~= 0
    s=[s,size(find(T==n),1)];
    n=n+1;
end

n = n-1;

fprintf('Number of clusters found is %d\n',n);
for i=1:n
    fprintf('The size of the cluster number %d is %d\n',i,s(i));
end

fprintf('-------------------------------------\n-------------------------------------\n\n');

clusters = cell(1,n);
for i=1:n
    clusters{i} = M(find(T==i),:);
end

for i=1:n
    for j=1:size(clusters{i},2)
        dij = (clusters{i}(:,j) - mean(clusters{i}(:,j)))/std(clusters{i}(:,j));
        %The null hypothesis is that x has a standard normal distribution. 
        %The alternative hypothesis is that x does not have that distribution.
        %The result h is 1 if the test rejects the null hypothesis at the 5% significance level,
        %0 otherwise.
        [h,p,ksstat,cv] = kstest(dij);
        if ~h
            fprintf('The dimension %d in the cluster %d follows a normal distribution with p-val %g\n',j,i,p);
        else
            fprintf('The dimension %d in the cluster %d DOES NOT follows a normal distribution with p-val %g\n',j,i,p);
        end
    end
    fprintf('-------------------------------------\n-------------------------------------\n\n');
end
