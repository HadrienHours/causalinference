function [res] = cusum(ds,dim,alpha,c,th)
%This function detects anomalies (changes) using cumulative sum
%INPUTS
%	infilepath: 		path to infile (csv)
%	header	: 		flag set to 1 if header present
%	dim	:		dimension to test variations
%	alpha [optional]: 	scalar defining the proportion of new/old value: new = alpha*old + (1-alpha)*present, default = 0.875
%	c [optional]:		scalar representing the proportion of standard deviation in the metric, default = 0.5
%	threshold [optional]:	scalar for testing the anomaly, threshold, default = 30
%OUTPUT
%	res: matrix with the list of values and one additional column with binary values, 1 identifying anomalies

if nargin < 2
	error('Wrong number of arguments, see help');
elseif nargin == 2
	alpha = 0.875;
	c = 0.5;
	th = 30;
elseif nargin == 3
	if alpha == 0
		alpha = 0.875;
	end
	c = 0.5;
	th = 30;
elseif nargin == 4
	if alpha == 0
		alpha = 0.875;
	end
	if c == 0
		c = 0.5;
	end
	th = 30;
elseif nargin == 5
	if alpha == 0
		alpha = 0.875;
	end
	if c == 0
		c = 0.5;
	end
	if th == 0
		th = 30;
	end
elseif nargin > 5
	error('Wrong number of arguments, see help')
end



n = size(ds,1);
p = size(ds,2);

if p > n
	ds = ds';
	t = n;
	n = p;
	p = t;
	clear t;
end

res = zeros(n,p+1);

idx=0;

for i = 1:n
	value1 = ds(i,dim);
	idx = idx+1;
	AD = 0;
	tmp=0;
	L = 0;
	if (idx == 1)
		m = value1;
                var = 0.0;
                CUSUM = 0.0;
                CUSUM_p = CUSUM;
	else
		m_p = alpha * m + (1 - alpha) * value1;
		var_p = alpha * var + (1 - alpha) * ((value1 - m_p)^2);
		L = value1 - (m_p + c * sqrt(var_p));
		CUSUM_p = CUSUM + L;

		if abs(L) > th
			fprintf('Change detected for sample %d with value %d\n',i,value1);
			AD = 1;
			m = value1;
			var = 0;
			CUSUM = 0;
			CUSUM_p = CUSUM;
%			idx = 0;
		else
			m = m_p;
			var = var_p;
			CUSUM = CUSUM_p;
		end
		
	end				
%
%		if (CUSUM_p < 0)
%			CUSUM_p = 0.0;
%		end
%
%		if (CUSUM_p > th)
%			AD = 1;
%	        else 
%			m = m_p;
%			var = var_p;
%			CUSUM = CUSUM_p;
%		end
%	end
	res(i,:) = [ds(i,:),AD];
end
