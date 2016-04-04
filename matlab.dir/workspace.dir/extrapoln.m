function v = extrapoln(dataset,domainsize,method)
% This function is multidimensional interpolation of the dataset, which
% last value is the function of the previous ones, to a larger domain
% according to the method which can be 'nearest', for Nearest Neighbor,
% 'linear', for linear extrapolation, 'spline' or 'cubic'
% INPUTS:
%             dataset: n*p matrix where the p-1 first columns represent the
%                      values for which we have the resulting function 
%                      which value is the pth column
%             domainsize : The size of the extrapolation domain
%             method : The method used for interpolation: 'nearest', 
%                      'linear', 'spline' or 'cubic'
% OUTPUT:
%             v      : N*1 vector representing the value of the function 
%                      extrapolated to the domain


p=size(dataset,2);
Xis = zeros(domainsize,p-1);
boarders= zeros(p-1,2);
for i=1:(p-1)
    boarders(i,1)=min(dataset(:,i));
    boarders(i,2)=max(dataset(:,i));
end
for i=1:(p-1)
    %creating the extrapolation domain by equally space point between the
    %given limits and of the given length
    Xis(:,i) = linspace(boarders(i,1),boarders(i,2),domainsize);
end
%here we have to assume the number of dimension, ie p-1, is 3
v = interpn(dataset(:,1)',dataset(:,2),dataset(:,3)',dataset(:,4)',Xis(:,1)',Xis(:,2),Xis(:,3),method);
