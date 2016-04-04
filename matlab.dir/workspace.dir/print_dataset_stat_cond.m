function [] = print_dataset_stat_cond(ds,labels,idx_1,idx_2)
%	print in the latex format, table summarizing the statistics of the dataset
% INPUT: 	ds : 	matrix of p columns and n lines, each column corresponding to one parameter and each line to one sample
%           labels:	cell containing the labels of each parameter	
%           idx_1 [optional]: index of first subset
%           idx_2 [optional]: index of second subset


if nargin == 2

    fprintf('Parameter & Avg & Min & Max & Var & Std & C.V. \\\\\n')

    for ii = 1:size(ds,2)
        avg = mean(ds(:,ii));
        minv = min(ds(:,ii));
        maxv = max(ds(:,ii));
        varv = var(ds(:,ii));
        stdv = std(ds(:,ii));
        cv = std(ds(:,ii))/mean(ds(:,ii));
        fprintf('%s & %2.2g & %2.2g & %2.2g & %2.2g & %2.2g & %2.2g \\\\\n',labels{ii},avg,minv,maxv,varv,stdv,cv)
    end
elseif nargin == 4
    fprintf('Parameter & Avg & Avg & Min & Min & Max & Max & Var & Var & Std & Std & C.V. & C.V. \\\\\n')
    ds1 = ds(idx_1,:);
    ds2 = ds(idx_2,:);
    for ii = 1:size(ds,2)
        avg1 = mean(ds1(:,ii));
        minv1 = min(ds1(:,ii));
        maxv1 = max(ds1(:,ii));
        varv1 = var(ds1(:,ii));
        stdv1 = std(ds1(:,ii));
        cv1 = std(ds1(:,ii))/mean(ds1(:,ii));
        avg2 = mean(ds2(:,ii));
        minv2 = min(ds2(:,ii));
        maxv2 = max(ds2(:,ii));
        varv2 = var(ds2(:,ii));
        stdv2 = std(ds2(:,ii));
        cv2 = std(ds2(:,ii))/mean(ds2(:,ii));
        fprintf('%s & %2.2g & %2.2g & %2.2g & %2.2g & %2.2g & %2.2g & %2.2g & %2.2g & %2.2g & %2.2g & %2.2g & %2.2g \\\\\n',labels{ii},avg1,avg2,minv1,minv2,maxv1,maxv2,varv1,varv2,stdv1,stdv2,cv1,cv2)
    end
else
    error('Wrong number of inputs. See help')
end