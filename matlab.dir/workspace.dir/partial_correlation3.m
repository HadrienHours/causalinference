function [parcorxyz] = partial_correlation3(x,y,z)
% The inputs have to be vectors (1*N) with same size
mx=mean(x);
my=mean(y);
mz=mean(z);
xc=x-ones(1,size(x,2)).*mean(x);
yc=y-ones(1,size(y,2)).*mean(y);
zc=z-ones(1,size(z,2)).*mean(z);
%fprintf('Size are \nxc = %d\nyc=%d\nzc = %d\n',size(xc,2),size(yc,2),size(zc,2))
xc2=[];
yc2=[];
zc2=[];
for i=1:size(x,2),
    xc2= [xc2,(x(1,i)-mean(x))^2];
    yc2= [yc2,(y(1,i)-mean(y))^2];
    zc2= [zc2,(z(1,i)-mean(z))^2];
end
%fprintf('Size are \nxc2 = %d\nyc2=%d\nzc2 = %d\n',size(xc2,2),size(yc2,2),size(zc2,2))
corxy=sum(xc.*yc)/((sum(xc2)*sum(yc2))^(1/2));
coryz=sum(yc.*zc)/((sum(yc2)*sum(zc2))^(1/2));
corxz=sum(xc.*yc)/((sum(xc2)*sum(yc2))^(1/2));
parcorxyz=(corxy-coryz*corxz)/(((1-(coryz)^2)*(1-(corxz)^2))^(1/2));
%fprintf('Result is %f\n',parcorxyz)
end
