function [bd_dsy,prob,dsq,dscen,edges] = backdooreffect_q_fixed_centroid(ds,dscen,x,y,z,b,delta)
%This function return the Probability of Pr(Y / do(X=x)) using the backdoor
%adjustement with the set z Pr(Y / do(X=x)) = sum_{z}Pr(Y/X=x,Z=z)Pr(Z=z)
%In this version the dataset is quantized, the probability are computed
%based on kmeans and centroids are translated in their quantized values as
%pre formatting input
%inputs
%       ds = the dataset n*p matrix : n samples p parameters
%       dsc = centroid dataset k*p+1: k centroids, p parameters, 1
%       probability
%       x = vector of two values, the dimension and the value to set on
%       this dimension
%       y = scalar representing the dimension of Y
%       z = vector representing the dimension(s) corresponding to the
%       blocking set Z
%       b = number of samples per bin for quantization
%       delta [optional] = scalar < 1 representing percentage error selection
%outputs
%       res = ny*2 matrix: the different value of y and their probability
%       prob = the probability of the result before normalization
%       dsq = k*p+1 matrix: The quantized centroids and their
%             probabilities,used for computing the causal effect
%       dsc = k*p+1 matrix: The centroids and their probabilities
%       edges = cell of k matrices of 6 columns representing the bins
%               used for quantization [bin_left,bin_right,value,prob,nsamples]

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
k = size(dscen,1);

dimx = x(1);
dimy = y;

%Build the probabilities
% [dsq,dsp,edges,centroids] = quantize_global(ds,k,b);


%Build the dataset
edges = quantize_fixedweight(ds,b);
[dsq,dspp,dspc] = quantize_function(dscen(:,1:p),edges);
dsq = [dsq,dscen(:,p+1)];

%Find x bin and the corresponding value
dimx = x(1);
vx = x(2);
edgex = edges{dimx};
I = find(edgex(:,1)<=vx);
edgex =edgex(I,:);
I = find(edgex(:,2) > vx);
binx = min(I);
vx = edgex(binx,3);


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
%dsz = marginalize_probability(dsq,idz,delta); delta remove as we have
%discrete values due to quantization
dsz = marginalize_probability(dsq,idz);


%After quantization several duration values in the dataset are the same
ly = unique(dsq(:,dimy));
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
        [dsc,pr] = conditionned_probability(dsq,idxz,valxz,delta);
%         if ~isempty(dsc)
%             fprintf('%d samples found for conditioning on values hereafter (prob = %f)\n',size(dsc,1),pr)
%             idxz
%             valxz
%             if size(dsc,1) > 5
%                 pause
%             end
%         else
%             fprintf('No samples found for conditions on dimensions and values hereafter\n')
%             idxz
%             valxz
% 
%         end
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

%Normalizing to obtain probability
prob = sum(bd_dsy(:,end));
bd_dsy(:,end) = bd_dsy(:,end)/prob;