function [] = run_pc_kpc(ds,outputdir,listalphas,flagkpc)
%This function runs the pc algorithm on the dataset ds and store the results in the outputdir. The PC algorithm is tested for different value of alphas (listalphas)
%inputs
%	ds = n*p dataset consisting in n samples of p observations
%	outputdir = string representing the full paht to the directory where to store results
%	listalphas = vector of the list of alpha values to test
%	flagkpc[optional] = if set to 1 run the kpc also

if nargin == 3
	flagkpc = 0;
end

n = size(ds,1);
p = size(ds,2);

[success,m,mid] = mkdir(outputdir);
if ~success
	error('Impossible to create the directory %s',outputdir)
end

pathpc = strcat(outputdir,'/pc/');
pathkpc = strcat(outputdir,'/kpc/');

[success,m,mid] = mkdir(pathpc);
if ~success
        error('Impossible to create the directory %s',pathpc)
end

if flagkpc
	[success,m,mid] = mkdir(pathkpc);
	if ~success
		error('Impossible to create the directory %s',pathkpc)
	end
end

for j=listalphas
	namepc=strcat(pathpc,'pc_results_alpha_',num2str(j));
	diary(namepc)
	learn_struct_pdag_pc('cond_indep_fisher_z',p,p,corr(ds),n,j)
	diary off
end

if flagkpc
	for j=listalphas
		namekpc=strcat(pathkpc,'kpc_resulsts_shuffles_',num2str(n),'_alpha_',num2str(j));
		diary(namekpc)
		kpc_param(ds,j,1e-3,1e12,n)
		diary off
	end
end
