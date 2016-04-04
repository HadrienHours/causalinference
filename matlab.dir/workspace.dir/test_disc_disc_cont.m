function [r,p] = test_disc_disc_cont(D,i,j,k,alpha)
%This function test the independence between X and Y conditionally on Z in
%the case where X and Y are discrete and Z is continuous
%INPUTS
%       D: n*p dataset of n samples of p parameters
%       i: dimension corresponding to X
%       j: dimension corresponding to Y
%       k: dimension corresponding to Z
%       alpha: significance level
%OUTPUTS
%       r: test outcome (1 if independent 0 otherwise)
%       p: p value

n = size(D,1);
p = size(D,2);

quantization = 1;

if quantization > 0
    weight = floor(n*alpha);
    edges = quantize_fixedweight(D(:,k),weight);
    [dsq,ps_quant,qs_quant] = quantize_function(D(:,k),{edges{1}});
    D2 = [D(:,i),D(:,j),dsq];
    s = size(k,2);
    [r,p] = test_discrete(D2,1,2,[3:3+s-1],alpha);
end