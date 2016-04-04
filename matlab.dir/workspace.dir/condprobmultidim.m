function [p] = condprobmultidim (M,x,y)
% This function compute the condtional probabilities of the form
% P(A in A1 / B in B1) for A and B of any dimension
%
% INPUTS
%           . n*p matrix: the global matrix corresponding to all the samples on
% all dimension, 
%           . x : sx*3 matrix containing, for each line, the dimension and
%           the borders defining the interval for this dimension
%           . y : sy*3 matrix containing, for each line, the dimension and
%           the borders defining the interval for this dimension
% OUTPUT
%           . p : scalar corresponding to Pr(x/y)
%The probabilities are computed as P(A/B) = P(A,B) / P(B)
% P(X1,...,Xn) approximated with frequencies  = number of samples matching
% the sets / total number of samples

if nargin < 3
    error('Not enough arguments, see help')
end

if (size(y,2) < 3 | size(x,2) < 3)
    error('The second and third parameter must be lists of [dim,leftboarder,rightboarder]\n');
end



%Get each variable from the global observation
varx = cell(1,size(x,1));
for i=1:size(x,1)
    varx{i} = M(:,x(i));
end

vary = cell(1,size(y,1));
for i=1:size(y,1)
    vary{i} = M(:,y(i));
end

% Get for each variable the samples corresponding to desired
% set
varx1 = cell(size(x,1),2);
for i=1:(size(x,1))
     varx1{i,1} = varx{i} >= x(i,2);
     varx1{i,2} = varx{i} <= x(i,3);
end

vary1 = cell(size(y,1),2);
for i=1:(size(y,1))
     vary1{i,1} = vary{i} >= y(i,2);
     vary1{i,2} = vary{i} <= y(i,3);
end

%compute the probabilities
%number of samples matching 1st dimension boundaries
varx2 = cell(1,size(x,1));
for i=1:size(x,1)
    varx2{i} = varx1{i,1} & varx1{i,2};
end

vary2 = cell(1,size(y,1));
for i=1:size(y,1)
    vary2{i} = vary1{i,1} & vary1{i,2};
end

match_sx = zeros(1,size(x,1));
match_sy = zeros(1,size(y,1));

for i=1:size(x,1)
    match_sx(i)=size(find(varx2{i}),1);
end

for i=1:size(y,1)
    match_sy(i)=size(find(vary2{i}),1);
end

%divide by the total number of samples to obtain the marginal frequencies
prob_setx = match_sx/size(M,1);
prob_sety = match_sy/size(M,1);

%compute P(A,B) and P(B)
num=varx2{1};% A
denum=vary2{1};% B

for l=1:(size(dims,2)-1)
%     fprintf('Num %d\n',l+1);
    num = num & vars2{l+1};% A&B and then A&B&C
%     find(num)
%     pause
%     fprintf('Denum %d\n',l+1);
    denum = denum & vars2{l+1};%B (B&B = B) and then B&C
%     find(denum)
%     pause
end
num_v = size(find(num),1);
denum_v = size(find(denum),1);
% fprintf('The probability will be computed as %f / %f\n',num_v,denum_v);

%We have Pr(A/B,C) = Pr(A,B,C)/Pr(B,C) = (#[A1,B1,C1]/N)/(#[B1,C1]/N)
%                                      = #[A1,B1,C1]/#[B1,C1]
if denum_v == 0
    p = 0;
else
    p = num_v / denum_v;
end