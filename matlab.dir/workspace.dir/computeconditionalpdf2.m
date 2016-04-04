function [] = computeconditionalpdf2(ds,dimx,dimy,methodk,methodc,N)
%This function use copulae to compute the conditional probability
%distribution of f_x/y
%inputs
%       ds: the dataset
%       dimx: x dimension
%       dimy: y dimension(s)
%       methodk: kernel method for estimating marginals
%       (normal,box,triangle,epanechniokv)
%       methodc: Copula type (Gaussian or t)
%       N: number of points to use for estimating marginals
%output
%       [x,y,f_x/y]

if nargin ~= 6
    error('Wrong number of arguments, see help')
end

x = ds(:,dimx);
ny = size(dimy,2);
y = ds(:,dimy);

%Estimate CDF marginals
[cdf_x,x_x] = ksdensity(x,'npoints',N,'kernel',methodk,'function','cdf');
cdf_y = zeros(ny,N);
x_y = zeros(ny,N);
for i = 1:ny
    [cdf_y(i,:),x_y(i,:)] = ksdensity(y(:,i),'npoints',N,'kernel',methodk,'function','cdf');
end

%Estimate CDF of y
Yx = cell(1,ny);
Yx = ngrid(

%estimate PDF marginals
[pdf_x,xp_x] = ksdensity(x,'npoints',N,'kernel',methodk,'function','pdf');
pdf_y = zeros(ny,N);
xp_y = zeros(ny,N);
for i = 1:ny
    [pdf_y(i,:),xp_y(i,:)] = ksdensity(y(:,i),'npoints',N,'kernel',methodk,'function','pdf');
end

%Estimate iCDF marginals
[icdf_x,ix_x] = ksdensity(x','npoints',N,'kernel',methodk,'function','icdf');
    %remove bad values and create interp fn
I = find(~isnan(icdf_x));
Xx = [0,max(ix_x(I),0),1];
Yx = [0,max(icdf_x(I),0),max(x)];
hx = @(x1) interp1(Xx,Yx,x1);
icdf_y = zeros(ny,N);
ix_y = zeros(ny,N);
hy = cell(1,ny);
for i = 1:ny
    [icdf_y(i,:),ix_y(i,:)] = ksdensity(y(:,i)','npoints',N,'kernel',methodk,'function','icdf');
    I = find(~isnan(icdf_y(i,:)));
    Xy = [0,max(ix_y(i,I),0),1];
    Yy = [0,max(icdf_y(i,I),0),max(y(:,i))];
    hy{i} = @(x1) interp1(Xy,Yy,x1);
end

%Estimate parameters copulas
cdf_1 = zeros(size(cdf_x,2),ny+1);
cdf_2 = cdf_y';
cdf_1(:,1) = cdf_x';
for i = 1:ny
    cdf_1(:,i+1) = cdf_y(i,:)';
end
cdf_1(cdf_1==0) =eps;
cdf_2(cdf_2==0) =eps;
cdf_1(cdf_1==1) =1-eps;
cdf_2(cdf_2==1) =1-eps;
[rho1,nu1] = copulafit(methodc,[cdf_1]);
[rho2,nu2] = copulafit(methodc,[cdf_2]);

if ny == 1
    [X.Y] = meshgrid(cdf_x,cdf_y);
    [Xp,Yp] = meshgrid(pdf_x,pdf_y);
    F = copulapdf(methodc,[X(:),Y(:)],rho,nu);
Fr = reshape(F,N,N);
elseif ny == 2
    [X,Y,Z] = ndgrid(cdf_x,cdf_y(1,:),cdf_y(2,:));
    [Xp,Yp,Zp] = meshgrid(pdf_x,pdf_y(1,:),pdf_y(2,:));
    F = copulapdf(methodc,[X(:),Y(:),Z(:)],rho,nu);
    Fr = reshape(F,N,N,N);
elseif ny == 3
    [X,Y,Z,W] = ndgrid(cdf_x,cdf_y(1,:),cdf_y(2,:),cdf_y(3,:));
    [Xp,Yp,Zp,Wp] = meshgrid(pdf_x,pdf_y(1,:),pdf_y(2,:),pdf_y(3,:));;
    F = copulapdf(methodc,[X(:),Y(:),Z(:),W(:)],rho,nu);
    Fr = reshape(F,N,N,N,N);
else
    error('Dynamic method not implemented, cond set has to be of size 3 maximum')
end

