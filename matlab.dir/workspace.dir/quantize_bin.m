function edges = quantize_bin(ds,maxbin,minweight, maxweight,minrange)
%This functions is taking is taking as argument a dataset and outputs the edges of each bin for each dimension for quantizing
% input:
%		ds = n*p dataset consisting of n samples of p paramters
%		maxbin = scalar describing the number of bins we wnat to have for each dimension
%		minweight = scalar describing the minimum of samples in each bin
%		minrange [optional]: Scalar giving the minimum number of different value for quantizing, otherwise keep the values as bins of lenght 1. By default equal tp minweight
%output
%		edges : matrix of p cells containing 1*2 matrices for the sequence of edges of the bin for each dimension

if nargin < 3
	error('Not enough arguments, see help\n');
elseif nargin == 3
	minrange = minweight;
end

n=size(ds,1);
p=size(ds,2);



edges=cell(1,p);

for i = 1:size(ds,2)
	if (size(unique(ds(:,i)),1) < minweight) | (size(unique(ds(:,i))) < minrange) | (size(unique(ds(:,i))) < maxbin)
		u=unique(ds(:,i));
		r = size(u,1);
		edges{i} = zeros(r,3);
		for j = 1:r
			ns = size(find(ds(:,i) == u(j)),1);
			edges{i}(j,:) = [u(j),u(j),ns];
		end
		clear u r
	else
		r = range(ds(:,i));
		binw = r/maxbin;
		bins = [min(ds(:,i)):binw:max(ds(:,i))];
		%Include the maximum in the last bin
		bins(end) = max(ds(:,i));
		s=size(bins,2);
		j=1;
		while j < s
			%If there are not enough samples falling into the bin, merge the bin with the one AFTER 
			if size(find(ds(:,i) >= bins(j) & ds(:,i) < bins(j+1)),1) < minweight
				%check we are not dealing with the last bin
				if j < s-1
					bins(j+1) = [];
					s = s-1;
				%if last bin we keep the number of samples in the last bin unchanged
				else
					j = j+1;
				end
			%If there are too many samples
			elseif size(find(ds(:,i) >= bins(j) & ds(:,i) < bins(j+1)),1) > maxweight
				bins = [bins(1:j),(bins(j+1)+bins(j))/2,bins(j+1:end)];
				s = s+1;
			else
					j = j+1;
			end
		end
		edges{i} = zeros(s-1,3);
		for j = 1:s-1
			if j ~= s-1
				ns = size(find(ds(:,i) >= bins(j) & ds(:,i) < bins(j+1)),1);
			else
				ns = size(find(ds(:,i) >= bins(j) & ds(:,i) <= bins(j+1)),1);
			end
			edges{i}(j,:) = [bins(j),bins(j+1),ns];
		end 
	end
end
