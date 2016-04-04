function [] = cluster_var(M,alpha,delta_m,delta_c,shuff,sizemin,outputfile)
% this function take the dimension with the highest variance and try to
% create uniform region for this parameter on which it applies the kpc
% algoritm
%INPUTS
%         M:      n*p matrix
%                     . n being the number of samples
%                     . p being the parameters observed
%         alpha:      relevance value to test independence
%         delta_m:    threshold to prune high value in the relevance vector machine
%         shuff:      number of permutations for testing HSIC null distribution
%         sizemin:    Minimum size of one cluster, use to approximate the
%                     number of clusters
warning('off');
[var_m, var_idx] = max(var(M));
N = M(:,var_idx);
n = floor(size(M,1)/sizemin);
T = clusterdata(N,'linkage','ward','maxclust',n);

%find how many clusters were found
i=1;
while( size(find(T == i),1) > 0)
    i=i+1  
end
ncl=i-1;
fprintf('%d clusters found with sizes:\n',ncl);

%store each cluster in a cell
clustindx = cell(ncl,1);
clustval  = cell(ncl,1);
for i=1:ncl
    clustindx{i} = find(T==i);
    fprintf('%d\n',size(clustindx{i},1));
    clustval{i} = M(clustindx{i},:);
    csvwrite(strcat('/homes/hours/PhD/datas/matlab_buckets/cluster',num2str(i)),clustval{i});
end
fprintf('Clusters written\n');
pause


diary(outputfile)
for i=1:ncl
    if size(clustval{i},1) > 80
        flag = 1;
        alpha_r = alpha -0.05;
        while flag && alpha_r < 0.35
            alpha_r = alpha_r+0.05;
            delta_mr = delta_m /1e2;
            while flag && delta_mr < 1e16
                delta_mr = delta_mr*1e2;
                try
                    fprintf('Launching kpc with parameters alpha %g, delta_m %g, delta_c %g, shuffles %d\n',alpha_r,delta_mr,delta_c,shuff)
                    fprintf('Cluster number %i with variance on dimension %d being %d\n' ,i,var_idx,var(clustval{i}(:,var_idx)));
                    kpc_param(clustval{i},alpha_r,delta_mr,delta_c,shuff)
                    flag = 0;
                catch ME
                    ME
                end
            end
        end
    else
        fprintf('Cluster number %d not evaluated because of size %d\n',i,size(clustval{i},1))
    end
end
diary off