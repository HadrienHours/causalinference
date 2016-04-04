function [] = generateindependences_frompval(filepval,npars,condsetsize,fileout,alpha)

if condsetsize==0
	listindep=nchoosek(2,1:npars);
else
	pvals=csvread(filepval);
	xy = unique(pvals(:,[1 2]),'rows');
	listindep = [];
	listindex = 1:npars;
	for c = 1:size(xy,1)
		x = xy(c,1);
		y = xy(c,2);
		I = find(pvals(:,1)==x & pvals(:,2)==y);
		pm = max(pvals(I,end));
		if pm < alpha
			listindex2 = listindex;
			listindex2(listindex2==x)=[];
			listindex2(listindex2==y)=[];
			condsets=nchoosek(listindex2,condsetsize);
			listindep_t1 = ones(size(condsets,1),1)*[x,y];
			listindep_t = [listindep_t1,condsets];
			listindep = [listindep;listindep_t];
		else
			fprintf('%d and %d were found independent for cond set size of %d (pval %g) so no more independence testing between these two pars\n',x,y,condsetsize-1,pm)
		end
	end
end
csvwrite(fileout,listindep);
