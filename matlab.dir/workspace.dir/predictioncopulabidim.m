function [pdf,cpdf,eb,ea,X,Y] = predictioncopulabidim(pathds,minx,maxx,dim1,dim2,N,methodk)
%   This function use T copula and normal kernel to compute bidemensional
%   pdf and conditional pdf to compute the effect of an intervention on x with
%   no back door where we set x to an interval [minxx,maxx]
%
%Usage
%   [ea,eb,pdf,pdfc,Xp,Yp] = computebidimensionalpdfcopula(pathds,minx,maxx,dim1,dim2,N,methodk)
%input
%       full path of csvfile (with header)
%       minx : lower value defining interval
%       maxx : upper value defining interval
%       dim1 : dimension of x
%       dim2 : dimension of y 
%       N : number of points for estimation 
%       methodk: methodkernel (normal,box,triangle,epanechniokv)
%output
%       pdf: bidemensional pdf
%       cpdf: bidemensional conditional pdf
%       eb : value before
%       ea : expected value after intervention
%       x: x values
%       y: y values

if nargin < 5
    error('Not enough arguments, see help')
elseif nargin == 5
    N = 1000;
    methodk = 'normal';
elseif nargin == 6
    methodk = 'normal';
else
    error('Wrong number of arguments, see help');
end

%load data
%ds = csvread('dataset_nomss_nodist_cleaned.csv',1,0);
ds = csvread(pathds,1,0);
x1 = ds(:,dim1);
x2 = ds(:,dim2);

%pars definition
flag_icdf= 0;
flag_cdf1 = 0;
flag_cdf2 = 0;
flag_marginal = 1;

%compute cdf estimated at N equidistant points
[cdf_x1,x_x1] = ksdensity(x1,x1,'kernel',methodk,'function','cdf');
[cdf_x2,x_x2] = ksdensity(x2,x2,'kernel',methodk,'function','cdf');
cdf_x1 = max(cdf_x1,eps);%no 0 allowed
cdf_x2 = max(cdf_x2,eps);%no 0 allowed
if flag_cdf1 == 1
    figure()
    plot(x_x1,cdf_x1,'linestyle','none','Marker','+')
    xlabel('X','Fontsize',18)
    ylabel('CDF ','Fontsize',18)
    title('CDF X samples','Fontsize',18,'Fontweight','bold')
    set(gca,'fontsize',16)
    figure()
    plot(x_x2,cdf_x2)
    xlabel('Y','Fontsize',18)
    ylabel('CDF Y','Fontsize',18)
    title('CDF Y samples','Fontsize',18,'Fontweight','bold')
    set(gca,'fontsize',16)
end


%estimate copula
[rho,nu] = copulafit('t',[cdf_x1,cdf_x2]);

%generate estimation points
xlin = linspace(min(x1),max(x1),N);
ylin = linspace(min(x2),max(x2),N);
[Xl1,Yl1] = meshgrid(xlin,ylin);
xlin2 = ksdensity(x1,xlin,'function','cdf');
ylin2 = ksdensity(x2,ylin,'function','cdf');
[Xl2,Yl2] = meshgrid(xlin2,ylin2);
if flag_cdf2 == 1
    figure()
    plot(xlin,ylin,'linestyle','none','Marker','+')
    xlabel('X','Fontsize',18)
    ylabel('CDF X','Fontsize',18)
    title('CDF X equidistant','Fontsize',18,'Fontweight','bold')
    set(gca,'fontsize',16)
    figure()
    plot(ylin,ylin2)
    xlabel('Y','Fontsize',18)
    ylabel('CDF Y','Fontsize',18)
    title('CDF Y equidistant','Fontsize',18,'Fontweight','bold')
    set(gca,'fontsize',16)
end

%compute the inverse cdf functions
[icdf_x1,x_icdf_x1] = ksdensity(x1,'kernel',methodk,'npoints',N,'function','icdf');
I = find(~isnan(icdf_x1));
Xx1 = [0,max(x_icdf_x1(I),0),1];
Yx1 = [0,max(icdf_x1(I),0),max(x1)];
hx1 = @(x) interp1(Xx1,Yx1,x);%take as input [0,1] value and return corresponding RTT which cdf corresponds to this value
[icdf_x2,x_icdf_x2] = ksdensity(x2,'kernel',methodk,'npoints',N,'function','icdf');
I = find(~isnan(icdf_x2));
Xx2 = [0,max(x_icdf_x2(I),0),1];
Yx2 = [0,max(icdf_x2(I),0),max(max(icdf_x2(I))+eps,max(x2))];
hx2 = @(x) interp1(Xx2,Yx2,x);

%compute their derivative
L = linspace(0,1,N*N);
dhx1  = @(x) interp1(L(1:end-1),diff(hx1(L)),x);
dhx2 = @(x) interp1(L(1:end-1),diff(hx2(L)),x);

