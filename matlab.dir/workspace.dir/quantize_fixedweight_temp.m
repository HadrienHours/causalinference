function edges = quantize_fixedweight(ds,weight)
%This fucntion discretizes the input by approximating it with interval 
%functions such that the number of samples falling in each interval is 
%the same
%Note that this is not always possible as (i) if not enough unique values 
%then the algorithm takes each unique value as zero length interval 
%(discrete function) (ii) if continuous values we pick each "weight"-th 
%value as bin edge if there are less than "weight" sample for which the 
%value in one dimension is the same the upper bound of the bin can be 
%defined as this value and more than one sample will be 
%excluded by the strict < from the upper bound of the bin
% exple of (ii) with weight = 2
% dim X [x1,x2,x3,x4,x4,x4,x5,x6,...]
% bin1 = x1<=x<x3, bin2 = x3<=x<x4
%bin1 has a proper cardinality of weight (2) but bin2 as a cardinality of 1 
%inputs		ds: n*p matrix representing n samples of p parameters
%		weitgh: scalar representing the number of samples by interval, this
%value is a target value
%output
%		edges: cell containing the sequence of edges for each bin for each 
%dimension and number of samples for each bins

n = size(ds,1);
p = size(ds,2);
edges=cell(1,p);

for i =1:p
	u = unique(ds(:,i));
	su = size(u,1);
	flag = 0;
	%if the number of unique value is too low we just keep the list of values
	%for j=1:size(u,1)
	%	if(size(find(ds(:,i) == u(j)),1) > (size(ds,1)/weight)*5)
	%		fprintf('For dimension %d the  number of value equal to %g is %d, therefore we keep the values as discrete values\n',i,u(j),size(find(ds(:,i)==u(j)),1)) 
	%		flag =1;
	%	end
	%end
	if su < 3*weight
		flag = 1;
	end
	if flag == 0
		l = sort(ds(:,i));
		bins= [l(1)];
		%As we want weight samples by bin and the sample is placed in bin i if >= left  < right, the "<" removes l[weight] from first bin -> +1
		index2 = weight+1;
		while index2 < size(l,1)
			v = find(l == l(index2));
			index2 = max(v);
			bins = [bins;l(index2)];
			index2 = index2+weight;
		end
		fprintf('For dimension %d the size of the number of bins is %d\n',i,size(bins,1))
		%We add the max value to the last bin
		bins(end) = max(ds(:,i));
		s = size(bins,1)-1;
		edges{i} = zeros(s,4);
		for j = 1:s
			if j < s
				I = find(ds(:,i)>= bins(j) & ds(:,i) < bins(j+1));
                binv = mean(ds(I,i));
                ns = size(I,1);
			else
				I = find(ds(:,i)>= bins(j) & ds(:,i) <= bins(j+1));
                binv = mean(ds(I,i));
                ns = size(I,1);
			end
			edges{i}(j,:) = [bins(j),bins(j+1),binv,ns];
		end
	else
		fprintf('Dimension %d is already discrete with size %d\n',i,su)
		edges{i}=zeros(su,4);
		for j = 1:su
			ns = size(find(ds(:,i) == u(j)),1);
			edges{i}(j,:)=[u(j),u(j),ns,u(j)];
		end
	end
end 
