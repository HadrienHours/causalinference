function [H,E] = plot2histsuperpose(ds,Index1,Index2,dimy,labels,percclean)
%This function plot the superposition of two histograms
%   The number of bins is computed based on Freedman?Diaconis
%   binwidth = (2*IQR(X))/(n^(1/3))
%
%Input
%       ds = N*p dataset
%       Index1 = indexes of the first subset
%       Index2 = indexes of the second subset
%       dimy = the dimensions to plot
%       labels [optional] = names for the two subset
%       percclean [optional] = percentage for remove out of inter
%       percentile samples (removing outliers)
%Output
%       H: 2*1 cell containing the two bar plot values (unnormalized)
%       E: 2*1 cell containing the positions of the bars

if nargin < 4 || nargin > 6
    error('Wrong number of parameters, see help')
end

if nargin == 4 || size(labels,2) ~= 2
    labels = {'Dataset 1','Dataset 2'};
end

if nargin == 5
    percclean = 0;
end


%subset
Y1 = ds(Index1,dimy);
Y2 = ds(Index2,dimy);

%Freedman-diaconis rule
h1 = 2*iqr(Y1)/(length(Y1)^(1/3));
h2 = 2*iqr(Y2)/(length(Y2)^(1/3));

%number of bins
n1 = ceil(range(Y1)/h1);
n2 = ceil(range(Y2)/h2);

%fprintf('Number of bins for %s: %d\n',labels{1},n1)
%fprintf('Number of bins for %s: %d\n',labels{2},n2)

%histogram
if ~isinf(n1) && n1 ~= 0
    [H1,E1] = hist(Y1,n1);
else
    [H1,E1] = hist(Y1);
end

if ~isinf(n2) && n2 ~= 0
    [H2,E2] = hist(Y2,n2);
else
    [H2,E2] = hist(Y2);
end

%figure
figure()
bar(E1,H1/sum(H1));
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','facealpha',0.5);
hold on
bar(E2,H2/sum(H2))
h = findobj(gca,'Type','patch');
set(h,'facealpha',0.5);
set(gca,'fontsize',24)
grid on
legend(labels)

H = cell(2,1);
E = cell(2,1);
H{1} = H1;
H{2} = H2;
E{1} = E1;
E{2} = E2;

%boxplots
s1 = size(Index1,1);
s2 = size(Index2,1);

group = [repmat({labels{1}},s1,1);repmat({labels{2}},s2,1)];

figure()
boxplot([Y1;Y2],group)
set(findobj(gca,'Type','text'),'FontSize',18)

%clean data

if percclean > 0
    %subset
    Y1c = remove_extremes(Y1,percclean);
    Y2c = remove_extremes(Y2,percclean);

    %Freedman-diaconis rule
    h1c = 2*iqr(Y1c)/(length(Y1c)^(1/3));
    h2c = 2*iqr(Y2c)/(length(Y2c)^(1/3));

    %number of bins
    n1c = ceil(range(Y1c)/h1c);
    n2c = ceil(range(Y2c)/h2c);

    %histogram
    if ~isinf(n1c) && n1c ~= 0
        [H1c,E1c] = hist(Y1c,n1c);
    else
        [H1c,E1c] = hist(Y1c);
    end

    if ~isinf(n2c) && n2c ~= 0
        [H2c,E2c] = hist(Y2c,n2c);
    else
        [H2c,E2c] = hist(Y2c);
    end

    %figure
    figure()
    bar(E1c,H1c/sum(H1c));
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','b','facealpha',0.5);
    hold on
    bar(E2c,H2c/sum(H2c))
    h = findobj(gca,'Type','patch');
    set(h,'facealpha',0.5);
    set(gca,'fontsize',24)
    grid on
    legend(labels)

    %boxplots
    s1c = size(Y1c,1);
    s2c = size(Y2c,1);
    
    group = [repmat({labels{1}},s1c,1);repmat({labels{2}},s2c,1)];
    figure()
    boxplot([Y1c;Y2c],group)
    set(findobj(gca,'Type','text'),'FontSize',18)
end

end