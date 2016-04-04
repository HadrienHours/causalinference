function [] = plotkercomparison(X,name_s)
%INPUTS     X: A vectore
%           names : {'name metric'}
%OUTPUT     Graph of comparison between the different kernel and the
%histograms obtained with scott rule or Freedman Diaconis rule

n = size(X,2);

%Scott rule
iqrs = std(X);
binw = iqrs*3.5*n^(-1/3);
bins = ceil(range(X)/binw);


%Freedman Diaconis
binwfd = 2*iqr(X)*n^(-1/3);
binfd = ceil(range(X)/binwfd);


labels = {'normal','triangle','box','epanechnikov'}
f = cell(1,4);
xi = cell(1,4);
pdfs = cell(1,4);

for i=1:4
    [f{i},xi{i}] = ksdensity(X,'function','pdf','kernel',labels{i});
    pdfs{i} = [xi{i};f{i}];
end

figure()
for i=1:4
    subplot(2,2,i)
    z = min(X):range(X)/bins:max(X);
    hist(X,z)
    mi = max(hist(X,z));
    hold on
    plot(pdfs{i}(1,:),(pdfs{i}(2,:)/max(pdfs{i}(2,:)))*mi,'r','linewidth',2)
    tx = strcat('values of ',name_s{1});
    xlabel(tx,'Fontsize',16);
    ylabel('Histogram and Density','Fontsize',16);
    tx = strcat('Comparison of Scott histo and density function for the  ',name_s{1},'  using  ',labels{i},' kernel');
    title(tx,'Fontsize',16)
    set(gca,'Fontsize',16)
end

figure()
for i=1:4
    subplot(2,2,i)
    z = min(X):range(X)/binfd:max(X);
    hist(X,z)
    mi = max(hist(X,z));
    hold on
    plot(pdfs{i}(1,:),(pdfs{i}(2,:)/max(pdfs{i}(2,:)))*mi,'r','linewidth',2)
    tx = strcat('values of ',name_s{1});
    xlabel(tx,'Fontsize',16);
    ylabel('Histogram and Density','Fontsize',16);
    tx = strcat('Comparison of Freedman Diaconis histo and density function for the  ',name_s{1},'  using  ',labels{i},' kernel');
    title(tx,'Fontsize',16)
    set(gca,'Fontsize',16)
end