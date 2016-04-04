function [corxy] = correlation2(x,y)
% The inputs have to be vectors (1*N) with same size
mx=sum(x)/size(x,1);
my=sum(y)/size(y,1);
% xc=x-ones(size(x))*mx;
% mean(xc)
% pause
% yc=y-ones(size(y))*my;
% %fprintf('Size are \nxc = %d\nyc=%d\nzc = %d\n',size(xc,2),size(yc,2),size(zc,2))
% xc2=[];
% yc2=[];

num = 0;
for i=1:size(x,1)
   num=num+(x(i)-mx)*(y(i)-my);
end

denum = 0;
denumx=0;
denumy=0;
for i=1:size(x,1)
    denumx=denumx+(x(i)-mx)^2;
    denumy=denumy+(y(i)-my)^2;
end
corxy=num/(sqrt(denumx)*sqrt(denumy));

% 
% for i=1:size(x,2),
%     xc2= [xc2,(x(i)-mean(x))^2];
%     yc2= [yc2,(y(i)-mean(y))^2];
% end
% %fprintf('Size are \nxc2 = %d\nyc2=%d\nzc2 = %d\n',size(xc2,2),size(yc2,2),size(zc2,2))
% corxy=sum(xc.*yc)/((sum(xc2)*sum(yc2))^(1/2));
% %fprintf('Result is %f\n',parcorxyz)
% end