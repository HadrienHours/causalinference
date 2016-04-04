function [listindep] = generateindependencelist(p,condsetsize,listindeptestedpath,filename)
%This function generates all the independence to test for a dataset of p
%parameters and a given condsetsize, knowing that previous independences
%were found
%Input
%       p : number of parameters
%       condsetsize: size of the conditional set (>=0)
%       listindeptested: csvfile path, header
%Output
%       listindep: path to csvfile where the independences were listed as
%       x,y,z1,...zn (n = condsetsize)

verbose = 0;

if condsetsize < 0
    error('The condsetsize must be positive or null');
elseif condsetsize > (p-2)
    error('The condsetsize must be smaller than the number of parameters - 2')
end


if condsetsize == 0 
    listindep = nchoosek(1:p,2);

else
    listindeptested = csvread(listindeptestedpath,1,0);
    sr = size(nchoosek(1:(p-2),condsetsize),1);
    nl = nchoosek(1:p,2);
    results = zeros(size(nl,1)*sr,condsetsize+2);
    counter = 0;
    for i = 1:size(nl,1)
        x = nl(i,1);
        y = nl(i,2);
        p1 = find(listindeptested(:,1)==x & listindeptested(:,2) == y);
        p2 = find(listindeptested(:,1)==y & listindeptested(:,2) == x);
        s1 = size(p1,1);
        s2 = size(p2,1);
        if (s1+s2) == 0%Independence not detected yet
            counter = counter+1;
            listindex = 1:p;
            if x > y
                t = x;
                x = y;
                y = t;
            end
            listindex(x)=[];
            listindex(y-1) = [];%x<y
            condlist = nchoosek(listindex,condsetsize);
            if size(condlist,2) ~= condsetsize
                condlist = condlist';
            end
            sc = size(condlist,1);
            %fprintf('Size to fit results is %d*%d size adding x or y is %d*1 size condlist is %d*%d\n',size(results(counter:counter+sc-1,:)),sc,size(condlist))
            results(counter:counter+sc-1,:) = [ones(sc,1)*x,ones(sc,1)*y,condlist];%counter:counter+sc-1 has the size sc
            counter = counter+sc-1;
        else
            %fprintf('Independence %d %d already tested\n',x,y); 
        end
    end
    listindep = results(1:counter,:);
end


headers = cell(1,condsetsize+2);
headers{1} = 'X';
headers{2} = 'Y';
for i = 1:condsetsize
    headers{i+2} = strcat('Z',num2str(i));
end


if length(headers) ~= size(listindep,2)
    error('number of header entries must match the number of columns in the data')
end

%% write the header string to the file

%turn the headers into a single comma seperated string if it is a cell
%array, 
header_string = headers{1};
for i = 2:length(headers)
    header_string = [header_string,',',headers{i}];
end

%write the string to a file
fid = fopen(filename,'w');
%fprintf('The identifier of %s is %d\n',filename,fid);
fprintf(fid,'%s\r\n',header_string);
fclose(fid);

%% write the append the data to the file

%
% Call dlmwrite with a comma as the delimiter
%
dlmwrite(filename, listindep,'-append','delimiter',',');

if verbose > 0
    fprintf('The list of independence with cond set of size %d was created in %s\n',condsetsize,filename);
end