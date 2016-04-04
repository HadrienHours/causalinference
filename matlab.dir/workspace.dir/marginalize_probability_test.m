function ds_m = marginalize_probability_test(ds,dimension,delta)
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

dim = dimension(1);

%We group the rows with same dim value, getting the unique once removing
%column dim
if dim < p
    [U,iA,iC] = unique(ds(:,[1:dim-1,dim+1:p]),'rows');
elseif dim == p
    [U,iA,iC] = unique(ds(:,[1:p-1]),'rows');
else
    error('Dimension out of range')
end

%dataset of unique rows
l = ds(iA,:);
s = size(l,1);
M = cell(1,s);

%For each unique row
for i = 1:s
    R = l(i,:);
    dt = ds;
    d = 1;
    while d < p
        if d == dim
            d = d+1;
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

ds_m = zeros(s,p+1);
for i = 1:s
    pr = sum(M{i}{2}(:,p+1));
    if dim < p 
        ds_m(i,:) = [M{i}{1}([1:dim-1,dim+1:end]),pr];
    else
        ds_m(i,:) = [M{i}{1}(1:p-1),pr];
    end
end

