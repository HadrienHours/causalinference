function [] = clustered_kpc(M,alpha,delta_m,delta_c,shuff,K,outputfile)
% clustered version of the kpc algorithm
% first operate a clusterization of the input and then operate the kpc on
% each cluster independently
%   INPUTS
%           M = n*p matrix representing n samples of p dimensions
%           alpha = significance value used for independence test
%           delta_m = threshold used for pruning high value in the
%                     relevance vector machine (RVM) regression
%           delta_c = convergence threshold for the RVM
%           shuff = number of shuffles used to test independence in the
%                   computation of the HSIC
%           K = number of clusters used in the Kmeans

%datas = csvread('/homes/hours/PhD/datas/matlab_buckets/2103_1104_1604_2012_compressed.csv',1,0);

%Compute the indexes of all the cluster assignement for each value
IDX = kmeans(M,K);

%the clusters
C = cell(K,1);

%the indexes for each cluster
cidx = cell(K,1);


for i=1:K
   cidx{i}=find(IDX==i);
   size(cidx{i})
end

%filling of each cluster
for i=1:K
    for j = 1:size(cidx{i},1)
        C{i} = [C{i};M(cidx{i}(j,1),:)];
    end
%     size(C{i})
end
diary(outputfile);
for k=1:K
    fprintf('Starting cluster number %d of size %d\n',k, size(C{k},1));
    warning('off');
    flag2 = 1;
    alpha1 = alpha - 0.1;
    while flag2 && (alpha1 < 0.4)
        alpha1 = alpha1 + 0.1;
        %flag = 0;
        delta_m1 = delta_m / (1e4);
        %flag2 = 1;
        while flag2 && (delta_m1 < 1e21)
            delta_m1 =delta_m1*1e4;
            flag2 = 0;
            try
                fprintf('Starting kpc with parameter alpha = %g, delta_max = %g, delta_conv = %g\n',alpha1,delta_m1,delta_c);
                kpc_param(C{k},alpha1,delta_m1,delta_c,shuff)
            catch ME
                ME
                %flag=1;
                flag2=1;
            end
        end
    end
end
diary OFF