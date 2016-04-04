function [dspadhye,dspadhyel] = watching_tput(pathdataset)
%%ds loading
ds = csvread(path,1,0);
%names= fgetl(fopen('/datas/xlan/hours/blagny/dataset3_from_05182013.dir/aggregates.dir/05172013_07032013_3500_rows_noextremaloss_interloss_stat_to.csv','r'));
%% get variables
tput = ds(:,end);
bulks = ds(:,7);
rtt = ds(:,5);
mss = ds(:,11);
cwin = ds(:,13);
rwin = ds(:,14);
npkts = ds(:,3);
p = bulks./npkts;
%%data cleaning
%loss
p005 = quantile(p,0.05);
p095 = quantile(p,0.95);
Iqp = find(p <= p095 & p >= p005);
tputqp = tput(Iqp);
pqp = p(Iqp);
rttqp = rtt(Iqp);
mssqp = mss(Iqp);
npktsqp = npkts(Iqp);
cwinqp = cwin(Iqp);
rwinqp = rwin(Iqp);
	%opposite
Iqp_n = find(p > p095 | p < p005);
mss1 = mss(Iqp_n);
rtt1 = rtt(Iqp_n);
p1 = p(Iqp_n);
tput1 = tput(Iqp_n);

%tput
tput005 = quantile(tputqp,0.05);
tput095 = quantile(tputqp,0.95);
Itputqpqt = find(tputqp <= tput095 & tputqp >= tput005);
tputqpqt = tputqp(Itputqpqt);
rttqpqt = rttqp(Itputqpqt);
pqpqt = pqp(Itputqpqt);
mssqpqt = mssqp(Itputqpqt);
npktsqpqt = npktsqp(Itputqpqt);
cwinqpqt = cwinqp(Itputqpqt);
rwinqpqt = rwinqp(Itputqpqt);
	%opposite
Itputqpqt_n = find(tputqp > tput095 | tputqp < tput005);
mss2 = mssqp(Itputqpqt_n);
rtt2 = rttqp(Itputqpqt_n);
p2 = pqp(Itputqpqt_n);
tput2 = tputqp(Itputqpqt_n);

%mss
mss005 = quantile(mssqpqt,0.05);
mss095 = quantile(mssqpqt,0.95);
Imssqpqtqm = find(mssqpqt <= mss095 & mssqpqt >= mss005);
tputqpqtqm = tputqpqt(Imssqpqtqm);
rttqpqtqm = rttqpqt(Imssqpqtqm);
pqpqtqm = pqpqt(Imssqpqtqm);
npktsqpqtqm = npktsqpqt(Imssqpqtqm);
cwinqpqtqm = cwinqpqt(Imssqpqtqm);
rwinqpqtqm = rwinqpqt(Imssqpqtqm);
mssqpqtqm = mssqpqt(Imssqpqtqm);
	%opposite
Imssqpqtqm_n = find(mssqpqt > mss095 | mssqpqt < mss005);
mss3 = mssqpqt(Imssqpqtqm_n);
rtt3 = rttqpqt(Imssqpqtqm_n);
p3 = pqpqt(Imssqpqtqm_n);
tput3 = tputqpqt(Imssqpqtqm_n);

%rtt
rtt005 = quantile(rttqpqtqm,0.05);
rtt095 = quantile(rttqpqtqm,0.95);
Irttqpqtqmqr = find(rttqpqtqm <= rtt095 & rttqpqtqm >= rtt005);
tputqpqtqmqr = tputqpqtqm(Irttqpqtqmqr);
rttqpqtqmqr = rttqpqtqm(Irttqpqtqmqr);
pqpqtqmqr = pqpqtqm(Irttqpqtqmqr);
npktsqpqtqmqr = npktsqpqtqm(Irttqpqtqmqr);
cwinqpqtqmqr = cwinqpqtqm(Irttqpqtqmqr);
rwinqpqtqmqr = rwinqpqtqm(Irttqpqtqmqr);
mssqpqtqmqr = mssqpqtqm(Irttqpqtqmqr);
	%opposite
Irttqpqtqmqr_n = find(rttqpqtqm > rtt095 | rttqpqtqm < rtt005);
mss4 = mssqpqtqm(Irttqpqtqmqr_n);
rtt4 = rttqpqtqm(Irttqpqtqmqr_n);
p4 = pqpqtqm(Irttqpqtqmqr_n);
tput4 = tputqpqtqm(Irttqpqtqmqr_n);

%%sorting
[v,idxtptus] = sort(tputqpqtqmqr);
pqpqtqmqrs = pqpqtqmqr(idxtptus);
rttqpqtqmqrs = rttqpqtqmqr(idxtptus);
mssqpqtqmqrs = mssqpqtqmqr(idxtptus);
tputqpqtqmqrs = tputqpqtqmqr(idxtptus);
npktsqpqtqmqrs = npktsqpqtqmqr(idxtptus);
cwinqpqtqmqrs = cwinqpqtqmqr(idxtptus);
rwinqpqtqmqrs = rwinqpqtqmqr(idxtptus);
%computation
tputpadhye = sqrt(3/2)*mssqpqtqmqrs./(rttqpqtqmqrs.*sqrt(2*pqpqtqmqrs));

