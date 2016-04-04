function [ds_quant,p] = quantize_prob(ds,edges)
%This functions gives the probability of each samples according to the
%quantization dictated by the bins described in the edges
%inputs
%           ds: n*p matrix representing the n samples of p parameters
%           edges: cell of p matrix containing the sequence of bins for
%           each quantization for each dimension with lower bound, upper
%           bound, value, probability, number of samples
%outputs
%           ds_quant : quantized values of ds
%           p        : probability of each sample of ds_quant

n=size(ds,1);
p=size(ds,2);

