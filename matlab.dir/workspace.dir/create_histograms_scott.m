function [] = create_histograms_scott(ds,labels,perc)
% This function plot the histogram of each dimension of the input dataset
% using a number of samples given by the bin width of Scott rule
% INPUTS
%       ds: n*p matrix representing the n samples of p parameters
%       OPTIONAL
%       labels: cell containing the names of each parameter
%       prc: if > 0 remove values out of the IQR for percentile prc

n = size(ds,1);
p = size(ds,2);

if nargin == 3
    flag_label = 1;
    flag_iqr = 1;
    if perc < 0.0 || perc > 1.0
        error('Percentile value must be between 0.0 and 1.0')
    end
elseif nargin == 2
    if size(labels,2) == 1
        flag_iqr = 1;
        perc = labels;
        flag_label = 0;
    else
        flag_iqr = 0;
        flag_label = 1;
    end
elseif nargin == 1
    flag_iqr = 0;
    flag_label = 0;
end

nbl = ceil(p/3);
figure()
for i = 1:p
    X = ds(:,i);
    %Remove the 5% min and 5% max
    if flag_iqr
        x1 = quantile(X,perc);
        x2 = quantile(X,(1-perc));
        I = find(X>=x1 & X<= x2);
        X = X(I);
    end
    h = 3.5*std(X)/(n^(1/3));
    ex = max(X) - min(X);
    nb = ceil(ex/h);
    subplot(nbl,3,i)
    hist(X,nb)
    if flag_label
        title(labels{i})
    end
end