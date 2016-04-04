function [err,outputzlin] = computeerror()

%loading datasets
ds200 = csvread('/datas/xlan/hours/chalon/datasets/dropbox_trace/hourytest/bigfiles/dropboxhourglobal/csvfiles/delay200files.dir/dropboxdelay200rttlossrwintput',1,0);
ds200 = ds200(:,[1,3,4]);
zlinflatten = csvread('/datas/xlan/hours/chalon/datasets/dropbox_trace/hourytest/bigfiles/dropboxhourglobal/csvfiles/delay0_100_300.dir/dstput/resultsextrapolationlinear/Zlinflatten.csv');

%keeping only the cases where the rtt is around the values we want to predict
i1 = find(zlinflatten(:,1) > 0.290);
zlinflatten1 = zlinflatten(i1,:);
i2 = find(zlinflatten1(:,1) < 0.310);
zlinflatten2 = zlinflatten1(i2,:);

%getting the unique list of receiver window
listrwinuniq = unique(zlinflatten2(:,2));
p = size(listrwinuniq,1);
outputzlin = zeros(p,3);

%getting one value of throughput per receiver window averaging on rtt
counter=0;
for r=listrwinuniq'
counter=counter+1;
index=find(zlinflatten2(:,2) == r);
outputzlin(counter,:) = [mean(zlinflatten2(index,1)),r,mean(zlinflatten2(index,3))];
end

%doing the same as before for the real dataset
listuniqrwin = unique(ds200(:,2));
p = size(listuniqrwin,1);
ds200avg = zeros(p,3);

counter=0;
for r = listuniqrwin'
index = find(ds200(:,2) == r);
counter=counter+1;
ds200avg(counter,:) = [mean(ds200(index,1)),r,mean(ds200(index,3))];
end

%computing the error as the difference of throughput between the real one (computed as average for different rtt for a given rwin) and the average of the predicted throughput for rwin values in an interval of +0.05 -0.05 the given rwin
err_f = zeros(p,2);
counter = 0;
outputzlin3 = zeros(size(listuniqrwin,1),3);
for r = listuniqrwin'
counter=counter+1;
tputreal = ds200avg(find(ds200avg(:,2) == r),3);
index = find(outputzlin(:,2) > r-0.05*r);
outputzlin1 = outputzlin(index,:);
index= find(outputzlin1(:,2) < r+0.05*r);
outputzlin2 = outputzlin1(index,:);
pred =  mean(outputzlin2(:,3));
err_f(counter,:) = [r,abs(tputreal - pred)/nmax(tputreal,pred)];
outputzlin3(counter,:) = [200,r,pred] ;
end


outputzlin = outputzlin3;
index = find(~isnan(err_f(:,2)));
err = err_f(index,:);
%p = size(err_fn,1);
%listindex = cell(p,1);
%for i = 1:p
%listindex{i} = find(ds200(:,2) == err_fn(i,1));
%end

