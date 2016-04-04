function [ds_quant,ps_quant,qs_quant,multiprob,cmultiprob,rho,nu] = quantize_multiprob(ds,edges,methodc)
%this function return the multidimensional probability of the samples based
%on the cumulative probability functions and the copula <copulamethod>
%inputs
%           ds: n*p matrix representing n samples of p parameters
%           edges: cell of p matrix containing the sequence of bins for
%           each quantization for each dimension with lower bound, upper
%           bound, value, probability, number of samples
%           copulamethod: string describing the copula to use
%outputs
%           p : n*1 column giving the multidimensional probability of
%           each sample in ds once it had been quantized

n = size(ds,1);
p = size(ds,2);

[ds_quant,ps_quant,qs_quant] = quantize_function(ds,edges);


%Adapt the cdf so that the values fall in ]0;1[ and not in ]0;1]
for i = 1:p
    m = min(qs_quant(:,i))/10;
    M = max(qs_quant(:,i));
    I = find(qs_quant(:,i) == M);
    qs_quant(I,i) = M - m;
end

if strcmp(methodc,'Gaussian')
    rho = copulafit('Gaussian',qs_quant);
    multiprob = copulapdf('Gaussian',qs_quant,rho);
    cmultiprob = copulacdf('Gaussian',qs_quant,rho);
    nu = 0;
elseif strcmp(methodc,'t') 
   [rho,nu] = copulafit('t',qs_quant);
   multiprob = copulapdf('t',qs_quant,rho,nu);
   cmultiprob = copulacdf('t',qs_quant,rho,nu);
else
    error('Copula type chosen not recognized (Gaussian or t)')
end