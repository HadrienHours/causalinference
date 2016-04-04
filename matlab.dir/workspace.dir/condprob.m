function [p] = condprob (M,dims,sets)
% This function compute the condtional probabilities of the form
% P(A in A1 / B in B1) or
% P(A in A1 / B in B1 and C in C1)
%
% It takes as input 
%           . the global matrix corresponding to all the samples on
% all dimension, 
%           . the variables on which the conditional probabilities have to be
%           computed: First A and second B and (optionally) C
%           . the set for each variable on which the probability is
%           computed
%
%   
% INPUTS
%         M = n*p matrix representing the global measurements
%             n samples
%             p dimension
%         dims = 1*c vector containings the dimensions corresponding to the
%                variables on which the probability will be computed (c <= 3)
%         sets = c*2 matrix containing the interval limits for each
%                dimension
%
%The probabilities are computed as P(A/B) = P(A,B) / P(B) or P(A/B,C) = P(A,B,C)/P(B,C)
% P(X1,...,Xn) approximated with frequencies  = number of samples matching
% the sets / total number of samples


if (size(dims,2) > 3 | size(dims,2) < 1)
    error('The second parameters must contain the indexes of the variables to compute cond prob\n');
end

if (size(dims,2) ~= size(sets,1) )
    error('The third parameter must contain a matrix c*2 where c is the number of variables\n')
end

%Get each variable from the global observation
vars = cell(1,size(dims,2));
for i=1:size(dims,2)
    vars{i} = M(:,dims(i));
end

% Get for each variable the samples corresponding to desired
% set
vars1 = cell(size(dims,2),2);
for i=1:(size(dims,2))
     vars1{i,1} = vars{i} >= sets(i,1);
     vars1{i,2} = vars{i} <= sets(i,2);
end

%compute the probabilities
%number of samples matching 1st dimension boundaries
vars2 = cell(1,size(dims,2));
for i=1:size(dims,2)
    vars2{i} = vars1{i,1} & vars1{i,2};
end

match_s = zeros(1,size(dims,2));

for i=1:size(dims,2)
    match_s(i)=size(find(vars2{i}),1);
end

%divide by the total number of samples to obtain the marginal frequencies
prob_set = match_s/size(M,1);%prob set contains P(A), P(B) and optionally P(C)

%compute P(A,B,C) et P(B,C) (C being optional)
num=vars2{1};% A
denum=vars2{2};% B
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