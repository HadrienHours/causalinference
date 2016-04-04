function p = frontdoor_effect(M,vars,setes,delta)
%this function computes the probability of P(x / do(y)) using the front
%door criterion formula
% P(y/do(x)) = sumz(P(z/x)sumx'(P(y/x'z)P(x'))
%
% INPUTS:
%         .M : n*p matrix representing n observation of p dimensions
%         .var: the indices (in the order) of x,y and the front door variable z
%         .sets: the sets for x and y for computing P(y in sets[2,:] / do(x in sets[1,:])
%         .delta: the threshold value to approximate the probability of a given value by the average value of the interval [v-delta,v+delta]
%         
%     OUTPUT : 
%         .p : the causal effect we want to predict

if size(vars,2) ~= 3
    error('The second argument argument must be a 1*3 matrix containing the indices of x,y and z for P(y/do(x)) using z as front door')
end

%Storing each dimesion
X = M(:,vars(1))';
Y = M(:,vars(2))';
Z = M(:,vars(3))';

%the prediction we want to make
p=0;

for z=Z
    %P(z/x)
    s1 = condprob(M,[vars(3),vars(1)],[z-delta,z+delta;setes(1,1),setes(1,2)])
    s2 = 0;
    
    for x=X
        %P(x')
        p1 = prob_quant(M(:,vars(1)),x,delta)
        %P(y/x',z)
        p2 = condprob(M,[vars(2),vars(1),vars(3)],[setes(2,1),setes(2,2);x-delta,x+delta;z-delta,z+delta])/(4*delta^2)
        s2=s2+p1*p2
    end
    p=p+s1*s2
end