function [px,x] = backdooradj3pars(ds,dimx,dimy,dimz,N,valy,deltay,methodk,methodc)
%This function returns the value of Pr(X/do(Y=y)) with Y \in
%[y-delta,y+delta], applying back door criteria
%input
%       ds: dataset
%       dimx: dimension of target var X
%       dimy: dimension of interventional var Y
%       dimz: dimension(s) of back door vars
%       N: number of points for linear kernel marginal estimation
%       valy: interventional values
%       deltay: interval around valy
%       methodk [optional]: kernel type
%       methodc [optional]: copula type
%output
%       [vx,fvx]

if nargin < 7
    error('Not enough arguments given, see help')
elseif nargin == 7 
    methodk = 'normal';
    methodc = 't';
elseif nargin == 8
    methoc = 't';
elseif nargin > 9
    error('Wrong number of args, see help')
end

n = size(ds,1);
p = size(ds,2);

%compute fx/yz
conddim1 = [dimy,dimz(:)];
[pdfxCy,xv,yv] = conditionalprobability_condset3_ext(ds,dimx,conddim1,N,methodk,methodc,0);

%compute fz
[z,fz] = computemultidimprob_linext(ds,dimz,N,methodk,methodc);

I = find(yv(:,1)>= (valy+deltay) & yv(:,1) <= (valy+deltay));
Xp = xv(I);
Zp = yv(I,[2:end]);
Fxyzp = pdfxCy(I);
Fzp = fz(I);%%%%%%%%%%%%% ONLY VALID BECAUSE WE USE THE SAME MARGINALS SUPPORTS in both previous functions

%compute P(y/do(X=x)) = sum_z{P(y/X,Z=z)Pz(Z)
x = Xp;
px = Fxyzp.*Fzp; %no integral because no 3d extrapolation used here