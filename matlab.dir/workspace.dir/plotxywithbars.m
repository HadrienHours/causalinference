function [] = plotxywithbars(listx,listy,listnsamples,methodinterp,labels)
%This function plots all the value of y as function of x adding a bar plot with the number of samples used for estimating y values
%It operates a interpolation in case of missing values
%inputs
%	listx: n*1 list coordinates
%	listy: n*p list of corresponding values
%	listnsamples: n*s number of samples per coordinate
%	axisxy: 1*4 of [minx,maxx,miny,maxy]
%	methointerp[optional]:  string defining the interpolation method (default: nearest neighbor)
%	labels = cell of labelx, labely,title,legends
%outputs
%	a plot

if nargin < 3
	error('Not enough inputs')
elseif nargin == 3
	methodinterp = 'nearest';
elseif nargin > 5
	error('Too many inputs')
end

nx1 = size(listx,1);
nx2 = size(listx,2);
if nx2 > nx1
   listx = listx'; 
end
ny1 = size(listy,1);
ny2 = size(listy,2);
if ny2 > ny1
   listy = listy'; 
end
ns1 = size(listy,1);
ns2 = size(listy,2);
if ns2 > ns1
   listnsamples = listnsamples'; 
end

nx = size(listx,1);
ny = size(listy,1);
ns = size(listnsamples,1);

if nx ~= ny || nx ~= ns
	error('The number of x and ys must be the same');
end

dy = size(listy,2);

listc = {[1 0 0],[0 1 0],[0 1 1],[1 0 1],[1 1 0],[1 1 1]};

figure()
I = find(listy(:,1) == 0);
listxt = listx;
listyt = listy(:,1);
listxt(I) = [];
listyt(I) = [];
h = @(t) interp1(listxt,listyt,t,methodinterp);
plot(listx,h(listx),'linewidth',4);
hold
if dy > 1
	for k=2:dy
        I = find(listy(:,k) == 0);
        listxt = listx;
        listyt = listy(:,k);
        listxt(I) = [];
        listyt(I) = [];
		h = @(t) interp1(listxt,listyt,t,methodinterp);
		idxc = max(1,mod(k-1,7));
		plot(listx,h(listx),'linewidth',4,'color',listc{idxc})
	end
end

scalelab = min(min(listy(listy~=0)))/max(listnsamples);

bar(listx,listnsamples*scalelab)
for i1=1:nx
    text(listx(i1),listnsamples(i1)*scalelab,num2str(listnsamples(i1),'%d'),'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',32,'fontweight','bold')
end
dx = (listx(2)-listx(1))/3;
m1 = max(listy(2,1),listy(1,1));
m2 = min(listy(2,1),listy(1,1));
dy = (m1-m2)*.1;
axis([min(listx)-dx,max(listx)+dx,0,max(max(listy))+dy]);
set(gca,'fontsize',32)
grid on

if nargin == 5
	xlabel(labels{1},'fontsize',32)
	ylabel(labels{2},'fontsize',32)
	title(labels{3},'fontsize',32,'fontweight','bold')
    if length(labels) > 3
        s = cell(1,length(labels)-3);
        for k = 1:length(labels)-3
            s{k} = labels{k+3};
        end
        legend(s)
    end
end

hold off