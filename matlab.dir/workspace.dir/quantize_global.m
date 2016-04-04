function [dspq,dsp,edges,centroids] = quantize_global(ds,k,b)
%This function gives the probability of each samples by using kmeans first
%to compute probability and then quantize the centroids so that they fit in
%the bins defined by the dataset
%inputs
%       ds: n*p matrix representing n samples of p parameters
%       k: number of clusters for k means
%       b: number of samples per bin (target)
%output
%       dspq = k*p+1 dataset corresponding to centroid moved 
%              into quantize bins  and their corresponding probability
%       dsp = k*p+1 matrix: dataset corresponding to the centroids and
%       their corresponding probability
%       edges = cell of k matrices of 6 columns representing the bins
%               used for quantization [bin_left,bin_right,value,prob,nsamples]
%       centroids = k centroids obtained from k means

n = size(ds,1);
p = size(ds,2);

plot = 1;

flag = 0;
while flag == 0
    try
        flag=1;
        [index,centroids] = kmeans(ds,k);
    catch
%         fprintf('Clustering Fail\nTry again\n\n')
        flag=0;
    end
end

% fprintf('Clustering succeeded with %d clusters\n',k);

clusters = cell(1,k);

for i = 1:k
    clusters{i} = ds(find(index==i),:);
end

dsp = zeros(k,p+1);
dsp(:,1:p) = centroids;

for i = 1:k
    dsp(i,p+1) = size(clusters{i},1)/n;
end



if plot
    X = [1:k];
    Y = dsp(:,p+1)*n;

    figure()
    bar(X',Y')
    % text(X',Y',num2str(Y','%.2g'),'HorizontalAlignment','center','VerticalAlignment','bottom','Color',[1 0 0],'Fontsize',16)
    set(gca,'Fontsize',16)                                                                                  
    xlabel('Clusters','Fontsize',16)
    ylabel('Number of Samples','Fontsize',16)
    title('Number of samples per cluster','Fontsize',16,'Fontweight','bold')
    grid on
end

edges = quantize_fixedweight(ds,b);
[dspq,dspp,dspc] = quantize_function(dsp(:,1:p),edges);

dspq = [dspq,dsp(:,p+1)];



