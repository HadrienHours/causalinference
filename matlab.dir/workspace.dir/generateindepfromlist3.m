function [listindep] = generateindepfromlist3(pathlisttestedindeps,condset,npars,pathout,alpha)
%This function generate the list of independences to test (offline) for
%each step by building, at every step, the skeleton obtained with the
%independences detected so far and build the independences based on the
%still adjacent nodes and their mutual neighbors
%
%Inputs
%   pathlisttestedindeps: path to csvfile containing the independences in
%                         the form: X Y Z1.... Zmax pvalue (with header)
%   condset: size of the conditioning set size for the next bulk of tests
%            to be launched
%   npars: number of parameters
%   pathout: path to csvfile to store the independences in the form:
%            X Y Z1... Zcondset
%   alpha: Significance level to use for testing independences
%
%Output
%   listindep

verbose = 1;

if nargin ~= 5
    error('Not enough arguments, see help')
end

if condset == 0
   listindep = nchoosek(1:npars,2); 
else
    if verbose > 0
        fprintf('Start computing the adjacency matrix\n')
    end
    
    
    G = compute_adjacency_matrix(npars,condset-1,pathlisttestedindeps,alpha);

    if verbose > 0
        fprintf('Finished computing the adjacency matrix\n')
    end
    
    [X,Y] = find(triu(G));

    listindep = [];

    for ii = 1:length(X)
        if verbose > 0
            fprintf('Start generating independences for %d and %d\n',X(ii),Y(ii))
        end
        x = X(ii);
        y = Y(ii);
        nbrs = setdiff(myunion(neighbors(G,x),neighbors(G,y)),[x,y]);
        
        if size(nbrs,2) >= condset
            condlist = nchoosek(nbrs,condset);
            sc = size(condlist,1);
            if verbose > 0
                fprintf('The list of independences is going to increase from %d to %d\n',size(listindep,1),size(listindep,1)+sc);
            end

            try
                additionalindeps = [ones(sc,1)*[x,y],condlist];
                listindep = [listindep; additionalindeps];
            catch
                x
                y    
                condlist
                error('Error while trying to concatenate the additional indeps of size %d x %d to actual listindep of size %d x %d\n',size(additionalindeps),size(listindep));
            end
        else
            fprintf('Could not generate independences of condset size %d to separate %d and %d as the size of their commun neighbors set is %d\n',condset,x,y,size(nbrs,2))
        end
    end
end

headers = cell(1,condset+2);
headers{1} = 'X';
headers{2} = 'Y';
for i = 1:condset
    headers{i+2} = strcat('Z',num2str(i));
end

if size(listindep,1) == 0
    fprintf('No independence to be tested for conditioning set size of %d\n',condset)
elseif length(headers) ~= size(listindep,2)
    error('number of header entries must match the number of columns in the data (%d ~= %d)',length(headers),size(listindep,2))
end

%% write the header string to the file

%turn the headers into a single comma seperated string if it is a cell
%array, 
header_string = headers{1};
for i = 2:length(headers)
    header_string = [header_string,',',headers{i}];
end

%write the string to a file
fid = fopen(pathout,'w');
%fprintf('The identifier of %s is %d\n',filename,fid);
fprintf(fid,'%s\r\n',header_string);
fclose(fid);

%% write the append the data to the file

%
% Call dlmwrite with a comma as the delimiter
%
if size(listindep,1) ~= 0
    dlmwrite(pathout, listindep,'-append','delimiter',',');
end
