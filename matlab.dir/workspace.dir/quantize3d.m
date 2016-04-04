function [dsq] = quantize3d(ds,R1,R2)
%This function takes a 3D dataset and quantize it on 2 dimensional bin
%INPUT
%   ds: n*3 dataset
%   R1: number of bins or bin width for x
%   R2: number of bins or bin width for y
%output
%   dsq: R or floor(n/R) *3 dataset

if nargin < 2
    error('Not enough arguments');
elseif nargin == 2
    R2=R1;
end
%Test if R1 is an integer by looking at the rest of division by 1
if mod(R1,1)==0
    xx = linspace(min(ds(:,1)),max(ds(:,1)),R1);
    size(xx)
else
    xx = linspace(min(ds(:,1)),max(ds(:,1)),floor(range(ds(:,1))/R1));
end

if mod(R2,1)==0
    yy = linspace(min(ds(:,2)),max(ds(:,2)),R2);
else
    yy = linspace(min(ds(:,2)),max(ds(:,2)),floor(range(ds(:,2))/R2));
end

nx = size(xx,2);
ny = size(yy,2);

dsq = zeros(nx*ny,3);
counter = 0;
for i = 1:nx-1
    for j = 1:ny-1
       counter=counter+1;
       if mod(counter,10000) == 0
           fprintf('Filling cell %d on a total of %d\n',counter,nx*ny)
       end
       I = ds(:,1) >= xx(i) & ds(:,1) < xx(i+1) & ds(:,2)>= yy(j) & ds(:,2) < yy(j+1);
       if size(I,1) ~= 0
           Z = mean(ds(I,3));
       else
           Z = 0;
       end
       ds(counter,1) = xx(i);
       ds(counter,2) = yy(j);
       ds(counter,3) = Z;
    end
end