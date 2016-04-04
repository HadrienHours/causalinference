function [] = create_probabilities(M,flag)
%compute dynamically a discretization of the M matrix for each dimension
%using histogram and the scott rules h = 3.5*sigma*n^(-1/3)
% changing sigma by Inter Quantile Range (Freedman?Diaconi) less sensible
% to outliers
% INPUT
%       n*p matrix : n samples of p dimensions
%       flag       : remove values out of IQR

%sizes of the input matrix
n = size(M,1);
p = size(M,2);

%matrix to store Inter Quantile Range, Bin width and bins boundaries for
%each dimension
iqrs = zeros(1,p);
binw = zeros(1,p);
h = zeros(1,p);

if(flag == 1)
    fprintf('Entering the filtering phase\n');
    N = cell(p,1);
    %removing the ouliers by taking only the datas in the IQR
        %getting the 25 percentiles
    tmp25 = prctile(M,25);
        %getting the 75 percentiles
    tmp50 = prctile(M,75);
    prctiles = zeros(size(M,2),2);
    for i=1:size(M,2)
        prctiles(i,1) = tmp25(i);
        prctiles(i,2) = tmp50(i);
    end
    t1 = zeros(size(M));
    t2 = zeros(size(M));
    for i=1:size(M,2)
        t1 = M(:,i) > prctiles(i,1);
        t2 = M(:,i) > prctiles(i,2);
        t3 = logical(t1.*t2);
        N{i} = M(t3,i);
    end
    
end




%computation of the IQR, binwidth, and number of bins
if(flag == 0)
    for i=1:p
%         iqrs(i) = iqr(M(:,i));
        iqrs(i) = std(M(:,i));
        binw(i) = iqrs(i)*3.5*n^(-1/3);
        h(i) = ceil(range(M(:,i))/binw(i));
    end
else
    for i=1:p
        iqrs(i) = iqr(N{i}');
        binw(i) = iqrs(i)*3.5*size(N{i},1)^(-1/3);
        fprintf('The number of bins for the dimension %d is %d / %d \n',i,range(N{i}),binw(i));
        h(i) = ceil(range(N{i})/binw(i));
    end   
end


%building of the bins boundaries / edges
edges = cell(1,p);
xis = cell(1,p);
if (flag == 0)
    for i=1:p
        k = min(M(:,i));
        for j=1:h(i)
            k=k+binw(i);
            xis{i} = [xis{i},k-binw(i)/2];
            edges{i}=[edges{i},k];
        end
%         xis{i} = [xis{i},k+binw(i)/2];
    end
else
    for i=1:p
        k = min(N{i});
        for j=1:h(i)
            k=k+binw(i);
            xis{i} = [xis{i},k-binw(i)/2];
            edges{i}=[edges{i},k];
        end
%         xis{i} = [xis{i},k+binw(i)/2];
    end
end


histos = cell(1,p);
%computation of the cdfs
if (flag == 0)
    
    for i=1:p
        histos{i} = histc(M(:,i),edges{i});
    end
else
    for i=1:p
        edges{i};
        histos{i} = histc(N{i},edges{i});
    end 
end


linef=ceil(p/3);

if(flag == 0)
    figure()
    uicontrol('Style','text','String','No Filtering','Position',[10  400 100 25],'BackgroundColor',get(gcf,'Color'));
else
    figure()
    uicontrol('Style','text','String','Filtering the value in the IQR','Position',[10  400 120 35],'BackgroundColor',get(gcf,'Color'));
end

for i=1:p
   subplot(linef,3,i);
   bar(xis{i},histos{i}'/sum(histos{i}),'Barwidth',1); 
   xlabel('values');
   ylabel('frequency');
end
for i=1:p
    if(flag == 0)
        fprintf('\nFor dimension %d:\nBin width: \t%d\nRange: \t%d\nNumber of bins: \t%d\n\n',i,binw(i),range(M(:,i)),h(i));
    else
        fprintf('For dimension %d:\nBin width: \t%d\nRange: \t%d\nNumber of bins: \t%d\n\n',i,binw(i),range(N{i}),h(i));
    end
end
