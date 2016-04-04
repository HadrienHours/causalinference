function [Yf,fYf,yfYf,ey_post_inter,support_y_preinter,pdf_Y_preinter_1,pdf_Y_preinter_2,ey_preinter_1,ey_preinter_2] = estimate_intervention_rtt_fw(pathds,dimy,dimx,dimz,dimc,valc1,valc2,npoints,pathres)
%This function estimate the pdf of Y / C = valc1 when intervening on X to
%follow the distribution of X | C = valc2 with {Z,C} verifyin the back door
%criterion for X -> Y
%The formula used is
%   f(Y|C=valc1, do(X ~ X | C = valc2)) = 
%   sum_Z(f(Y | C = valc1,Z = z, X = x)*f(z)*f(X | C = valc2)*f(C = valc2)
%
%Inputs
%   pathds: path to the observations, dataset (header)
%   dimy: dimension of the response variable
%   dimx: dimension of the intervention variable
%   dimz: second dimension of the back door
%   dimc: first dimension of the back door, also used for intervention
%   valc1: value of C to condition on for response var
%   valc2: value of C to condition on for probability of X under
%   intervention
%   npoints: number of equally spaced points to estimate marginals
%   pathres: directory where .mat results will be stored as pre and post
%   intervention files
%Outputs
%   Yf:     post intervention Y values
%   fYf:    post intervention Y pdf
%   yfYf:   post intervention Y.fy
%   ey_postinter: expected value post intervention
%   y : Y values pre intervention
%   fy_c1: pdf Y conditional C = valc1, pre inter
%   fy_c2: pdf Y conditional C = valc2, pre inter
%   ey_preinter1: expected value of Y pre inter, cond C = valc1
%   ey_preinter2: expected value of Y pre inter, cond C = valc2
%example usage:
%   [Yf,fYf,yfYf,ey_post_inter,support_y_preinter,pdf_Y_preinter_1,pdf_Y_preinter_2,ey_preinter_1,ey_preinter_2] = estimate_intervention_rtt_fw('/datas/xlan/hours/Polito/20141009.dir/dataset_dstip_dns_nohttp_nofqdn_akamai_bt2mb_kBps_MB_kb_nbhops_torbin_cleaned_10percent.csv',19,5,4,2,3,1,600,'/datas/xlan/hours/Polito/20141009.dir/interventions/inetrttfw_cond_google.dir/matfiles_results.dir/')

%load parameters and data
if nargin == 0
    ds = csvread('/datas/xlan/hours/Polito/20141009.dir/dataset_dstip_dns_nohttp_nofqdn_akamai_bt2mb_kBps_MB_kb_nbhops_torbin_cleaned_10percent.csv',1,0);
    dimy = 19;%throughput
    dimx = 5;%inetrtt
    dimz = 4;%ts
    dimc = 2;%dns
    val_gg = 3;%google dns
    val_fw = 1;%fastweb dns
    N = 500;
else
    ds = csvread(pathds,1,0);
    val_gg = valc1;
    val_fw = valc2;
    N = npoints;
end

%select subset DNS = google
I_gg = find(ds(:,dimc)==val_gg);

%compute PDF of X, Y and Z conditionally to C = valc1 (DNS = google)
Xc = ds(I_gg,dimx);
Yc = ds(I_gg,dimy);
Zc = ds(I_gg,dimz);
support_x = linspace(min(ds(:,dimx)),max(ds(:,dimx)),N);
support_y = linspace(min(ds(:,dimy)),max(ds(:,dimy)),N);
support_z = linspace(min(ds(:,dimz)),max(ds(:,dimz)),N);
%Updf_x_c = ksdensity(Xc,support_x,'kernel','normal','function','pdf');%f(Y | C = valc1)
cdf_x_c = ksdensity(Xc,support_x,'kernel','normal','function','cdf');
pdf_y_c = ksdensity(Yc,support_y,'kernel','normal','function','pdf');%f(X | C = valc1)
cdf_y_c = ksdensity(Yc,support_y,'kernel','normal','function','cdf');
%Updf_z_c = ksdensity(Zc,support_z,'kernel','normal','function','pdf');%f(Z | C = valc1)
cdf_z_c = ksdensity(Zc,support_z,'kernel','normal','function','cdf');

%Estimate bivariate density f(X,Z |C = valc1)
    %estimate parameters
[rho_1,nu_1] = copulafit('t',[cdf_x_c',cdf_z_c']);
    %create inputs with corresponding matching to translate from one space
    %to another
[CDF_x_c,CDF_z_c] = meshgrid(cdf_x_c,cdf_z_c);
%U[support_CDF_x_c,support_CDF_z_c] = meshgrid(support_x,support_z);
    %estimate copula XZ_c
C_xz_c = copulacdf('t',[CDF_x_c(:),CDF_z_c(:)],rho_1,nu_1);%size N^2

%Estimate density f(Y,X,Z | C=valc1) = f(Y|valc1,X | valc1, Z | valc1)
    %Estimate copula for the bivariate Yc {XcZc} %% Ac variable A condion on C = valc1
        %resize CDF y of size N to match CDF of Xc,Zc of size N^2
CDF_y_c = repmat(cdf_y_c',N,1);%size N^2
[rho,nu] = copulafit('t',[CDF_y_c,C_xz_c]);
    %create the CDF input for Y, repeating N^2 time y1, N^2 times y2.. etc
t1 = cdf_y_c'*ones(1,N^2);
t2 = t1';
CDF_Y_C = t2(:);
CDF_XZ_C = repmat(C_xz_c(:),N,1);%size N^3
    %Creating the support /!\ ndgrid operate the opposite to meshgrid C(:) =
    %[c1;c2;c3;...] B(:) = [b1; b1; b1; b1;...;b2...]; A(:) =
    %[a1;a1;a1;....;a1;.....;a2...]
[C,B,A] = ndgrid(support_z',support_x',support_y');
support_CDF_XZ_C = [B(:),C(:)];
support_CDF_Y_C = A(:);
C_y_xz_c = copulapdf('t',[CDF_Y_C,CDF_XZ_C],rho,nu);

%Estimate cond prob Yc | Xc,Zc 
    %As f_ab=c_ab*f_a*f_b => f_a|b = c_ab*f_a
    %Estimate pdf Yc at the same points from which the CDF was defined in
    %the copula
    t1 = pdf_y_c'*ones(1,N^2);
    t2 = t1';
    PDF_Y_C = t2(:);
    %multiply copula by pdf of Y to obtain cond prob
    PDF_Y_XZ_C = C_y_xz_c .*PDF_Y_C ;
    
%Estimate Z PDF at the same points where cond prob P(Yc|Xc,Zc) was computed.
Z = ds(:,dimz);
pdf_z = ksdensity(Z,support_z,'kernel','normal','function','pdf');
%U[t,support_PDF_z_1] = meshgrid(support_z,support_z);
[t,PDF_z_1] = meshgrid(pdf_z,pdf_z);
clear t;
%Usupport_PDF_z = repmat(support_PDF_z_1(:),N,1);
PDF_z = repmat(PDF_z_1(:),N,1);

%Estimate PDF X cond DNS = Fastweb at the same points where cond prob P(Yc|Xc,Zc) was computed.
I_fw = find(ds(:,dimc)==val_fw);
Xc_f = ds(I_fw,dimx);
pdf_x_c_f = ksdensity(Xc_f,support_x,'kernel','normal','function','pdf');
    %create support matching the support of fy|x,z,c
%U[support_PDF_x_c_f_1,t] = meshgrid(support_x,support_x);
[PDF_x_c_f_1,t] = meshgrid(pdf_x_c_f,pdf_x_c_f);
%Usupport_PDF_x_c_f = repmat(support_PDF_x_c_f_1(:),N,1);
PDF_x_c_f = repmat(PDF_x_c_f_1(:),N,1);
clear t;

%Probability Fastweb
Pr_f = length(find(ds(:,dimc)==val_fw))/length(ds);

%Final probability Pr(Y | C = val_gg)_P( X | do(C = val_fw)) 
    %sum_x sum_z Pr(y | x, z, val_gg)*Pr(z)*Pr( x | val_fw)*Pr(val_fw)
fy_cxz = PDF_Y_XZ_C .* PDF_z .* PDF_x_c_f * Pr_f;
support_fy_cxz = [support_CDF_Y_C,support_CDF_XZ_C];
    %integrate over X and Z
Yf = zeros(N,1);
fYf = zeros(N,1);
mX = min(support_fy_cxz(:,2));
MX = max(support_fy_cxz(:,2));
mZ = min(support_fy_cxz(:,3));
MZ = max(support_fy_cxz(:,3));
    %                                         /N^2 time  \
    %We built the multi dim pdf with support [y1;y1;......;y2.....;y3;...]
for iy = 1:N
    index_l = (iy-1)*N^2+1;
    index_u = iy*N^2;
    Yf(iy) = support_fy_cxz(index_l,1);
    F = TriScatteredInterp(support_fy_cxz(index_l:index_u,2),support_fy_cxz(index_l:index_u,3),fy_cxz(index_l:index_u));
    h = @(a,b) F(a,b);
    fYf(iy) = integral2(h,mX,MX,mZ,MZ);
end


%compare pre intervention post intervention
	%Estimate pre intervention distribution and mean values
Y_preinter_1 = ds(I_gg,dimy);%google
Y_preinter_2 = ds(I_fw,dimy);%fastweb
support_y_preinter = linspace(min(ds(:,dimy)),max(ds(:,dimy)),N);
pdf_Y_preinter_1 = ksdensity(Y_preinter_1,support_y_preinter,'kernel','normal','function','pdf');
pdf_Y_preinter_2 = ksdensity(Y_preinter_2,support_y_preinter,'kernel','normal','function','pdf');
h_y_preinter_1 = @(t) interp1(support_y_preinter,pdf_Y_preinter_1,t,'nearest');
h_y_preinter_2 = @(t) interp1(support_y_preinter,pdf_Y_preinter_2,t,'nearest');
scale_y_preinter_1 = integral(h_y_preinter_1,min(support_y_preinter),max(support_y_preinter));
scale_y_preinter_2 = integral(h_y_preinter_2,min(support_y_preinter),max(support_y_preinter));
	%rescale so that the pdf integrates to 1
pdf_Y_preinter_1 = pdf_Y_preinter_1*1/scale_y_preinter_1;
pdf_Y_preinter_2 = pdf_Y_preinter_2*1/scale_y_preinter_2;
	%estimate the expected value pre intervention
h_yfy_preinter_1 = @(t) interp1(support_y_preinter,pdf_Y_preinter_1.*support_y_preinter,t,'nearest');
h_yfy_preinter_2 = @(t) interp1(support_y_preinter,pdf_Y_preinter_2.*support_y_preinter,t,'nearest');
ey_preinter_1 = integral(h_yfy_preinter_1,min(support_y_preinter),max(support_y_preinter));
ey_preinter_2 = integral(h_yfy_preinter_2,min(support_y_preinter),max(support_y_preinter));

	%estiamte post intervention distribution and expected value
h_postinter = @(t) interp1(Yf,fYf,t,'nearest');
scale_y_postinter = integral(h_postinter,min(Yf),max(Yf));
fYf = fYf*1/scale_y_postinter;
h_yfy_postinter = @(t) interp1(Yf,fYf.*Yf,t);
ey_post_inter = integral(h_yfy_postinter,min(Yf),max(Yf));
yfYf = Yf.*fYf;

%save results
if ~exist('pathres','var')
   pathres = pwd; 
end
pathres_preinter = strcat(pathres,'/results_intervention_dim_',num2str(dimx),'_cond_',num2str(dimc),'_',num2str(valc2),'_on_',num2str(dimy),'_cond_',num2str(dimc),'_',num2str(valc1),'_preinter_npoints_',num2str(N),'.mat');
pathres_postinter = strcat(pathres,'/results_intervention_dim_',num2str(dimx),'_cond_',num2str(dimc),'_',num2str(valc2),'_on_',num2str(dimy),'_cond_',num2str(dimc),'_',num2str(valc1),'_postinter_npoints_',num2str(N),'.mat');
save(pathres_preinter,'Y_preinter_1','Y_preinter_2','support_y_preinter','pdf_Y_preinter_1','pdf_Y_preinter_2','h_y_preinter_1','h_y_preinter_2','h_yfy_preinter_1','h_yfy_preinter_2','ey_preinter_1','ey_preinter_2')
save(pathres_postinter,'h_postinter','Yf','fYf','h_yfy_postinter','ey_post_inter')