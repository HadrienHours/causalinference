function [xmi,mpi,xpi,marginalspdf,xci,marginalscdf] = multidimdensitykernelcopula(ds,names,listp,filter,N,method,pathout)
% this function computes the multidimensional density corresponding to the multidimensional dataset given in input
% It uses normal kernel to estimate the marginals and copula to estimate the multdimensional density
%INPUTS
%	ds = n*p dataset
%	names = list of parameter names (cell), if empty X1,X2,... are used instead (must be given as [])
%	listp = list of parameters to consider, if empty all parameters are considered (must be given as [])
%	filter = percentage to remove values out of IQR corresponding to this percentage (set to 0 if no filtering)
%	N = size of the output
%	method = the type of copula to use (Gaussian,t,clayton,frank,gumble. The last three only for p = 2
%	pathout [optional] = if given the marginals pdf,cdf and multivariate densities are stored in csvfile at this location
%OUTPUTS
%	xmi : N*p points at which the multivariate density was estimated
%	mpi : multivariate pdf
%	xpi : N*p points at which the marginals pdf were estimated
%	marginalspdf: N*p marginals pdf
%	xci : N*p points at which the marginals cdf were estimated
%	marginalscdf: N*p marginals cdf
%Usage
%	[xmi,mpi,xpi,marginalspdf,xci,marginalscdf] = multidimdensitykernelcopula(ds,names,listp,filter,N,method,pathout)

%Use Maximum Likelihood approximation for t-copula
flag_t = 0;

flag_plot = 0;


n=size(ds,1);
p=size(ds,2);
if nargin == 6
	writeds = 0;
elseif nargin == 7
	writeds = 1;
else
	error('incorrect number of arguments, see help');
end

if isempty(listp)
	listp = 1:p;
end

if isempty(names)
	names = cell(1,p);
	for i = 1:p
		names{i}=strcat('X',num2str(i));
	end
end

if filter ~= 0
	if filter > 1.0 || filter < 0.0
		error('Filter value must be a percentage (]0,1[)');
	else
		dsc = remove_extremes(ds,filter);
	end
else
	dsc = ds;
end

names_red = names(listp);
ds_red = dsc(:,listp);
p = size(listp,2);
marginalspdf = zeros(N,p);
marginalscdf = zeros(N,p);
mpi = zeros(N,1);
xmi = zeros(N,p);
xci = zeros(N,p);
xpi = zeros(N,p);
nplot = ceil(p/2);
%Pdf
for i = 1:p
	[d,x] = ksdensity(ds_red(:,i),'npoints',N);
	marginalspdf(:,i) = d';
	xpi(:,i) = x';
	if writeds
		filen = strcat(pathout,'/density_pdf_normal_kernel_npoints',num2str(N),'_',names_red{i},'.csv');
		csvwrite(filen,[x',d']);
	end
end
if flag_plot > 0
	figure();
	for i = 1:p
		ylab = strcat('f(',names_red{i},')');
		tit = strcat('Pdf estimation of _',names_red{i},'_');
		subplot(nplot,2,i)
		plot(xpi(:,i)',marginalspdf(:,i)','linewidth',2);
		xlabel(names_red{i},'fontsize',14)
		ylabel(ylab,'fontsize',14);
		title(tit,'fontsize',16,'fontweight','bold');
		grid on
		set(gca,'fontsize',12);
	end
	if writeds
		figt = strcat(pathout,'/density_pdf_normal_kernel_npoint_',num2str(N));
		for i = 1:p
			figt = strcat(figt,'_',names_red{i});
		end
		figteps = strcat(figt,'.eps');
		figtjpg = strcat(figt,'.jpg');
		saveas(gcf,figteps);
		saveas(gcf,figtjpg);
	end
end

%cdf
for i = 1:p
	[d,x] = ksdensity(ds_red(:,i),'function','cdf','npoints',N);
	marginalscdf(:,i) = d';
	xci(:,i) = x';
	if writeds
		filen = strcat(pathout,'/density_cdf_normal_kernel_npoints',num2str(N),'_',names_red{i},'.csv');
		csvwrite(filen,[x',d']);
	end
end
if flag_plot > 0
	figure();
	for i = 1:p
		ylab = strcat('F(',names_red{i},')');
		tit = strcat('Cdf estimation of _',names_red{i},'_');
		subplot(nplot,2,i)
		plot(xci(:,i)',marginalscdf(:,i)','linewidth',2);
		xlabel(names_red{i},'fontsize',14)
		ylabel(ylab,'fontsize',14);
		title(tit,'fontsize',16,'fontweight','bold');
		grid on
		set(gca,'fontsize',12);
	end
	if writeds
		figt = strcat(pathout,'/density_cdf_normal_kernel_npoint_',num2str(N));
		for i = 1:p
			figt = strcat(figt,'_',names_red{i});
		end
		figteps = strcat(figt,'.eps');
		figtjpg = strcat(figt,'.jpg');
		saveas(gcf,figteps);
		saveas(gcf,figtjpg);
	end
end

%multidimensionality

if strcmp(method,'Gaussian')
    %Get parameters of the gaussian copula
    RHOHAT_g = copulafit('Gaussian',marginalscdf);
    mpi = copulapdf('Gaussian',marginalscdf,RHOHAT_g);

elseif strcmp(method,'t')
    %Get parameters of the t-copula
    if flag_t
        [rhohat_t,nuhat_t,nuci] = copulafit('t',marginalscdf,'Method','ApproximateML');
    else
        [rhohat_t,nuhat_t,nuci] = copulafit('t',marginalscdf);
    end
    fprintf('The 95%% confidence interval for the degree of freedom parameters estimated in nuhat is:\n')
    nuci
    mpi = copulapdf('t',marginalscdf,rhohat_t,nuhat_t);

elseif strcmp(method,'Clayton') || strcmp(method,'Frank') || strcmp(method,'Gumble')
    if p  ==2
        %Get parameter for an archimede copula
        if strcmp(method,'Clayton')
            [paramhat_c,paramci_c] = copulafit('Clayton',cumulatives);
            fprintf('The 95%% confidence interval in Clayton is:\n')
            paramci_c
            mpi = copulapdf('Clayton',cumulatives,paramhat_c);
        elseif strcmp(method,'Frank')
            [paramhat_f,paramci_f] = copulafit('Frank',cumulatives);
            fprintf('The 95%% confidence interval in Frank is:\n')
            paramci_f
            mpi = copulapdf('Frank',cumulatives,paramhat_f);
        elseif strcmp(method,'Gumble')
            [paramhat_g,paramci_g] = copulafit('Gumble',cumulatives);
            fprintf('The 95%% confidence interval in Gumble is:\n')
            paramci_g
            mpi = copulapdf('Gumble',cumulatives,paramhat_g);
        end
    else
        error('The method chosen only work in 2 dimensions\n')
    end
else
    error('The method chosen has not been recognized. Choose in [Gaussian,t,Clayton,Frank,Gumble]')
end

if writeds
	tit = strcat(pathout,'/multidimensionaldensity_pdf_normal_kernel_',method,'_copula_npoint_',num2str(N));
	for i = 1:p
		tit = strcat(tit,'_',names_red{i});
	end
	tit = strcat(tit,'.csv');
	csvwrite(tit,[xmi,mpi]);
end
xmi = xci;
%[X,Y] = meshgrid(dsmulti_rtt_tput(:,1),ds_multi_rtt_tput(:,2));
%Z = griddata(dsmulti_rtt_tput(:,1),dsmulti_rtt_tput(:,2),dsmulti_rtt_tput(:,3),X,Y);
%surf(X,Y,Z)
