function [r,p] = test_disc_cont_disc(D,i,j,k,alpha)
% This function test the conditional independence of X and Y conditionally
% on Z in the case where X is discrete Y is continous and Z is discrete

n = size(D,1);
p = size(D,2);

quantization = 1;

if quantization > 0
% Better quantization if clusterization but losing too much variation     
%    %Clusterization
%    s0 = size(D,1)+1;
%    s1 = size(D,1);
%    k = 0;
%    while s1 < s0
%         s0 = s1;
%         k = k+1;
%         flag = 0;
%         while flag == 0
%             try
%                 [idx,c,s] = kmeans(D(:,j),k);
%                 flag = 1;
%             catch
%                 flag = 0;
%             end
%         end
%        s1 = sum(s);
%    end
   %Quantization
    weight = floor(n*alpha);
    edges = quantize_fixedweight(D(:,j),weight);
    [dsq,ps_quant,qs_quant] = quantize_function(D(:,j),{edges{1}});
    D2 = [D(:,i),dsq,D(:,k)];
    s = size(k,2);
    [r,p] = test_discrete(D2,1,2,[3:3+s-1],alpha);
end