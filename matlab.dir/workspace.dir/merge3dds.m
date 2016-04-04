function [X,Y,Z] = merge3dds(X1,Y1,Z1,X2,Y2,Z2)
% Take two 3d datasets and merge them removing the NaN values in Zx

%flatten all vectors
X10 = reshape(X1,1,size(X1,1)*size(X1,2));
Y10 = reshape(Y1,1,size(Y1,1)*size(Y1,2));
Z10 = reshape(Z1,1,size(Z1,1)*size(Z1,2));

X20 = reshape(X2,1,size(X2,1)*size(X2,2));
Y20 = reshape(Y2,1,size(Y2,1)*size(Y2,2));
Z20 = reshape(Z2,1,size(Z2,1)*size(Z2,2));

I1=find(~isnan(Z10));
X11 = X10(I1);
Y11 = Y10(I1);
Z11 = Z10(I1);

I2=find(~isnan(Z20));
X21 = X10(I2);
Y21 = Y10(I2);
Z21 = Z10(I2);

X = [X11,X21];
Y = [Y11,Y21];
Z = [Z11,Y21];

