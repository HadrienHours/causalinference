rtt_p_tput = csvread('results_queries_allcnx_blagny_ftp_tcp_reno_rttstd_rttavg_tstat_rtt_intrabase_p_retrscore_tput.csv',1,0);
name_vars = {'rttavg','rttstd','p','retrscore','rtt','tput'};
addpath('/homes/hours/PhD/matlab/kpc/');
Nbins = 100;
X = rtt_p_tput(:,2);
Y = rtt_p_tput(:,3);
%quantize p
[H,E] = hist(Y,Nbins);
%get indexes of rtt for each p bin
index_per_bin_p = cell(1,Nbins);
delta = (E(3)-E(2))/2;
for ii = 2:(Nbins-1)
index_per_bin_p = find(Y >= (E(ii) -delta/2 - eps) & Y <= (E(ii)+delta/2+eps));
end
index_per_bin_p{1} = find(Y <= (E(1)+delta/2+eps));
index_per_bin_p{Nbins} = find(Y >= (E(Nbins)-delta/2-eps));
%compute average RTT per bin
val_rtt_per_bin = zeros(Nbins,1);
for ii = 1:Nbins
val_rtt_per_bin(ii) = mean(X(index_per_bin_p{ii}));
end
%remove bogus values
Inan = find(~isnan(val_rtt_per_bin) & H'>0);
rttstd = val_rtt_per_bin(Inan);
p = E(Inan)';
[v,idx] = sort(rttstd);
%count the number of samples per bin
[Hrtt,Ertt] = hist(X,v);

figure()
plot(sliding_window_2(rttstd(idx),5),sliding_window_2(p(idx),5));
hold on
bar(Ertt,H(Inan)/sum(H(Inan))*max(p))
set(gca,'fontsize',36);
grid on


%name_vars_blagny = {'rttavgc2s','rttavgs2c','rttstdc2s','rttstds2c','p','retrscore','rtt','tput'};
%var_mininet = {'rttavg','rttstd','rtt','retrscore','p','tput'}
vars_mininet = csvread('mininet.dir/output_query_mininet_xtraffic_rtt_std_rtt_avg_loss_p_tput.csv',1,0);
vars_blagny = csvread('blagny.dir/results_queries_rtt_tstat_std_avg_rtt_intrabase_p_retrscore_tput_blagny_ftp_tcp_reno_09112013_11042013.csv',1,0);
vars_mininet_cleaned = remove_extremes(vars_mininet,0.1);
vars_blagny_cleaned = remove_extremes(vars_blagny,0.1);
means_quartiles_cleaned = zeros(4,4);
	%mininet
		% std = f(avg)
X = vars_mininet_cleaned(:,1);
Y = vars_mininet_cleaned(:,2);
IX25 = find(X <= quantile(X,0.25));
IX25_50 = find(X >= quantile(X,0.25) & X <= quantile(X,0.5));
IX50_75 = find(X >= quantile(X,0.5) & X <= quantile(X,0.75));
IX75 = find(X >= quantile(X,0.75));
Y25 = Y(IX25);
Y25_50 = Y(IX25_50);
Y50_75 = Y(IX50_75);
Y75 = Y(IX75);
means_quartiles_cleaned(1,:) = [mean(Y25) mean(Y25_50) mean(Y50_75) mean(Y75)];
group = [repmat({'First quartile'},length(IX25),1);repmat({'Second quartile'},length(IX25_50),1);repmat({'Third quartile'},length(IX50_75),1);repmat({'Fourth quartile'},length(IX75),1)];
figure()
boxplot([Y25;Y25_50;Y50_75;Y75],group);
set(gca,'fontsize',36);
set(gca,'yscale','log');
grid on
		% p = f(std)
X = vars_mininet_cleaned(:,2);
Y = vars_mininet_cleaned(:,5);
IX25 = find(X <= quantile(X,0.25));
IX25_50 = find(X >= quantile(X,0.25) & X <= quantile(X,0.5));
IX50_75 = find(X >= quantile(X,0.5) & X <= quantile(X,0.75));
IX75 = find(X >= quantile(X,0.75));
Y25 = Y(IX25);
Y25_50 = Y(IX25_50);
Y50_75 = Y(IX50_75);
Y75 = Y(IX75);
means_quartiles_cleaned(2,:) = [mean(Y25) mean(Y25_50) mean(Y50_75) mean(Y75)];
group = [repmat({'First quartile'},length(IX25),1);repmat({'Second quartile'},length(IX25_50),1);repmat({'Third quartile'},length(IX50_75),1);repmat({'Fourth quartile'},length(IX75),1)];
figure()
boxplot([Y25;Y25_50;Y50_75;Y75],group);
set(gca,'fontsize',36);
set(gca,'yscale','log');
grid on

	%Blagny
		% std = f(avg)
X = vars_blagny_cleaned(:,2);
Y = vars_blagny_cleaned(:,4);
IX25 = find(X <= quantile(X,0.25));
IX25_50 = find(X >= quantile(X,0.25) & X <= quantile(X,0.5));
IX50_75 = find(X >= quantile(X,0.5) & X <= quantile(X,0.75));
IX75 = find(X >= quantile(X,0.75));
Y25 = Y(IX25);
Y25_50 = Y(IX25_50);
Y50_75 = Y(IX50_75);
Y75 = Y(IX75);
means_quartiles_cleaned(3,:) = [mean(Y25) mean(Y25_50) mean(Y50_75) mean(Y75)];
group = [repmat({'First quartile'},length(IX25),1);repmat({'Second quartile'},length(IX25_50),1);repmat({'Third quartile'},length(IX50_75),1);repmat({'Fourth quartile'},length(IX75),1)];
figure()
boxplot([Y25;Y25_50;Y50_75;Y75],group);
set(gca,'fontsize',36);
set(gca,'yscale','log');
grid on
		% p = f(std)
X = vars_blagny_cleaned(:,4);
Y = vars_blagny_cleaned(:,5);
IX25 = find(X <= quantile(X,0.25));
IX25_50 = find(X >= quantile(X,0.25) & X <= quantile(X,0.5));
IX50_75 = find(X >= quantile(X,0.5) & X <= quantile(X,0.75));
IX75 = find(X >= quantile(X,0.75));
Y25 = Y(IX25);
Y25_50 = Y(IX25_50);
Y50_75 = Y(IX50_75);
Y75 = Y(IX75);
means_quartiles_cleaned(4,:) = [mean(Y25) mean(Y25_50) mean(Y50_75) mean(Y75)];
group = [repmat({'First quartile'},length(IX25),1);repmat({'Second quartile'},length(IX25_50),1);repmat({'Third quartile'},length(IX50_75),1);repmat({'Fourth quartile'},length(IX75),1)];
figure()
boxplot([Y25;Y25_50;Y50_75;Y75],group);
set(gca,'fontsize',36);
set(gca,'yscale','log');
grid on
