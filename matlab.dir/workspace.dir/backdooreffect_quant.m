function [bd_dsy,prob,dsq,dsp,edges,centroids] = backdooreffect_quant(ds,x,y,z,k,b,delta)
%This function return the Probability of Pr(Y / do(X=x)) using the backdoor
%adjustement with the set z Pr(Y / do(X=x)) = sum_{z}Pr(Y/X=x,Z=z)Pr(Z=z)
%inputs
%       ds = the dataset n*p matrix : n samples p parameters
%       x = vector of two values, the dimension and the value to set on
%       this dimension
%       y = scalar representing the dimension of Y
%       z = vector representing the dimension(s) corresponding to the
%       blocking set Z
%       k = number of clusters for kmean in probability estimation
%       b = number of samples per bin for quantization
%       delta [optional] = scalar < 1 representing percentage error selection
%outputs
%       res = ny*2 matrix: the different value of y and their probability
%       prob = the probability of the result before normalization
%       dsq = k*p+1 matrix: The quantized centroids and their
%             probabilities,used for computing the causal effect
%       dsp = k*p+1 matrix: The centroids and their probabilities
%       edges = cell of k matrices of 6 columns representing the bins
%               used for quantization [bin_left,bin_right,value,prob,nsamples]
%       centroids = k centroids obtained from k means

if nargin < 6
    error('Not enough arguments. See help');
elseif nargin == 6
    delta = 0;
elseif nargin == 7
    if delta > 1 | delta < 0
        error('Last argument must be a percentage (>0, < 1)');
    end
elseif nargin > 7
    error('Too many arguments. See help');
end

n = size(ds,1);
p = size(ds,2);

dimx = x(1);
dimy = y;

%Build the probabilities
[dsq,dsp,edges,centroids] = quantize_global(ds,k,b);


%Find x bin and the corresponding value
dimx = x(1);
vx = x(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%If we don't requantize the centroids to fall in the bins fitting the   %%
%%dimensions of the original dataset there is no reason for mapping the x%%
%%value to its corresponding bin                                         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% edgex = edges{dimx};
% I = find(edgex(:,1)<=vx);
% edgex =edgex(I,:);
% I = find(edgex(:,2) > vx);
% binx = min(I);
% vx = edgex(binx,3);


zl = z;


index = 1:p;

%build the Z set
idz = 1:p;
for i = 1:size(z,2)
    idz(zl(i)) = [];
    %as we removed one value from the index, the dimension are now shifted
    %by 1 to right
    zl = zl - 1;
end


%compute the Z probability mass function
dsz = marginalize_probability(dsp,idz,delta);


%After quantization several duration values in the dataset are the same
ly = unique(dsp(:,dimy));
bd_dsy = zeros(size(ly,1),2);

for i = 1:size(ly,1)
    vy = ly(i);
    prvy = 0;
    for j=1:size(dsz,1);
        vz = dsz(j,1:end-1);
        pz = dsz(j,end);
        [idxz,t] = sort([z,dimx]);
        valxz = [vz,vx];
        valxz = valxz(t);
        [dsc,pr] = conditionned_probability(dsp,idxz,valxz,delta);
        if ~isempty(dsc)
            fprintf('%d samples found for conditioning on values hereafter (prob = %f)\n',size(dsc,1),pr)
            idxz
            valxz
            if size(dsc,1) > 5
                pause
            end
%         else
%             fprintf('No samples found for conditions on dimensions and values hereafter\n')
%             idxz
%             valxz

        end
        % Here we have the dataset with Z set to valz (multidim), X set to
        % x (unidim) and different values for y, the probability of the
        % line
        vy_l = vy - delta*vy;
        vy_r = vy + delta*vy;
        I = find(dsc(:,dimy) >= vy_l & dsc(:,dimy) <= vy_r);
        %We approximate Pr(Y=y1/X=x,Z=z) by sum_{y1-delta%<=y<=y1+delta%}
        %Pr(Y=y/X=x,Z=z)
        %Pr(Y=y1/do(x)) = sum_{z} Pr(Y=y1/X=x,Z=z)Pr(Z=z)
        prvy = prvy + sum(dsc(I,end))*pz;
    end
    bd_dsy(i,1) = vy;
    bd_dsy(i,2) = prvy;
end

prob = sum(bd_dsy(:,end));
bd_dsy(:,end) = bd_dsy/prob;