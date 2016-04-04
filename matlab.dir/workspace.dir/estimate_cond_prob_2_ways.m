function [X,Y,PDF_Y_X_1,X2,Y2,PDF_Y_X_2p] = estimate_cond_prob_2_ways()

pathds = '/datas/xlan/hours/Polito/20141009.dir/dataset_dstip_dns_nohttp_nofqdn_akamai_bt2mb_kBps_MB_kb_nbhops_torbin_cleaned_10percent.csv';
ds = csvread(pathds,1,0);
dimy = size(ds,2);
dimx = 5;
N = 1000;
objS = 40;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     estimate f_tput/rtt with copulae    %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = ds(:,dimx);
y = ds(:,dimy);
support_x = linspace(min(x),max(x),N);
support_y = linspace(min(y),max(y),N);
    %estimate marginals with normal kernels
cdf_x = ksdensity(x,support_x,'kernel','normal','function','cdf');
cdf_y = ksdensity(y,support_y,'kernel','normal','function','cdf');
pdf_x = ksdensity(x,support_x,'kernel','normal','function','pdf');
pdf_y = ksdensity(y,support_y,'kernel','normal','function','pdf');
    %estimate T-copula
[X,Y] = meshgrid(support_x,support_y);
[CDF_X,CDF_Y] = meshgrid(cdf_x,cdf_y);
[PDF_X,PDF_Y] = meshgrid(pdf_x,pdf_y);
[rho,nu] = copulafit('t',[CDF_X(:),CDF_Y(:)]);
    %estimate f_tput_rtt
PDF_Y_X = copulapdf('t',[CDF_X(:),CDF_Y(:)],rho,nu).*PDF_Y(:);
PDF_Y_X_1 = reshape(PDF_Y_X,N,N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% estimate f_tput/rtt with cond rtt intervals %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Find RTT values and intervals for computing cond pdf
[Hx,Ex,Dx] = findCorrectIntervalsForIntervention(x,objS,N);
PDF_Y_X_2 = zeros(length(Ex),N);
%support_y_x = zeros(length(Ex),N);
support_y_x = repmat(support_y,length(Ex),1);
%compute cond pdf using normal kernels
for ii = 1:length(Ex)
    Is = find(x >= Ex(ii)-Dx(ii)/2 & x <= Ex(ii)+Dx(ii)/2);
    Yx = y(Is);
    %support_y_x(ii,:) = linspace(min(Yx),max(Yx),N);
    PDF_Y_X_2(ii,:) = ksdensity(Yx,support_y_x(ii,:),'kernel','normal','function','pdf');
    hy = @(t) interp1(support_y_x(ii,:),PDF_Y_X_2(ii,:),t,'nearest');
    scale_y_x = integral(hy,min(Yx),max(Yx));
    if scale_y_x ~= 0
        PDF_Y_X_2(ii,:) = PDF_Y_X_2(ii,:)*1/scale_y_x;
    else
        fprintf('No normalization for PDF of Y for X value %g, measure 0\n',Ex(ii));
    end
end
%Estimate f_Y|X
Valx_2 = repmat(Ex,1,N);
Valy_2 = support_y_x;
Valx_2_f = Valx_2(:);
Valy_2_f = Valy_2(:);
PDF_Y_X_2_f = PDF_Y_X_2(:);
[Vs,Is] = sort(Valx_2_f);
%H_y_x = @(t,u) interp2(Valx_2_f(Is),Valy_2_f(Is),PDF_Y_X_2_f(Is),t,u,'nearest');
H_y_x = TriScatteredInterp(Valx_2_f(Is),Valy_2_f(Is),PDF_Y_X_2_f(Is));
[X2,Y2]  = meshgrid(linspace(min(Ex),max(Ex),N),linspace(min(min(support_y_x)),max(max(support_y_x)),N));
%[X2,Y2]  = meshgrid(support_x,support_y);
PDF_Y_X_2p = H_y_x(X2(:),Y2(:));
PDF_Y_X_2_rs = reshape(PDF_Y_X_2p,N,N);


%plot
figure()
surf(X,Y,reshape(PDF_Y_X,N,N))
grid on
set(gca,'fontsize',24)
title('Estimate of the conditional pdf, using T-copula','fontsize',36,'fontweight','bold');

figure()
surf(X2,Y2,reshape(PDF_Y_X_2p,N,N))
grid on
set(gca,'fontsize',24)
title('Estimate of the conditional pdf, using conditional intervals','fontsize',36,'fontweight','bold');

%Compare estimated Tput Values by integrating TPUT*f_TPUT|RTT
    %With copula
    %PDF_Y_X_1 increasing x along the row increasing y along the colum,
    %integrating along the column
EY_x_1 = zeros(1,N);
Val_x_1 = zeros(1,N);
for ii = 1:N
    fyt = PDF_Y_X_1(:,ii);
    hyt = @(t) interp1(Y(:,1),Y(:,1).*fyt,t,'nearest');
    Val_x_1(ii) = X(1,ii);
    EY_x_1(ii) = integral(hyt,min(Y(:,1)),max(Y(:,1)));
end
    %With kernels
EY_x_2 = zeros(1,N);
Val_x_2 = zeros(1,N);
for ii = 1:N
    fyt = PDF_Y_X_2_rs(:,ii);
    hyt = @(t) interp1(Y2(:,1),Y2(:,1).*fyt,t,'nearest');
    Val_x_2(ii) = X2(1,ii);
    EY_x_2(ii) = integral(hyt,min(Y2(:,1)),max(Y2(:,1)));
end

%Plot
figure()
plot(Val_x_1,EY_x_1,'linewidth',2)
hold on
plot(Val_x_2,EY_x_2,'r','linewidth',2)
grid on
set(gca,'fontsize',24)
legend('Expected throughput for a given RTT pdf using copulae','Expected throughput for a given RTT, using kernel and sub intervals')