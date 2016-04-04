function [] = plotker(M,bins,methodk,fontsize,labels)
%     INPUTS:
%             M:       n*p matrix representing n samples for p dimensions
%             bins:    scalar giving the number of bins for plotting the histogram
%             methodk: the method to use for kernel estimation: normal,box,triangle or epanechnikov
%             labels:  The names of the p dimensions
%     OUTPUT:
%             p figures representing the pdf based on kernel estimation confronted to histogram

%Store dimensions
n = size(M,1);
p = size(M,2);


%compute the kernel estimation of pdf
    pdfs = cell(1,p);
    for i = 1:p
        [f,xi] = ksdensity(M(:,i),'function','pdf','kernel',methodk);
        pdfs{i} = [xi;f];
    end
    
%Plot
for i = 1:p
    figure()
    if bins == 0
        iqrs = std(M(:,i));
        binw = iqrs*3.5*n^(-1/3);
        bins = ceil(range(M(:,i))/binw);
    end
    x = min(M(:,i)):range(M(:,i))/bins:max(M(:,i));
    hist(M(:,i),x)
    mi = max(hist(M(:,i),x));
    hold on
    plot(pdfs{i}(1,:),(pdfs{i}(2,:)/max(pdfs{i}(2,:)))*mi,'r','linewidth',2)
    if nargin == 5
       tx = strcat('Value for ',labels{i}); 
    else
        tx = strcat('Value of dimension ',num2str(i));
    end
    xlabel(tx,'FontSize',fontsize);
    ylabel('Histogram and PDF scaled to histogram max','fontsize',fontsize);
    t = strcat('Comparison of histogram using ',num2str(bins),'bins and kernel estimation using ',methodk);
    title(t,'fontsize',fontsize);
    set(gca,'fontsize',fontsize);
end