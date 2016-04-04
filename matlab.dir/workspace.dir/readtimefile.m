function [] = readtimefile(pathfile,header,tdim,format)
%Works only for date in the format 'YYYY-MM-DD HH:MM:SS'

if header == 1
	ds1 = csvread(pathfile,1,0,tdim-1);
	ds2 = csvread(pathfile,1,tdim+1);
	ds = [ds1,ds2];
else
	ds1 = csvread(pathfile,0,0,tdim-1);
	ds2 = csvread(pathfile,0,tdim+1);
	ds = [ds1,ds2];
end

n = size(ds,1);
p = size(ds,2);

%format = 'yyyy-mm-dd HH:MM:SS';
%pathfile = 'ftpblagny102420132ndhopRTT.csv'
%tdim = 1;
timeepoch = zeros(n,1);
fid = fopen(pathfile,'r');
counter = 0;
flag = 0;
for i = 1:n+1
l = fgetl(fid);
if counter == 0 && flag == 0 && header == 1
flag = 1;
else
counter = counter+1;
idx = strfind(l,',');
idx = [0,idx];
ls = l(idx(tdim)+1:idx(tdim+1)-1);%if in dim 1, as we added 0 we take from 1 to previous position before ","
timeepoch(counter) = datenum(ls,format);
end
end
plot(timeepoch,ds)
tm = min(timeepoch);
tM = max(timeepoch);
rt = tM - tm;
c = datestr(tm,'yyyy-mm-dd-HH-MM-SS');
tick_locations = datenum(str2num(c(1:4)),str2num(c(6:7)),str2num(c(9:10)),str2num(c(12:13)),str2num(c(15:16)),str2num(c(18:19)):1:rt)
set(gca,'XTick',tick_locations)
datetick('x','mmm yyyy','keeplimits', 'keepticks')



%timemat = zeros(n,6);
%timemat(counter,1) = ls(1:4);%year
%timemat(counter,2) = ls(6:7);%month
%timemat(counter,3) = ls(9:10);%day
%timemat(counter,4) = ls(12:13);%hour
%timemat(counter,5) = ls(15:16);%minutes
%timemat(counter,6) = ls(18:19);%seconds
