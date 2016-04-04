function [X,Y,Zlin,Zcub,Zv4,Znr,Zlinflatten,Zcubflatten,Zv4flatten,Znrflatten] = extrapolate(dataset,N,labs)
% This function is extrapolating the one given as input according to 4 different methods: Linear, Nearest Neighbor, Cubic and Matlab v4
% 
% INPUTS
%         dataset : a n*3 corresponding to [x,y,f(x,y)]
%         N       : The number of point to extrapolate between min and max of each x and y
%         labs    : Cell containins the labels of each dimension
% Ouptut
%         X       : The grid corresponding to n*n point of x
%         Y       : The grid corresponding to n*n points of y
%         Z       : The output corresponding to 2n*2n points

x=dataset(:,1);
y=dataset(:,2);
z=dataset(:,3);
ylin = linspace(min(y),max(y),N);
xlin = linspace(min(x),max(x),N);
[X,Y] = meshgrid(xlin,ylin);
Zlin = griddata(x,y,z,X,Y,'linear');
Zcub = griddata(x,y,z,X,Y,'cubic');
Zv4 = griddata(x,y,z,X,Y,'v4');
Znr = griddata(x,y,z,X,Y,'nearest');
%linear case
figure()
mesh(X,Y,Zlin)
hold on
plot3(x,y,z,'k*','Markersize',6,'Linewidth',4)
title('Linear extrapolation','Fontsize',20,'Fontweight','bold')
xlabel(labs{1},'Fontsize',20)
ylabel(labs{2},'Fontsize',20)
zlabel(labs{3},'Fontsize',20)
set(gca,'Fontsize',20)
colormap cool

%cubic case
figure()
mesh(X,Y,Zcub)
hold on
plot3(x,y,z,'k*','Markersize',6,'Linewidth',4)
title('Cubic extrapolation','Fontsize',20,'Fontweight','bold')
xlabel(labs{1},'Fontsize',20)
ylabel(labs{2},'Fontsize',20)
zlabel(labs{3},'Fontsize',20)
set(gca,'Fontsize',20)
colormap cool

%Matlab 4
figure()
mesh(X,Y,Zv4)
hold on
plot3(x,y,z,'k*','Markersize',6,'Linewidth',4)
title('Matlab v4 extrapolation','Fontsize',20,'Fontweight','bold')
xlabel(labs{1},'Fontsize',20)
ylabel(labs{2},'Fontsize',20)
zlabel(labs{3},'Fontsize',20)
set(gca,'Fontsize',20)
colormap cool

%Nearest neighbor
figure()
mesh(X,Y,Znr)
hold on
plot3(x,y,z,'k*','Markersize',6,'Linewidth',4)
title('Nearest Neighbor extrapolation','Fontsize',20,'Fontweight','bold')
xlabel(labs{1},'Fontsize',20)
ylabel(labs{2},'Fontsize',20)
zlabel(labs{3},'Fontsize',20)
set(gca,'Fontsize',20)
colormap cool

Znrflatten = zeros(N.^2,3);
Zv4flatten = zeros(N.^2,3);
Zcubflatten = zeros(N.^2,3);
Zlinflatten = zeros(N.^2,3);

for i=1:N
    for j=1:N
        Zlinflatten(i*j,1)=X(i,j);
        Zlinflatten(i*j,2)=Y(i,j);
        Zlinflatten(i*j,3)=Zlin(i,j);
        Znrflatten(i*j,1)=X(i,i);
        Znrflatten(i*j,2)=Y(i,j);
        Znrflatten(i*j,3)=Zlin(i,j);
        Zcubflatten(i*j,1)=X(i,j);
        Zcubflatten(i*j,2)=Y(i,j);
        Zcubflatten(i*j,3)=Zlin(i,j);
        Zv4flatten(i*j,1)=X(i,j);
        Zv4flatten(i*j,2)=Y(i,j);
        Zv4flatten(i*j,3)=Zlin(i,j);
    end
end