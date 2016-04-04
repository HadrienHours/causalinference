function [ds_quant,ps_quant,qs_quant] = quantize_function(ds,edges)
%This function takes as input the quantization bins and output a
%discretization of ds. 
%All the samples < left border of the smallest bin are put in the smallest
%bin
%All the samples > right border of the biggest bin are put in the biggest
%bin
%inputs
%           ds: n*p matrix representing n samples of p parameters
%           edges: cell of p matrix of ri*3, each of which contains in each line
%           the border of the bin and its corresponding value
%outputs
%           ds_quant: quantized version of the dataset
%           ps_quant: probability of the quantized samples
%           qs_quant: cdf corresponding to the quantized samples
n=size(ds,1);
p=size(ds,2);

if size(ds,2) ~= size(edges,2)
   error('The number of dimension does not match'); 
end

ds_quant = NaN(size(ds));
ps_quant = NaN(size(ds));
qs_quant = NaN(size(ds));

for i = 1:p
    for j = 1:size(edges{i},1)
            %Check for discrete function for this dimension
            if (edges{i}(j,2) - edges{i}(j,1)) ~= 0
                I = find(ds(:,i)>= edges{i}(j,1) & ds(:,i) < edges{i}(j,2));
                ds_quant(I,i) = edges{i}(j,3);
                ps_quant(I,i) = edges{i}(j,4);
                qs_quant(I,i) = edges{i}(j,5);
            else
                I = find(ds(:,i) == edges{i}(j,1));
                ds_quant(I,i) = edges{i}(j,3);
                ps_quant(I,i) = edges{i}(j,4);
                qs_quant(I,i) = edges{i}(j,5);
            end
    end
    %The values smaller than the minimum of the bins take the value
    %corresponding to the smaller bin
    I = find(ds(:,i) < edges{i}(1,1));
    ds_quant(I,i) = edges{i}(1,3);
    ps_quant(I,i) = edges{i}(1,4);
    qs_quant(I,i) = edges{i}(1,5);
    %Idem for the values falling after the last bin or equal to maximum
    I = find(ds(:,i) >= edges{i}(end,2));
    ds_quant(I,i) = edges{i}(end,3);
    ps_quant(I,i) = edges{i}(end,4);
    qs_quant(I,i) = edges{i}(end,5);
    % In case in this dimension we have discrete values not present in the
    % training set, we give them the value of the closest training set
    % value
    NC = find(isnan(ds_quant(:,i)));
    l= sort(unique(ds(NC,i)));
    for j = 1:size(l,1)
       T = l(j)*ones(size(edges{i}),1);
       V = abs(T - edges{i}(:,3));
       %Look for the discrete value closer (l1-distance) to the dataset
       %values under study (l(j))
       [m,idx] = min(V);
       I = find(ds(:,i) == l(j));
       ds_quant(I,i) = edges{i}(idx,3);
       ps_quant(I,i) = edges{i}(idx,4);
       qs_quant(I,i) = edges{i}(idx,5);
    end
end