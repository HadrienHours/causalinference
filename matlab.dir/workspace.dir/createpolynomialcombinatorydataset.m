function [polydataset,header] = createpolynomialcombinatorydataset(ds,mindegree,maxdegree,stepdegree,maxsetsize)
%This functions is creating a combinatorial superset of the input by
%creating sets of size up to maxset size consisting in multiplication of
%powers of the inputs
%
%Usage
%       [polydataset] = createpolynomialcombinatorydataset(ds,mindegree,maxdegree,step,maxsetsize)

if nargin ~= 5
    error('Wrong number of arguments, see help');
end

n = size(ds,1);
p = size(ds,2);


%Create the stock of size 1 set of all possible power of the parameters
listdegree = mindegree:stepdegree:maxdegree;

%No use of constants
i0 = find(listdegree == 0);

if i0 == 1
    listdegree = listdegree([2:end]);
else
    listdegree = listdegree([1:i0-1,i0+1:end]);
end

ld = size(listdegree,2);

ls = ld*p;

stock = zeros(n,ls);
stock_n = cell(1,ls);

% rlist = [];

for i = 1:ld
    %We cannot put value 0 under a denominator or a root
    for j = 1:p
            if listdegree(i) < 0
                if abs(listdegree(i)) >= 1
                    I = find(ds(:,j) == 0);
                    if size(I,1) == 0
                        stock(:,(i-1)*p+j) = ds(:,j).^listdegree(i);
                        stock_n{(i-1)*p+j} = strcat('X',num2str(j),'_',num2str(listdegree(i)));
%                     else
%                         rlist = [rlist,(i-1)*p+j];
                    end
                else
                    I = find(ds(:,j) <= 0);
                    if size(I,1) == 0
                        stock(:,(i-1)*p+j) = ds(:,j).^listdegree(i);
                        stock_n{(i-1)*p+j} = strcat('X',num2str(j),'_',num2str(listdegree(i)));
%                     else
%                         rlist = [rlist,(i-1)*p+j];
                    end
                end
            elseif listdegree(i) < 1
                I = find(ds(:,j) < 0);
                if size(I,1) == 0
                    stock(:,(i-1)*p+j) = ds(:,j).^listdegree(i);
                    stock_n{(i-1)*p+j} = strcat('X',num2str(j),'_',num2str(listdegree(i)));
%                 else
%                     rlist = [rlist,(i-1)*p+j];
                end
            else
                stock(:,(i-1)*p+j) = ds(:,j).^listdegree(i);
                stock_n{(i-1)*p+j} = strcat('X',num2str(j),'_',num2str(listdegree(i)));
            end
    end
end

%Minimize the stock to remove empty cells
ls1 = ls;
i = 1;
while i < ls1
    if size(stock_n{i},1) == 0
        if i == 1
            stock_n = stock_n([2:end]);
            stock = stock(:,[2:end]);
        elseif i < ls1
            stock_n = stock_n([1:i-1,i+1:end]);
            stock = stock([1:i-1,i+1:end]);
        else 
            stock_n = stock_n([1:i-1]);
            stock = stock([1:i-1]);
        end
        ls1 = ls1-1;
    else
        i = i+1;
    end
end

%Create the dataset as all possible combinations of the stock inputs
sds = 0;

ls = ls1;

for s = 1:maxsetsize
    sds = sds + nchoosek(ls,s);
end

fprintf('The size of the output dataset will be %d\n',sds)

polydataset = zeros(n,sds);
header = cell(1,sds);

%header = zeros(sds,maxsetsize);

idx = 0;
for i = 1:maxsetsize
    listcoeff = combnk(1:ls,i);
    lc = size(listcoeff,1);
    for j = 1:lc
        idx = idx + 1;
        polydataset(:,idx) = prod(stock(:,listcoeff(j,:))')';
%         header(idx,1:size(listcoeff(j,:),2)) = listcoeff(j,:);
        header{idx} = stock_n{listcoeff(j,1)};
        if size(listcoeff(j,:),2) > 1
            for k = 2:size(listcoeff(j,:),2)
                header{idx} = strcat(header{idx},',',stock_n{listcoeff(j,k)});
            end
         end
    end
end