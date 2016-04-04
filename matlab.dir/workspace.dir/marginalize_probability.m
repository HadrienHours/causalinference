function ds_m = marginalize_probability(ds,dimension,delta)
%Function which marginalize dimensions. For each unique row in the dataset
%from which the dimension were removed, to compute the new probability we
%take also all the rows distant to delta % from each dimension of the
%examined row. The sum of probability will then exceed one if delta > 0
%inputs
%           ds = n*(p+1) matrix representing n samples of p parameters and
%           their corresponding probability
%           dim = vector of 1*k representing the dimension to marginalize
%           delta [optional] = interval around which we assume the value to
%           be close enough to be considered as equal
%output
%           ds_m = n*(p-k+1) dataset corresponding the marginalized dataset

n = size(ds,1);
p = size(ds,2)-1;
k = size(dimension,2);

if nargin < 2
    error('Not enough arguments. See help');
elseif nargin == 2
    delta = 0;
elseif delta < 0
    error('Delta must be positive value');
end

if max(dimension) > p
    error('Dimension for marginalizing out of range')
end

idx = 1:p;
dim = dimension;
for i = 1:k
    idx(dim(i)) = [];
    %as we remove on dimension the resulting dimensions have to be shifted 
    dim = dim - 1;
end

%We select the unique rows once all the dimensions on which we have to
%marginalize have been removed.
[U,iA,iC] = unique(ds(:,idx),'rows');

%l resulting dataset for which each row is unique for the remaining
%dimension (after marginalization)
l = ds(iA,:);
s = size(l,1);
M = cell(1,s);


%For each unique row, for each dimension we iteratively remove the rows
%having more than delta*row distnace on this dimension. In the resulting
%dataset we will only have rows distant less than delta the unique row. The
%resulting probability for the given unique row will be the one of the
%resulting set
for i = 1:s
    R = l(i,:);
    dt = ds;
    d = 1;
    while d < p
        %if d is one of the dimension on which we have to marginalize
        %nothing is done
        if size(find(dimension == d),2) ~= 0
            d = d+1;
        %else we look for similar rows having this dimension at delta
        %distance of this dimension of the unique row we are studyin and
        % keep only these rows
        else
            t = abs(dt(:,d) - R(d));
            I = find(t <= abs(R(d))*delta);
            dt = dt(I,:);
            d = d+1;
        end
    end
    M{i} = cell(1,2);
    M{i}{1} = R;
    M{i}{2} = dt;
end

%Number of dimension left + probability
h = size(idx,2)+1;

ds_m = zeros(s,h);
for i = 1:s
    %The probability of the given unique row on the remaining dimension is
    %the sum of the probability of the rows distant of delta 
    pr = sum(M{i}{2}(:,p+1));
    ds_m(i,:) = [M{i}{1}(idx),pr];
end

