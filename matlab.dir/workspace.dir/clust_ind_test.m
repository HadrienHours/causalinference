function [qglobs,pglobs] = clust_ind_test(M,alpha,shuffles)
%this function return the average p and q value from HSIC criteria tested
%on every cluster made by reducing the variance of the highest dimension
%variance

%INPUT
%         M :     n*p matrix n samples p dimensions
%         alpha:  relevance level
%         shuffles: number of permutations to make to test null distribution of HSIC

[v,d] = max(var(M));
fprintf('In the independence clustered test, the dimension with the highest variance (%d) is the %d\n',v,d);
s1 = size(M,1);
s2 = size(M,2);
maxclust = floor(s1/100);
T = clusterdata(M(:,d),'linkage','ward','maxclust',maxclust);
clusters = cell(1,maxclust);
for i=1:maxclust
    clusters{i} = M(find(T==i),:);
    fprintf('Size of cluster %d in independence test is %d\n',i,size(clusters{i},1));
end

pglobs = zeros(s2);
qglobs = zeros(s2);
for i=1:maxclust
    if(size(clusters{i},1) > 75)
        for j=1:s2
            for k=1:s2
                if j~=k
                    [q,p] = hsicTestBootIC(clusters{i}(:,j),clusters{i}(:,k),alpha,shuffles);
                    pglobs(j,k)=pglobs(j,k)+p*(size(clusters{i},1)/size(M,1));
                    qglobs(j,k)=qglobs(j,k)+q*(size(clusters{i},1)/size(M,1));
                end
            end
        end
    end
end