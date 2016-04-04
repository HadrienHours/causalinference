function [dsc,dsq,centroids,kopt,bopt,dopt,erroropt,params,err_l,objval,rval] = parameterization_intervds(ds,listk,listb,listd,dimtest,valuetest,dimobj,dimblock,dsintervention,rintervention)
%This function is finiding the correct parameterization for a given ds, for
%finding the number of cluster, it computed the sum of distances from
%points to centroids, for number of bins and similarity threshold it
%applies the backdoor effect to predict a value present in the dataset with
%minimum of error
%INPUTS
%           ds = n*p n observations of p parameters
%           listk = list of cluster size to test
%           listb = list of bins size to test
%           listd = list of similarity thr to test
%           dimtest = dimension of the value to set to test
%           valtest = value to set
%           dimobj = dimension of value to predict
%           dimblock = list of dimension for the blocking set
%           dsintervention = value or dataset corresponding to the real
%           value(s) under intervention 
%OUTPUT
%           dsc: k*p+1 matrix: k centroids and their probabilities
%           dsq: k*p+1 matrix: k quantized centroids and their
%           probabilities
%           centroids : k*p centroids
%           kopt:       optimal number of cluster
%           bopt        optimal number of samples per bin
%           dopt        optimal similarity threshold
%           erroropt    error for optimal setting
%           params      list parameters tested
%           err_l       list errors obtained
%           objval      The real value retained for testing


if nargin < 9
    error('Not enough arguments. See help');
elseif nargin == 9
    objval = mean(dsintervention(:,dimobj));
    rval = range(ds(:,dimobj));
else
    objval = dsintervention;
    rval = rintervention;
end
    

n = size(ds,1);
p = size(ds,2);

index = cell(1,size(listk,2));
centroids = cell(1,size(listk,2));
sumd = cell(1,size(listk,2));
Y=zeros(size(listk,1),1);
counter = 0;
for nk = listk
    fprintf('Trying k means with k = %d\n',nk)
    counter=counter+1;
    flag = 0;
    while flag == 0
        try
            flag=1;
            [index{counter},centroids{counter},sumd{counter}] = kmeans(ds,nk);
        catch
            flag=0;
        end
    end
    Y(counter) = sum(sumd{counter});
    fprintf('K means with %d cluster succeeded\n',nk);
end

figure()
X = listk;
bar(X,Y')
Ylabel = Y;
for i=1:2:size(Y,1)
    Ylabel(i) = 3*min(Y);
end
axis([min(X)-5,max(X)+5,min(Y)/2,max(Y)]);
text(X,Ylabel',num2str(Y','%.2g'),'HorizontalAlignment','center','VerticalAlignment','bottom','Color',[1 0 0],'Fontsize',16)
set(gca,'Fontsize',16)                                                                                  
xlabel('Number of clusters','Fontsize',16)
ylabel('sum of distances','Fontsize',16)
title('Sample distance to centroids as function of the number of clusters','Fontsize',16,'Fontweight','bold')
grid on

kopt = input('Enter the chosen value for the number of clusters:  ');
iopt = find(listk == kopt);
% centroids = centroids{iopt};

clusters = cell(1,kopt);

for i = 1:kopt
    clusters{i} = ds(find(index{iopt}==i),:);
end

dsp = zeros(kopt,p+1);
dsp(:,1:p) = centroids{iopt};

for i = 1:kopt
    dsp(i,p+1) = size(clusters{i},1)/n;
end

% I = find(ds(:,dimtest) <= valuetest_r & ds(:,dimtest) >= valuetest_l);
% yrange = range(ds(I,dimobj));
% yobj = mean(ds(I,dimobj));

x = [dimtest, valuetest];
[dsc,dsq,params,yval,ymean,err_l,size_l] = test_backdoor_fixed_centroid(ds,dsp,listd,listb, x,dimobj,dimblock,objval,rval);

u = unique(params(:,3));
param_error_p = cell(1,size(u,1));

for i = 1:size(u,1)
    I = find(params(:,3) == u(i));
    param_error_p{i} = [params(I,1),err_l(I,1)];
end

figure()
leg=cell(1,size(u,1));
plot(param_error_p{1}(:,1),1./param_error_p{1}(:,2),'linewidth',2)
leg{1} = strcat('bin = ',num2str(u(1)));
hold
for i = 2:size(u,1)
    plot(param_error_p{i}(:,1),1./param_error_p{i}(:,2),'color',[rand, rand, rand],'linewidth',2)
    leg{i} = strcat('bin = ',num2str(u(i)));
end
xlabel('Similarity threshold','Fontsize',32);
ylabel('Inverse of the error','Fontsize',32);
title('Error evolution function of bin size and similariy threshold','Fontsize',32);
legend(leg)
set(gca,'fontsize',32)


[erroropt,i] = min(err_l);
bopt = params(i,3);
dopt = params(i,1);