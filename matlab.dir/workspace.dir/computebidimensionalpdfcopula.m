function [ea,eb,pdf,pdfc,Xp,Yp] = computebidimensionalpdfcopula(pathds,N,minx,maxx,dim1,dim2)
%   This function use T copula and normal kernel to compute bidemensional
%   pdf and conditional pdf to compute the effect of an intervention on x with
%   no back door where we set x to an interval [minxx,maxx]
%
%Usage
%   [ea,eb,pdf,pdfc,Xp,Yp] = computebidimensionalpdfcopula(pathds,N,minx,maxx,dim1,dim2)
%input
%       full path of csvfile (with header)
%       N : number of points for estimation
%       minx : lower value defining interval
%       maxx : upper value defining interval
%       dim1 : dimension of x
%       dim2 : dimension of y
%output
%       ea : expected value after intervention
%       eb : value before
%       pdf: bidemensional pdf
%       pdfc: bidemensional conditional pdf
%       x: x values
%       y: y values
%load data
%ds = csvread('dataset_nomss_nodist_cleaned.csv',1,0);

if nargin < 4
    error('Not enough arguments, see help')
elseif nargin == 4
    dim1 = 4;
    dim2 = 13;
else
    error('Wrong number of arguments, see help');
end

ds = csvread(pathds,1,0);
rtt = ds(:,dim1);%4
tput = ds(:,dim2);%13
figure()
plot(rtt,tput,'linestyle','None','Marker','+');
grid on
xlabel('RTT(s)','fontsize',18)
ylabel('Tput(bps)','fontsize',18)
title('Initial Samples','Fontsize',18,'fontweight','bold')
set(gca,'fontsize',16)
%compute cdf
[cdf_rtt,x_rtt] = ksdensity(rtt,'npoints',N,'function','cdf');
figure()
plot(x_rtt,cdf_rtt)
xlabel('RTT(s)','Fontsize',18);
ylabel('CDF','Fontsize',18);
title('Cdf rtt','Fontsize',18);
set(gca,'Fontsize',16,'fontweight','bold');
[cdf_tput,x_tput] = ksdensity(tput,'npoints',N,'function','cdf');
figure()
plot(x_tput,cdf_tput)
xlabel('Tput(bps)','Fontsize',18)
ylabel('CDF(tput)','Fontsize',18)
title('Cdf tput','fontsize',18,'fontweight','bold');
set(gca,'fontsize',16)
%compute reverse cdf function for translation
[icdf_rtt,x_icdf_rtt] = ksdensity(rtt,'npoints',N,'function','icdf');
I = find(~isnan(icdf_rtt));
Xrtt = [0,max(x_icdf_rtt(I),0),1];
Yrtt = [0,max(icdf_rtt(I),0),max(rtt)];
hrtt = @(x) interp1(Xrtt,Yrtt,x);
[icdf_tput,x_icdf_tput] = ksdensity(tput,'npoints',N,'function','icdf');
I = find(~isnan(icdf_tput));
Xtput = [0,max(x_icdf_tput(I),0),1];
Ytput = [0,max(icdf_tput(I),0),max(tput)];
htput = @(x) interp1(Xtput,Ytput,x);
%%Computation of pdf
[rho,nu] = copulafit('t',[cdf_rtt',cdf_tput']);
%Computation pdf with cdf points output by kernel cdf estimation
[X,Y] = meshgrid(cdf_rtt,cdf_tput);
F = copulapdf('t',[X(:),Y(:)],rho,nu);
Fr = reshape(F,N,N);
figure()
surf(hrtt(X),htput(Y),Fr);
axis([min(min(hrtt(X))),max(max(hrtt(X))),min(min(htput(Y))),max(max(htput(Y))),min(F),max(F)]);
xlabel('RTT(s)','Fontsize',18);
ylabel('Tput(bps)','Fontsize',18);
zlabel('PDF(RTT,TPUT)','Fontsize',18);
title('Estimation of bidimensional pdf of Tput, RTT using normal kernel and Gaussian copula at equidistant points on RTT/TPUT cdfs','Fontsize',18,'Fontweight','bold')
set(gca,'Fontsize',16);

%Computation pdf on equally spaced point on the [0,1]x[0,1] hypercube
xlin = linspace(min(rtt),max(rtt),N);
ylin = linspace(min(tput),max(tput),N);
[Xl1,Yl1] = meshgrid(xlin,ylin);
xlin2 = ksdensity(rtt,xlin,'function','cdf');
ylin2 = ksdensity(tput,ylin,'function','cdf');
[Xl2,Yl2] = meshgrid(xlin2,ylin2);
Fl = copulapdf('t',[Xl2(:),Yl2(:)],rho,nu);
Frl = reshape(Fl,N,N);
figure
surf(Xl1,Yl1,Frl);
axis([min(min(Xl1)),max(max(Xl1)),min(min(Yl1)),max(max(Yl1)),min(Fl),max(Fl)]);
xlabel('RTT(s)','Fontsize',18);
ylabel('Tput(bps)','Fontsize',18);
zlabel('PDF(RTT,TPUT)','Fontsize',18);
title('Estimation of bidimensional pdf of Tput, RTT using normal kernel and Gaussian copula at equidistant points on RTT/TPUT then converted to cdfs','Fontsize',18,'Fontweight','bold')
set(gca,'Fontsize',16);
%Computation of conditional CDF
dx = xlin(2)-xlin(1);
dy = ylin(2)-ylin(1);
FC = Frl./(repmat(sum(Frl,1),size(Frl,2),1)*dy);
figure()
surf(Xl1,Yl1,FC)
xlabel('RTT(s)','Fontsize',18);
ylabel('Tput(bps)','Fontsize',18);
zlabel('Conditional_PDF(RTT,TPUT)','Fontsize',18);
title('Estimation of bidimensional pdf of Tput conditionally on RTT using normal kernel and Gaussian copula at equidistant points on RTT/TPUT then converted to cdfs','Fontsize',18,'Fontweight','bold')
%Returning values
pdf = Frl;
pdfc= FC;
Xp = Xl1;
Yp = Yl1;

%computing expecting value of Y
I = find(Xl1(1,:)<=maxx & Xl1(1,:)>=minx);
FD = sum(pdfc(:,I),2)*dx/(sum(sum(pdfc(:,I)))*dx*dy);
Etput_aft = sum(Yl1(:,1).*FD*dy);
Ftput = sum(Frl,2)*dx / (sum(sum(Frl))*dx*dy);
Etput_bef = sum(Yl1(:,1).*Ftput*dy);
ea = Etput_aft;
eb = Etput_bef;