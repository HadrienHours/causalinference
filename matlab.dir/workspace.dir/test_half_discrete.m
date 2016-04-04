function [r,p] = test_half_discrete(D,i,j,alpha)
% This function test if X is independent of Y in the case where X is
% continuous and Y is not.
%INPUTS
%       D: n*p dataset of n samples of p parameters
%       i: dimension corresponding to X
%       j: dimension corresponding to Y
%       alpha: significance level
%OUTPUTS
%       r: test outcome 1 if independent 0 otherwise
%       p: p-value

n = size(D,1);
p = size(D,2);

quantization = 1;

if quantization > 0
    weight = floor(n*alpha);
    if weight > 0
        edges = quantize_fixedweight(D(:,j),weight);
        [dsq,ps_quant,qs_quant] = quantize_function(D(:,j),{edges{1}});
        D2 = [D(:,i),dsq];
        [r,p] = test_discrete(D2,1,2,[],alpha);
    else
        r = -1;
        p = -1;
    end
end