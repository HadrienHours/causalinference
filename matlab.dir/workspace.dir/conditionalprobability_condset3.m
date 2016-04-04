function [pdfxCy,xv,yv] = conditionalprobability_condset3(ds,dimx,dimy,methodk,methodc,plotf)
%this function use kernel and copula to compute fx/y for y of size 3
%inputs
%       ds: the dataset
%       dimx: the dimension of x
%       dimy: the three dimension of y
%       methodk: string, kernel type (default normal)
%       methodc: string, copula type (default t)
%       plot = flag, if set to 1 will plot fx and fx_y for x
%output
%       f_x/y
%       x
%       y

n = size(ds,1);
xv = ds(:,dimx);
yv = ds(:,dimy);
if nargin < 3
    error('Not enough arguments')
elseif nargin == 3
    methodk = 'normal';
    methodc = 't';
    plotf = 0;
elseif nargin == 5
    plotf= 0;
elseif nargin > 6
    error('Too much inputs');
end

if length(dimy) ~= 3
    error('This function is for condset size of 3');
end

%compute Fy
    %marginals
cdfsy = zeros(3,n);
yv = zeros(3,n);
if plotf
    figure()
end
for i = 1:3
    yi = dimy(i);
    [cdfsy(i,:),yv(i,:)] = ksdensity(ds(:,yi),ds(:,yi),'kernel',methodk,'function','cdf');
    if plotf
        subplot(3,1,i)
        plot(yv(i,:),cdfsy(i,:),'linestyle','None','Marker','+')
        tit = strcat('Values for parameter ',num2str(yi));
        xlabel(tit,'fontsize',16)
        ylabel('CDF','fontsize',16)
        tit = strcat('CDF estimated with kernel ',methodk,' for parameter ',num2str(yi));
        title(tit,'fontsize',16,'fontweight','bold');
        grid on
        set(gca,'fontsize',14)
    end
end

fprintf('Size of cdfs of y is %d,%d\n',size(cdfsy))

if strcmp(methodc,'t')
    [rhoy,nuy] = copulafit('t',cdfsy')
    cdfy = copulacdf('t',cdfsy',rhoy,nuy);
elseif strcmp(methodc,'Gaussian')
    rhoy = copulafit('Gaussian',cdfsty');
    cdfy = copulacdf('t',cdfsy',rhoy);
else
    error('Unknown copula method')
end

fprintf('Size of the cdfy is %d,%d\n',size(cdfy));

%compute Fx
cdfx = ksdensity(ds(:,dimx),ds(:,dimx),'kernel',methodk,'function','cdf');
pdfx = ksdensity(ds(:,dimx),ds(:,dimx),'kernel',methodk,'function','pdf');

fprintf('The size of cdfx is %d,%d\n',size(cdfx));

%compute Fxy
if strcmp(methodc,'t')
    [rhog,nug] = copulafit('t',[cdfx,cdfy])
    pdfxCy = copulapdf('t',[cdfx,cdfy],rhog,nug).*pdfx;
elseif strcmp(methodc,'Gaussian')
    rhog = copulafit('Gaussian',[cdfx',cdfy']);
    pdfxCy = copulapdf('Gaussian',[cdfx',cdfy'],rhog).*pdfx;
end

if plotf
    figure()
    subplot(2,1,1)
    plot(ds(:,dimx),pdfx,'linestyle','None','Marker','+')
    grid on
    xlabel('X values','fontsize',16)
    ylabel('fx','fontsize',16)
    title('X pdf marginal','fontsize',16,'fontweight','bold')
    set(gca,'fontsize',14)
    subplot(2,1,2)
    plot(ds(:,dimx),pdfxCy,'linestyle','None','Marker','+')
    grid on
    xlabel('X values','fontsize',16)
    ylabel('fx/y','fontsize',16)
    title('PDF of x cond on y','fontsize',16,'fontweight','bold')
    set(gca,'fontsize',14)
end