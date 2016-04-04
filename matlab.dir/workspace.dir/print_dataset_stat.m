function [] = print_dataset_stat(ds,labels)
%	print in the latex format, table summarizing the statistics of the dataset
% INPUT: 	ds : 	matrix of p columns and n lines, each column corresponding to one parameter and each line to one sample
%		labels:	cell containing the labels of each paramter	

fprintf('Parameter & Avg & Min & Max & Var & Std & C.V. \\\\\n')

for i = 1:size(ds,2)
	avg = mean(ds(:,i));
	minv = min(ds(:,i));
	maxv = max(ds(:,i));
	varv = var(ds(:,i));
	stdv = std(ds(:,i));
	cv = std(ds(:,i))/mean(ds(:,i));
	fprintf('%s & %2.2g & %2.2g & %2.2g & %2.2g & %2.2g & %2.2g \\\\\n',labels{i},avg,minv,maxv,varv,stdv,cv)
end
