function [] = superpose2boxplots(ds,labels,dim,index1,index2,names,perc_remove)
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
%
%Output
%       plot

if nargin < 6
    error('Not enough inputs, see help')
end

if nargin > 7
    error('Too many inputs, see help')
end

if nargin == 6
    perc_remove = 0;
else
    if perc_remove >= 1 || perc_remove < 0
        error('Percentage must be a value in [0;1[')
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


s1 = size(X1,1);
s2 = size(X2,1);

group = [repmat({names{1}},s1,1);repmat({names{2}},s2,1)];
figure()
boxplot([X1;X2],group)
set(findobj(gca,'Type','text'),'FontSize',24)
set(gca,'fontsize',24)  
grid on
