%cleaning
qpad005 = quantile(tputpadhye,0.05);
qpad095 = quantile(tputpadhye,0.95);
Iqpad = find(tputpadhye <= qpad095 & tputpadhye >= qpad005);
pqpqtqmqrsqy = pqpqtqmqrs(Iqpad);
rttqpqtqmqrsqy = rttqpqtqmqrs(Iqpad);
mssqpqtqmqrsqy = mssqpqtqmqrs(Iqpad);
tputqpqtqmqrsqy = tputqpqtqmqrs(Iqpad);
npktsqpqtqmqrsqy = npktsqpqtqmqrs(Iqpad);
cwinqpqtqmqrsqy = cwinqpqtqmqrs(Iqpad);
rwinqpqtqmqrsqy = rwinqpqtqmqrs(Iqpad);
	%opposite
Iqpad_n = find(tputpadhye > qpad095 | tputpadhye < qpad005);
mss5 = mssqpqtqmqrs(Iqpad_n);
rtt5 = rttqpqtqmqrs(Iqpad_n);
p5 = pqpqtqmqrs(Iqpad_n);
tput5 = tputqpqtqmqrs(Iqpad_n);

mssT=[mss1;mss2;mss3;mss4;mss5;];
rttT=[rtt1;rtt2;rtt3;rtt4;rtt5];
pT=[p1;p2;p3;p4;p5];
tputT=[tput1;tput2;tput3;tput4;tput5];

%sliding window
tputpadhyes = sliding_window(tputpadhye,10);
rwintput = rwinqpqtqmqrs./rttqpqtqmqrs;
rwintputs = sliding_window(rwintput,10);


%%%%%%%%%%%PLOTS%%%%
figure()
plot(tputpadhyes(Iqpad),'b','linewidth',2)
hold on
plot(tputqpqtqmqrs(Iqpad),'r','linewidth',2);
xlabel('Samples in tput increasing order','Fontsize',24);
ylabel('Throughput','Fontsize',24);
title('Padhye formula smoothed','Fontsize',30);
grid on
set(gca,'Fontsize',20)
legend('MSS*sqrt(3/2)/(RTT*sqrt(2*p))','Original Tput');
figure()
plot(tputpadhyes(Iqpad),'b','linewidth',2)
hold on
plot(rwintputs(Iqpad),'r','linewidth',2)
xlabel('Samples in tput increasing order','Fontsize',24);
ylabel('Throughput','Fontsize',24);
title('Receiver window limit','Fontsize',30);
grid on
set(gca,'Fontsize',20)
legend('MSS*sqrt(3/2)/(RTT*sqrt(2*p))','RWinMax/RTT');


%Plotting ratio
mssq = mssqpqtqmqrsqy;
rttq = rttqpqtqmqrsqy;
pq = pqpqtqmqrsqy;
tputq = tputqpqtqmqrsqy;
tputp = mssq*sqrt(3/2)./(rttq.*sqrt(pq*2));
ratiopred = tputp./tputq;
figure();
scatter(pq,rttq,30,ratiopred,'fill')
grid on
colorbar
title('Ratio between tput padhye and tput real as function of RTT and p','fontsize',16)
set(gca,'fontsize',12)
ylabel('RTT (s)','fontsize',16)
xlabel('P (loss event probability)','fontsize',16)
title('Ratio between tput padhye and tput real as function of RTT and p','fontsize',20,'fontweight','bold')
	%inverse
tputp_n = mssT*sqrt(3/2)./(rttT.*sqrt(pT*2));
ratio_n = tputp_n./tputT;
q005 = quantile(ratio_n,0.05);
q095 = quantile(ratio_n,0.95);
Iq = find(ratio_n >= q005 & ratio_n <= q095);
figure();
scatter(pT(Iq),rttT(Iq),30,ratio_n(Iq),'fill');
grid on
colorbar
title('Ratio between tput padhye and tput real as function of RTT and p','fontsize',16)
set(gca,'fontsize',12)
ylabel('RTT (s)','fontsize',16)
xlabel('P (loss event probability)','fontsize',16)
title('Ratio between tput padhye and tput real as function of RTT and p for extrema','fontsize',20,'fontweight','bold')

%%creation dataset:
%dspadhye
dspadhye = [mssqpqtqmqrs,rttqpqtqmqrs,pqpqtqmqrs,tputqpqtqmqrs];
%log dspadhye
dspadhyel = [log(mssqpqtqmqrs+ones(size(tputqpqtqmqrs,1),1)*eps),log(rttqpqtqmqrs+ones(size(tputqpqtqmqrs,1),1)*eps),log(pqpqtqmqrs+ones(size(tputqpqtqmqrs,1),1)*eps),log(tputqpqtqmqrs+ones(size(tputqpqtqmqrs,1),1)*eps)];
