function [res,p] = indtestimpl_norbug(i,j,k,ds,alpha)
%This function is a wrapper of indtest_new to return 1 in independence case 0 otherwise

verbose = 1;

if verbose > 0
    fprintf('HSIC testing independence of %d %d',i,j);
    if ~isempty(k)
        fprintf(' conditionally on %d',k(1));
        r = 2;
        l = size(k,2);
        while r <= l
            fprintf(' and %d',k(r));
            r = r+1;
        end
    end
    fprintf('\n');
end
if isempty(k)
    tic;
	flag=0;
	try
		[p,s] = indtest_new(ds(:,i),ds(:,j),[],[]);
		flag = 1;
	catch err
		if verbose > 0
			fprintf('Failure at testing previously mentionned independence\n');
			err
		end
	end
	if flag == 0
		if verbose > 0
			fprintf('Retesting with normalized dataset\n');
		end
		[p,s] = indtest_new(normalizedataset(ds(:,i)),normalizedataset(ds(:,j)),[],[]);
	end
    ti = toc;
	res = p > alpha;
    if res > 0 && verbose > 0
        fprintf('Independence detected for the previously mentionned parameters\n');
    end
else
    tic;
	flag = 0;
	try
		[p,s] = indtest_new(ds(:,i),ds(:,j),ds(:,k),[]);
		flag = 1;
	catch err
		if verbose > 0
			fprintf('Failure at testing previously mentionned independence\n');
			err
		end
	end
	if flag == 0
		if verbose > 0
			fprintf('Retesting with normalized dataset\n');
		end
		[p,s] = indtest_new(normalizedataset(ds(:,i)),normalizedataset(ds(:,j)),normalizedataset(ds(:,k)),[]);
	end

    ti = toc;
	res = p > alpha;
    if res > 0 && verbose > 0
        fprintf('Independence detected for the previously mentionned parameters\n');
    end
end

if verbose > 0
	fprintf('The test took %g seconds\n' ,ti);
end
