function [rlin,rcub, rv4, rnr,errlin,errcub,errv4,errnr] = predict4(dataset,dim,val,delta,N,labs,realds,limex)
% INPUTS:
%             dataset: n*p matrix where the last column is the one to predict
%             dim: the dimension on which we gonna set the value for
%             prediction (here only 1 or 2 as working with 3 dimensions)
%             val: the value set on the dim for prediction
%             delta: define the width of the interval around val for filtering the dataset
%             limex: 2*p
%             realdsx: real dataset value on x
%             realdsy: real dataset value on y (predicted value)
%
% OUTPUTS:
%             rX: w*(p-1) matrix, the predicted values function of the remaining dimensions
 
p=size(dataset,2);
n=size(dataset,1);

if nargin < 6
    ferror('Not enough arguments\n')
end

if nargin == 6
    limex = zeros(p,2)
    for i=1:p
        limex(i,:) = [min(dataset(:,i)),max(dataset(:,i))];
    end
end


[X,Y,Zlin,Zcub,Zv4,Znr,Zlinflatten,Zcubflatten,Zv4flatten,Znrflatten] = extrapolatelim(dataset,N,labs,limex);
lim1 = val - delta;
lim2 = val + delta;

if(dim == 1)
    points = find(X>=lim1);
    X1 = X(points);
    Y1 = Y(points);
    Zlin1 = Zlin(points);
    Zcub1 = Zcub(points);
    Zv41 = Zv4(points);
    Znr1 = Znr(points);
    points = find(X1<=lim2);
    X2 = X1(points);
    Y2 = Y1(points);
    [Y2,I] = sort(Y2);
    Zlin2 = Zlin1(points);
    Zlin2 = Zlin2(I);
    Zcub2 = Zcub1(points);
    Zcub2 = Zcub2(I);
    Zv42 = Zv41(points);
    Zv42 = Zv42(I);
    Znr2 = Znr1(points);
    Znr2 = Znr2(I);
    rlin = [Y2,Zlin2];
    rcub = [Y2,Zcub2];
    rv4 = [Y2,Zv42];
    rnr = [Y2,Znr2];
end

if(dim == 2)
    points = find(Y>=lim1);
    X1 = X(points);
    Y1 = Y(points);
    Zlin1 = Zlin(points);
    Zcub1 = Zcub(points);
    Zv41 = Zv4(points);
    Znr1 = Znr(points);
    points = find(Y1<=lim2);
    X2 = X1(points);
    Y2 = Y1(points);
    [X2,I] = sort(X2);
    Zlin2 = Zlin1(points);
    Zlin2 = Zlin2(I);
    Zcub2 = Zcub1(points);
    Zcub2 = Zcub2(I);
    Zv42 = Zv41(points);
    Zv42 = Zv42(I);
    Znr2 = Znr1(points);
    Znr2 = Znr2(I);
    rlin = [X2,Zlin2];
    rcub = [X2,Zcub2];
    rv4 = [X2,Zv42];
    rnr = [X2,Znr2];
end


listc=['g','r','m','c','y'];

figure()
plot(rlin(:,1),rlin(:,2))
hold
for i=1:5
    plot(rlin(:,1),sliding_window(rlin(:,2),i*5),listc(i),'linewidth',2)
end

if ~isempty(realds)
    plot(realds(:,1),realds(:,2),'k','linewidth',3)
    %intrapolation on the measured dataset for comparison
    rds_y=interp1(realds(:,1),realds(:,2),rlin(:,1),'linear');
    errlind = abs(sliding_window(rlin(:,2),20)./rds_y)*100;
    errlin = abs(sliding_window(rlin(:,2),20)-rds_y);
    plot(rlin(:,1),errlin,'--r','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',10)
    text(rlin(N,1),errlin(N),num2str(mean(errlin)),'HorizontalAlignment','left','VerticalAlignment','bottom','Fontsize',20);
    text(rlin(2*N,1),errlin(2*N),num2str(mean(errlind)),'HorizontalAlignment','left','VerticalAlignment','bottom','Fontsize',20);
else
    errlin = 0;
end

xlabel('Size','Fontsize',20);
ylabel('LoadTime','Fontsize',20);
t = strcat('Comparison linear extrapolation and measure value of LoadTime depending on Size for delay = ',num2str(val),' ms');
title(t,'Fontsize',20,'Fontweight','bold');
if ~isempty(realds)
    legend('Original extrapolation','window 5','window 10','window 15','window 20','window 25','measured loadtime','Error','location','EastOutside');
else
    legend('Original extrapolation','window 5','window 10','window 15','window 20','window 25','location','EastOutside');
end
set(gca,'Fontsize',20);


figure()
plot(rcub(:,1),rcub(:,2))
hold
for i=1:5
    plot(rcub(:,1),sliding_window(rcub(:,2),i*5),listc(i),'linewidth',2)