%plot icdf
if flag_icdf == 1
figure()
plot(linspace(0,1,N),hx1(linspace(0,1,N)),'linewidth',2)
hold
plot(x_icdf_x1,icdf_x1,'r','linestyle','None','Marker','v')
plot(L(1:end-1),dhx1(L(1:end-1)),'g','linewidth',2)
grid on
xlabel('CDF of X','Fontsize',18)
ylabel('Corresponding X values','Fontsize',18)
title('ICDF of X interpolation and its derivative','Fontsize',18,'Fontweight','bold')
legend('Interpolation ICDF','ICDF Points','Interpolation ICDF derivative','Location','NorthWest')
set(gca,'fontsize',16)
figure()
plot(linspace(0,1,N),hx2(linspace(0,1,N)),'linewidth',2)
hold
plot(x_icdf_x2,icdf_x2,'r','linestyle','None','Marker','v')
plot(L(1:end-1),dhx2(L(1:end-1)),'g','linewidth',2)
grid on
xlabel('CDF of Y','Fontsize',18)
ylabel('Corresponding Y values','Fontsize',18)
title('ICDF of Y interpolation and its derivative','Fontsize',18,'Fontweight','bold')
legend('Interpolation ICDF','ICDF Points','Interpolation ICDF derivative','Location','NorthWest')
set(gca,'fontsize',16)
end


%estimate copula at estimation points
dx = xlin(2)-xlin(1);
dy = ylin(2)-ylin(1);
dFx = dhx1(Xl2(:));
dFy = dhx2(Yl2(:));
Fl = copulapdf('t',[Xl2(:) Yl2(:)],rho,nu);
Fln = Fl./(abs(dFx).*abs(dFy));
F = reshape(Fln,N,N);
X = reshape(Xl2(:),N,N);
Y = reshape(Yl2(:),N,N);

Sxy =sum(sum(F))*dx*dy;
F=F/Sxy;

dx2 = diff(Xl2(:));
dx2 = [dx2;dx2(end)];
dy2 = diff(Yl2(:));
dy2 = [dy2;dy2(end)];
fprintf('Integral of fuv is %f \n',sum(Fl.*dx2.*dy2));

fprintf('The integral of pdf_xy on X and Y is %f\n',Sxy);

%plot copula on invert CDF values of point where it was evaluated
%(F-1(F(X)=X)
figure()
surf(hx1(X),hx2(Y),F)
xlabel('X','Fontsize',18);
ylabel('Y','Fontsize',18);
zlabel('PDF(X,Y)','Fontsize',18);
title('PDF of X,Y with normal kernel and T copula','Fontsize',18,'Fontweight','bold')
set(gca,'Fontsize',16);

%compute cpdf
Fx1 = sum(F,1)*dy/(sum(sum(F,1)*dy)*dx);%X varies on dimension 2 (>) while Y varies on dimension 1 (v)
Sr = repmat(Fx1,size(F,1),1);
FC = F./Sr;%We compute F_{Y/X} = F_{X,Y} / F_{X} = F_{X,Y}/(sum_{Y}(F_{X,Y})*dy)
if flag_marginal == 1
    fprintf('Sizeof pdf X is %d, %d\n',size(Fx1));
    fprintf('Once reformatted to fit conditional one, size is %d, %d\n',size(Sr));
    figure()
    plot(Xl1(1,:),Fx1,'linewidth',2)
    xlabel('X','fontsize',18)
    ylabel('fx','fontsize',18)
    title('Marginalization of Y to obtain pdf of X from bivariate','fontsize',18,'fontweight','bold')
    set(gca,'fontsize',16)
end

figure()
surf(Xl1,Yl1,FC)
xlabel('X','Fontsize',18);
ylabel('Y','Fontsize',18);
zlabel('CPDF(Y/X)','Fontsize',18);
title('Estimation of bidimensional conditional pdf of Y cond X normal kernel, T copula','Fontsize',18,'Fontweight','bold')
set(gca,'Fontsize',16);

%Compute Fy integrating on X
Fx2 = sum(F,2)*dx / (sum(sum(F))*dx*dy);%normalization, Ftput N*1
if flag_marginal == 1
    fprintf('Size Pdf Y is %d, %d\n',size(Fx2));
    figure()
    plot(Yl1(:,1),Fx2,'linewidth',2)
    xlabel('Y','fontsize',18)
    ylabel('fy','fontsize',18)
    title('Marginalization of X to obtain pdf of Y from bivariate','fontsize',18,'fontweight','bold')
    set(gca,'fontsize',16)
end

%Compute exepcted Y value before intervention
eb = sum(Yl1(:,1).*Fx2*dy);

%Compute expected Y value after intervention
I = find(xlin>=minx & xlin <= maxx);%give all the columns where x in intervall [minx,maxx]
FCx = (sum(FC(:,I),2)*dx)/(sum((sum(FC(:,I),2)*dx)*dy));%sum Pr(Y=y/x \in Dx) = 1
ea = sum(Yl1(:,1).*FCx*dy);

%return values
pdf = F;
cpdf = FC;
X = Xl1;
Y = Yl1;
