function [X,header] = createmultidegreesizesets(ds,maxdegree,maxset,labels)
%This function creates the different set of the different degree and size
%Usage
%       [X,header] = createmultidegreesizesets(ds,maxdegree,maxset,labels)

n = size(ds,1);
p = size(ds,2);

listp = 1:p;
listdegree = [-1/2,1/2,1:maxdegree];

%The size of the regressors
sX = 0;
for i = 1:maxset
    sX = sX+nchoosek(p,i);
end

sX = sX*(maxdegree+1);

%The regressors
X = zeros(n,sX);

%The different sets
sets = cell(1,maxset);
for i = 1:maxset
    sets{i} = combnk(listp,i);
end

header = cell(1,sX);

%Build the dataset for regression
index = 0;
for d = 1:size(listdegree,2)
    degree = listdegree(d);
    for s = 1:maxset
        seti = sets{s};
        for k = 1:size(seti,1)
            index = index+1;
            if size(seti(k,:),2) == 1
                X(:,index) = ds(:,seti(k)).^degree;
            else
                X(:,index) = prod(ds(:,seti(k,:))')'.^degree;
            end
            l = strcat('Degree ',num2str(degree),',');
            for i = 1:size(seti(k,:),2)
                l = strcat(l,labels{seti(k,i)});
            end
            header{index} = l;
        end
    end
end