end
if ~isempty(realds)
    plot(realds(:,1),realds(:,2),'k','linewidth',3)
    %intrapolation on the measured dataset for comparison
    rds_y=interp1(realds(:,1),realds(:,2),rcub(:,1),'cubic');
    errcubd = abs(sliding_window(rcub(:,2),20)./rds_y)*100;
    errcub = abs(sliding_window(rcub(:,2),20)-rds_y);
    plot(rcub(:,1),errcub,'--r','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',10)
    text(rcub(N,1),errcub(N),num2str(mean(errcub)),'HorizontalAlignment','left','VerticalAlignment','bottom','Fontsize',20);
    text(rcub(2*N,1),errcub(2*N),num2str(mean(errcubd)),'HorizontalAlignment','left','VerticalAlignment','bottom','Fontsize',20);
else
    errcub = 0;
end
xlabel('Size','Fontsize',20);
ylabel('LoadTime','Fontsize',20);
t = strcat('Comparison cubic extrapolation and measure value of LoadTime depending on Size for delay = ',num2str(val),' ms');
title(t,'Fontsize',20,'Fontweight','bold');
if ~isempty(realds)
    legend('Original extrapolation','window 5','window 10','window 15','window 20','window 25','measured loadtime','Error','location','EastOutside');
else
    legend('Original extrapolation','window 5','window 10','window 15','window 20','window 25','location','EastOutside');
end
set(gca,'Fontsize',20);


figure()
plot(rnr(:,1),rnr(:,2))
hold
for i=1:5
    plot(rnr(:,1),sliding_window(rnr(:,2),i*5),listc(i),'linewidth',2)
end
if ~isempty(realds)
    plot(realds(:,1),realds(:,2),'k','linewidth',3)
    %intrapolation on the measured dataset for comparison
    rds_y=interp1(realds(:,1),realds(:,2),rnr(:,1),'nearest');
    errnrd = abs(sliding_window(rnr(:,2),20)./rds_y)*100;
    errnr = abs(sliding_window(rnr(:,2),20)-rds_y);
    plot(rnr(:,1),errnr,'--r','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',10)
    text(rnr(N,1),errnr(N),num2str(mean(errnr)),'HorizontalAlignment','left','VerticalAlignment','bottom','Fontsize',20);
    text(rnr(2*N,1),errnr(2*N),num2str(mean(errnrd)),'HorizontalAlignment','left','VerticalAlignment','bottom','Fontsize',20);
else
    errnr = 0;
end
xlabel('Size','Fontsize',20);
ylabel('LoadTime','Fontsize',20);
t = strcat('Comparison NN extrapolation and measure value of LoadTime depending on Size for delay = ',num2str(val),' ms');
title(t,'Fontsize',20,'Fontweight','bold');
if ~isempty(realds)
    legend('Original extrapolation','window 5','window 10','window 15','window 20','window 25','measured loadtime','Error','location','EastOutside');
else
    legend('Original extrapolation','window 5','window 10','window 15','window 20','window 25','location','EastOutside');
end
set(gca,'Fontsize',20);


figure()
plot(rv4(:,1),rv4(:,2))
hold
for i=1:5
    plot(rv4(:,1),sliding_window(rv4(:,2),i*5),listc(i),'linewidth',2)
end
if ~isempty(realds)
    plot(realds(:,1),realds(:,2),'k','linewidth',3)
    %intrapolation on the measured dataset for comparison
    rds_y=interp1(realds(:,1),realds(:,2),rv4(:,1),'v5cubic');
    errv4d = abs(sliding_window(rv4(:,2),20)./rds_y)*100;
    errv4 = abs(sliding_window(rv4(:,2),20)-rds_y);
    plot(rv4(:,1),errv4,'--r','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',10)
    text(rv4(N,1),errv4(N),num2str(mean(errv4)),'HorizontalAlignment','left','VerticalAlignment','bottom','Fontsize',20);
    text(rv4(2*N,1),errv4(2*N),num2str(mean(errv4d)),'HorizontalAlignment','left','VerticalAlignment','bottom','Fontsize',20);
else
    errv4 = 0;
end
xlabel('Size','Fontsize',20);
ylabel('LoadTime','Fontsize',20);
t = strcat('Comparison MV4 extrapolation and measure value of LoadTime depending on Size for delay = ',num2str(val),' ms');
title(t,'Fontsize',20,'Fontweight','bold');
if ~isempty(realds)
    legend('Original extrapolation','window 5','window 10','window 15','window 20','window 25','measured loadtime','Error','location','EastOutside');
else
    legend('Original extrapolation','window 5','window 10','window 15','window 20','window 25','location','EastOutside');
end
set(gca,'Fontsize',20);