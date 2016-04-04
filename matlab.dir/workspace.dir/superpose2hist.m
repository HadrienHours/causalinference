function [] = superpose2hist(ds,labels,dim,index1,index2,names,perc_remove,nbins1,nbins2)
%This function plots a two histograms for a given dimension of the given
%dataset
%
%Usage: superpose2hist(ds,labels,dim,index1,index2.perc_remove)
%
%Inputs
%       ds:     n*p matrix, representing the dataset
%       labels: cell containing the names of the parameters
%       dim:    dimension to be plotted
%       index1: list of indexes for first histogram
%       index2: list of indexes for the second histogram
%       names: cell of size 2 with label for each histogram
%       perc_remove[optional]:  percentage for removing outliers
%       nbins1 [optional]: number of bins dim1
%       nbins2 [optional]: number of bins dim2
%Output
%       plot

method = 1;

if nargin < 6
    error('Not enough inputs, see help')
end

if nargin > 9
    error('Too many inputs, see help')
end

if nargin == 6
    perc_remove = 0;
    nbins1 = 0;
    nbins2 = 0;
elseif nargin >= 7
    if perc_remove >= 1 || perc_remove < 0
        error('Percentage must be a value in [0;1[')
    end
    if nargin == 7
        nbins1 = 0;
        nbins2 = 0;
    elseif nargin == 8
        nbins2 = 0;
    end
end

if size(names,2) > 2
    error('There must be only two names in the labels');
end

X1 = ds(index1,dim);
X2 = ds(index2,dim);

if perc_remove > 0
    X1 = remove_extremes(X1,perc_remove);
    X2 = remove_extremes(X2,perc_remove);
end

h1 = 2.5*iqr(X1)/(size(X1,1)^(1/3));
h2 = 2.5*iqr(X2)/(size(X2,1)^(1/3));

if nbins1 ~= 0
    nb1 = nbins1;
else
    if h1 ~= 0
        nb1 = ceil(range(X1)/h1);
    else
        nb1 = 0;
    end
end

if nbins2 ~= 0
    nb2 = nbins2;
else
    if h2 ~= 0
        nb2 = ceil(range(X2)/h2);
    else
        nb2 = 0;
    end
end

if nb1 ~= 0
    [H1,E1] = hist(X1,nb1);
else
    [H1,E1] = hist(X1);
end

if nb2 ~= 0
    [H2,E2] = hist(X2,nb2);
else
    [H2,E2] = hist(X2);
end

if method == 1
    figure()
    bar(E1,H1/sum(H1));
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','none')
    set(h,'linewidth',2)
    set(h,'EdgeColor','b')
    hold on
    bar(E2,H2/sum(H2));
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','none')
    set(h,'linewidth',2,'linestyle','--')
    set(gca,'fontsize',24)
    % xlabel(labels{dim},'fontsize',24)
    legend(names{1},names{2})
    grid on
else
    figure()
    if nb1 ~= 0
        hist(X1,nb1);
    else
        hist(X1);
    end
    h = findobj(gca,'Type','patch');
    set(h,'Facecolor','b','EdgeColor','k','facealpha',0.75)
    hold on
    if nb2 ~= 0
        hist(X2,nb2);
    else
        hist(X2);
    end
    h = findobj(gca,'Type','patch');
    set(h(1),'Facecolor','r','facealpha',0.75)
    legend(names{1},names{2})
    grid on
end    
