function [] = plot_cluster(data,minsize)
% Cluster the data into cluster of average size minsize trying to reduce
% the variance of the dimension in which it is higher

s1 = size(datas,1);
s2 = size(datas,2);

[m1,d1] = max(var(data));
T1 = clusterdata(data(:,d1),'linkage','ward','maxclust',floor(s1/minsize));
m1 = max(T1);
clusters1=cell(m1,1);
for i=1:m1
clusters1{i}=data(T1==i,:);
end
for i=1:m1
    figure(i)
    subplot(3,2,1)
    plot(clusters1{i}(:,1))
    xlabel('samples number');
    ylabel('loss rate (pckt/pckt)');
    subplot(3,2,2)
    plot(clusters1{i}(:,2))
    xlabel('samples number');
    ylabel('Throughput (bytes/ms)');
    subplot(3,2,3)
    plot(clusters1{i}(:,3))
    xlabel('samples number');
    ylabel('RTT (ms)');
    subplot(3,2,4)
    xlabel('samples number');
    ylabel('Size (bytes)');
    plot(clusters1{i}(:,4))
    subplot(3,2,5)
    plot(clusters1{i}(:,5))
    xlabel('samples number');
    ylabel('Loading Time (ms)');
    subplot(3,2,6)
    title(['cluster ',num2str(i)]);
end