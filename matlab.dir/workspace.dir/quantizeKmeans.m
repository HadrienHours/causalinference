function [dsq,sf] = quantizeKmeans(ds,N)
%This function takes as input a dataset and quantize it by substituting
%each line by the centroid of the kmeans cluster to which it belongs
%
%Usage
%       [dsq] = quantizeKmeans(ds,N)
%           N is optional, if not given the number of cluster is chosen as
%           the last one (by increasing) for which the sum of the distance
%           of points to their centroids did not decrease

n = size(ds,1);

if nargin == 1
    k = 0;
    D1 = Inf;
    D2 = 1e200;
    
    while D2 < D1
        D1 = D2;
        k = k+1;
        [IDX,C,S] = kmeans(ds,k);
        D2 = sum(S);
    end
    dsq = C;
    sf = S;
else
    S = zeros(1,N);
    IDX = zeros(n,N);
    C = cell(1,N);
    for i=1:N
        flag = 0;
        counter = 0;
        while flag == 0 && counter < 10
            counter = counter+1;
            try
                [idx,c,s]  = kmeans(ds,i);
                flag = 1;
            catch
                fprintf('Error on kmeans for size %d\n',i);
            end
        end
        
        if flag == 0;
            S(i) = NaN;
        end
        
        IDX(:,i) = idx;
        S(i) = sum(s);
        C{i} = c;
    end
    
    [sf,mi] = min(S);
    dsq = C{mi};
    
    I = find(isnan(S));
    for i = 1:size(I,1)
        S(i) = 0;
    end
    
    X = 1:N;
    bar(X,S,1)
end
        