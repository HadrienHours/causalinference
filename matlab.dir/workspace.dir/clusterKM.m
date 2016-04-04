function [clusterf,centroidsf,idxf,distf,Kf] = clusterKM(dataset,listvartorm,nreps,normalz)
%This function applies the K means to cluster the dataset given as input.
%The function starts with K = 1 and increase K until the new clustering
%increases the overall distance of points to their centroid
%
%Inputs
%   dataset = n*m matrix, n observations of m features
%    listvarstorm = list of parameters dimensions not to consider for the
%    clustering
%    nreps [OPTIONAL] = Number of times to run the function and keep the
%    min distance clustering (default 1)
%    normalz [OPTIONAL] = if set to 1 normalized the dataset, default 0
%Outputs
%    clusters = cell of size K with the samples for each cluster
%    centroids = matrix K*(m-(length(listvarstorm))) of the centroids
%    distance = smallest distance detected
%    indexes = cluster ID of each sample
%    Kf = final number of clusters

special_case = 1;
verbose = 1;

if nargin < 2 || nargin > 4
    error('Wrong number of inputs, see help');
end

if nargin == 2
    Nr = 1;
    Nm = 0;
elseif nargin == 3
    Nm = 0;
else
    Nr = nreps;
    Nm = normalz;
end

n = size(dataset,1);
p = size(dataset,2);

if ~isempty(listvartorm)
    listp = setdiff(1:p,listvartorm);
else
    listp = 1:p;
end

if verbose > 0
    fprintf('List of retained features:')
    listp
end

ds = zeros(n,length(listp));

if Nm > 0
    if verbose > 0
       fprintf('Normalizing the dataset\n'); 
    end
    for ii = 1:length(listp)
        ds(:,ii) = dataset(:,listp(ii)) - repmat(mean(dataset(:,listp(ii))), size(dataset,1), 1);
        ds(:,ii) = ds(:,ii)*diag(1./std(ds(:,ii)));
    end
else
    ds = dataset(:,listp);
end

distf = inf;
clusterf = {};
centroidsf = [];
idxf = [];
Kf = 0;
for l = 1:Nr
    fprintf('Starting iteration %d (/%d)\n',l,Nr)
    K = 0;
    dist_o = 1e40;
    dist_n = 1e30;
    centroid_n = cell(1,1);
    centroid_o = cell(1,1);
    idx_n = [];
    idx_o = [];
    while dist_o > dist_n
        dist_o = dist_n;
        centroid_o = centroid_n;
        idx_o = idx_n;
        K = K+1;
        [idx_n,centroid_n,D] = kmeans(ds,K);
        dist_n = sum(D);
    end
    %If new clustering better than previous ones, update
    if dist_o < distf
        distf = dist_o;
        idxf = idx_o;
        centroidsf = centroid_o;
        Kf = K-1;
        if verbose > 0
           fprintf('Updating clustering with new distance found of %g for %d clusters\n',distf,Kf); 
        end
    end
end

clusterf = cell(1,Kf);
for ii = 1:Kf
    idx_c = idxf==ii;
    clusterf{ii} = dataset(idx_c,:);
end

%Special use for cyber insurance, first column label 1 (Good) or 2 (Bad)
%   print stat per cluster
if special_case == 1
    for ii = 1:Kf
        fprintf('%d & %g & %d & %d & %.2g \\\\\n',ii,mean(clusterf{ii}(:,1)),length(find(clusterf{ii}(:,1)==1)),length(find(clusterf{ii}(:,1)==0)),length(find(clusterf{ii}(:,1)==0))/length(clusterf{ii}))
    end
end