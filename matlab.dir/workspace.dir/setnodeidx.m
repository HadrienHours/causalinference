function [nodeidx] = setnodeidx(pathlistindex,nNodes)
%This function automatically assigned an index to a node by reading a file
%containing the list of still available indexes
%Usage
%       nodeidx = setnodeidx(pathlistindex,nNodes)
%           pathlistindex: path to the file containing the list of index,
%           this file is created if not existing yet
%           nNodes: maximum index values, number of machines

if exist(pathlistindex,'file') == 0
    listindex = 2:nNodes';
    csvwrite(pathlistindex,listindex);
    nodeidx = 1;
    return;
elseif exist(pathlistindex,'file') == 2
    %if the file is being written, wait
    pathlistindexlock=strcat(pathlistindex,'_lock');
    while exist(pathlistindexlock,'file') == 2
        rtime = ceil(rand(1)*10);
        fprintf('The file:\t %s \n is being written by another application, waiting for %d s before retry\n',pathlistindexlock,rtime)
        pause(rtime);
    end
    csvwrite(pathlistindexlock,[1]);
    %if the file is empty, no more index
    s = dir(pathlistindex);
    if s.bytes < 2
        fprintf('No more index available\n');
        choice = input('Creating a new list (will start from 0 and erase the given one)?: [Y/N]','s');
        if choice == 'Y'
            delete(pathlistindex);
            listindex = 2:nNodes';
            csvwrite(pathlistindex,listindex);
            delete(pathlistindexlock);
            nodeidx = 1;
            return;
        elseif choice == 'N'
            nodeidx = 0;
            delete(pathlistindexlock);
            return
        else
            error('Wrong input')
        end
    end
    
    %else take the first available index
    listindex = csvread(pathlistindex);
    nodeidx = listindex(1);
    if nodeidx > nNodes
        error('The index is bigger than the maximum number of nodes')
    end
    %erase this index for not being taken by other node
    listindex(1) = [];
    delete(pathlistindex);
    csvwrite(pathlistindex,listindex);
    fprintf('Updated the index list\n')
    %free the lock
    fprintf('Free the lock\n')
    delete(pathlistindexlock);
else
    error('The file %s does not redirect toward non existing or existing file',pahtlistindex)
end