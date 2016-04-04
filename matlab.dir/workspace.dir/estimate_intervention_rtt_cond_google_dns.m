function [] = estimate_intervention_rtt_fw(pathds,dimy,dimx,dimz,dimc,valc1,valc2,npoints)

%load parameters and data
if nargin == 0
    ds_polito = csvread('/datas/xlan/hours/Polito/20141009.dir/dataset_dstip_dns_nohttp_nofqdn_akamai_bt2mb_kBps_MB_kb_nbhops_torbin_cleaned_10percent.csv',1,0);
    dimy = 19;%throughput
    dimx = 5;%inetrtt
    dimz = 4;%ts
    dimc = 2;%dns
    val_gg = 3;%google dns
    val_fw = 1;%fastweb dns
    N = 500;
else
    ds_polito = csvread(pathds,1,0);
    val_gg = valc1;
    val_fw = valc2;
    N = npoints
end
%select subset DNS = google
I_gg = find(ds_polito(:,dimc)==val_gg);

%compute PDF of X, Y and Z conditionally to DNS = google
Xc = ds_polito(I_gg,dimx);
Yc = ds_polito(I_gg,dimy);
Zc = ds_polito(I_gg,dimz);
support_x = linspace(min(ds_polito(:,dimx)),max(ds_polito(:,dimx)),N);
support_y = linspace(min(ds_polito(:,dimy)),max(ds_polito(:,dimy)),N);
support_z = linspace(min(ds_polito(:,dimz)),max(ds_polito(:,dimz)),N);
pdf_x_c = ksdensity(Xc,support_x,'kernel','normal','function','pdf');
cdf_x_c = ksdensity(Xc,support_x,'kernel','normal','function','cdf');
pdf_y_c = ksdensity(Yc,support_y,'kernel','normal','function','pdf');
cdf_y_c = ksdensity(Yc,support_y,'kernel','normal','function','cdf');
pdf_z_c = ksdensity(Zc,support_z,'kernel','normal','function','pdf');
cdf_z_c = ksdensity(Zc,support_z,'kernel','normal','function','cdf');

%Estimate bivariate density f_x,z|c
    %estimate parameters
[rho_1,nu_1] = copulafit('t',[cdf_x_c',cdf_z_c']);
    %create inputs with corresponding matching to translate from one space
    %to another
[CDF_x_c,CDF_z_c] = meshgrid(cdf_x_c,cdf_z_c);
[support_CDF_x_c,support_CDF_z_c] = meshgrid(support_x,support_z);
    %estimate copula XZ_c
C_xz_c = copulacdf('t',[CDF_x_c(:),CDF_z_c(:)],rho_1,nu_1);%size N^2


%Estimate copula for the bivariate Yc {XcZc}
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

%Estimate cond prob Yc | Xc,Zc as f_ab=c_ab*f_a*f_b => f_a|b = c_ab*f_a
    %Estimate pdf Yc at the same points from which the CDF was defined in
    %the copula
    t1 = pdf_y_c'*ones(1,N^2);
    t2 = t1';
    PDF_Y_C = t2(:);
    %multiply copula by pdf of Y to obtain cond prob
    PDF_Y_XZ_C = C_y_xz_c .*PDF_Y_C ;
    
%Estimate Z PDF at the same points where cond prob P(Yc|Xc,Zc) was computed.
Z = ds_polito(:,dimz);
pdf_z = ksdensity(Z,support_z,'kernel','normal','function','pdf');
[t,support_PDF_z_1] = meshgrid(support_z,support_z);
[t,PDF_z_1] = meshgrid(pdf_z,pdf_z);
clear t;
support_PDF_z = repmat(support_PDF_z_1(:),N,1);
PDF_z = repmat(PDF_z_1(:),N,1);

%Estimate PDF X cond DNS = Fastweb at the same points where cond prob P(Yc|Xc,Zc) was computed.
I_fw = find(ds_polito(:,dimc)==val_fw);
Xc_f = ds_polito(I_fw,dimx);
pdf_x_c_f = ksdensity(Xc_f,support_x,'kernel','normal','function','pdf');
    %create support matching the support of fy|x,z,c
[support_PDF_x_c_f_1,t] = meshgrid(support_x,support_x);
[PDF_x_c_f_1,t] = meshgrid(pdf_x_c_f,pdf_x_c_f);
support_PDF_x_c_f = repmat(support_PDF_x_c_f_1(:),N,1);
PDF_x_c_f = repmat(PDF_x_c_f_1(:),N,1);
clear t;

%Probability Fastweb
Pr_f = length(find(ds_polito(:,dimc)==val_fw))/length(ds_polito);

%Final probability Pr(Y | C = val_gg)_P( X | do(C = val_fw)) = sum_x sum_z
%Pr(y | x, z, val_gg)*Pr(z)*Pr( x | val_fw)*Pr(val_fw)

fy_cxz = PDF_Y_XZ_C .* PDF_z .* PDF_x_c_f * Pr_f;
support_fy_cxz = [support_CDF_Y_C,support_CDF_XZ_C];


%integrate over X and Z
Yf = zeros(N,1);
fYf = zeros(N,1);
mX = min(support_fy_cxz(:,2));
MX = max(support_fy_cxz(:,2));
mZ = min(support_fy_cxz(:,3));
MZ = max(support_fy_cxz(:,3));
for iy = 1:N
    index_l = (iy-1)*N^2+1;
    index_u = iy*N^2;
    Yf(iy) = support_fy_cxz(index_l,1);
    F = TriScatteredInterp(support_fy_cxz(index_l:index_u,2),support_fy_cxz(index_l:index_u,3),fy_cxz(index_l:index_u));
    h = @(a,b) F(a,b);
%     fyf(iy) = integral2(h,min(support_fy_cxz(index_l:index_u,2)),max(support_fy_cxz(index_l:index_u,2)),min(support_fy_cxz(index_l:index_u,3)),max(support_fy_cxz(index_l:index_u,3)));%
    fYf(iy) = integral2(h,mX,MX,mZ,MZ);%
end


%compare pre intervention post intervention
	%Estimate pre intervention distribution and mean values
Y_preinter_1 = ds_polito(I_gg,dimy);%google
Y_preinter_2 = ds_polito(I_fw,dimy);%fastweb
support_y_preinter = linspace(min(ds_polito(:,dimy)),max(ds_polito(:,dimy)),N);
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


save('results_intervention_rtt_fw_tput_gooogle_stats_preinter.mat','Y_preinter_1','Y_preinter_2','support_y_preinter','pdf_Y_preinter_1','pdf_Y_preinter_2','h_y_preinter_1','h_y_preinter_2','h_yfy_preinter_1','h_yfy_preinter_2','ey_preinter_1','ey_preinter_2')
save('results_intervention_rtt_fw_tput_gooogle_stats_postinter.mat','h_postinter','Yf','fYf','h_yfy_postinter','ey_post_inter')