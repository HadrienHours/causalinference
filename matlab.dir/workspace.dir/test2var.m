function [stats] = test2var(sizemin,sizemax,step,X,Y,loopn,plotflag)
%This function computes the percentage of success for testing independence
%between two independent variables. 
%usage
%   [stats] = test2var(sizemin,sizemax,step,X,Y,loopn,plotflag)
%           sizemin,sizemax,step: for the sizes of the datasets
%           X,Y: for generating two non normal independent vars with random
%           resampling
%           loopn: The number of test for a given test and ds size
%           plotflag [optional] : plot every ds if failure of one test and
%           the multiple of 1000 ds size

if nargin == 6
    plotflag = 0;
end

s = size([sizemin:step:sizemax],2);

stats = cell(1,4);
for i = 1:4
    stats{i} = zeros(s,2);
end


%normal same variance
counter=1;
ids = 0;
for i = sizemin:step:sizemax
    ids = ids+1;
    for j = 1:loopn
        X1 = randn(i,1);
        X2 = randn(i,1);
        sf = cond_indep_fisher_z(1,2,[],corr([X1,X2]),i,0.05);
        if sf > 0
            fprintf('Independence correcly detected for test %d with Fisher for size %d loop %d\n',counter,i,j);
            stats{counter}(ids,1) = stats{counter}(ids,1)+1;
        else
            if plotflag > 0
                figure()
                subplot(2,1,1)
                plot(X1,'linewidth',2)
                title('X1','Fontsize',16)
                set(gca,'Fontsize',12)
                subplot(2,1,2)
                plot(X2,'linewidth',2)
                title('X2','Fontsize',16)
                set(gca,'Fontsize',12)
                suptitle(strcat(num2str(i),' samples'))
            end
        end
        sh = indtestimpl(1,2,[],[X1 X2],0.05);
        if sh > 0
            fprintf('Independence correcly detected for test %d with HSIC for size %d loop %d\n',counter,i,j);
            stats{counter}(ids,2) = stats{counter}(ids,2)+1;
        else
           if plotflag > 0
                figure()
                subplot(2,1,1)
                plot(X1,'linewidth',2)
                title('X1','Fontsize',16)
                set(gca,'Fontsize',12)
                subplot(2,1,2)
                plot(X2,'linewidth',2)
                title('X2','Fontsize',16)
                set(gca,'Fontsize',12)
                suptitle(strcat(num2str(i),' samples'))
           end
        end
        if plotflag > 0
            if i == 1000 || i == 2000 || i == 3000
                figure()
                subplot(2,1,1)
                plot(X1,'linewidth',2)
                title('X1','Fontsize',16)
                set(gca,'Fontsize',12)
                subplot(2,1,2)
                plot(X2,'linewidth',2)
                title('X2','Fontsize',16)
                set(gca,'Fontsize',12)
                suptitle(strcat(num2str(i),' samples'))
            end
        end
        clear X1 X2;
    end
    stats{counter}(ids,1) = stats{counter}(ids,1)/loopn;
    stats{counter}(ids,2) = stats{counter}(ids,2)/loopn;
end


%normal different variance
counter=2;
ids = 0;
for i = sizemin:step:sizemax
    ids = ids+1;
    for j = 1:loopn
        X1 = (randn(i,1)*100*randn(1))+50*randn(1);
        X2 = (randn(i,1)*5*randn(1))+2*randn(1);
        sf = cond_indep_fisher_z(1,2,[],corr([X1,X2]),i,0.05);
        if sf > 0
            fprintf('Independence correcly detected for test %d with Fisher for size %d loop %d\n',counter,i,j);
            stats{counter}(ids,1) = stats{counter}(ids,1)+1;
        else
            if plotflag > 0
                figure()
                subplot(2,1,1)
                plot(X1,'linewidth',2)
                title('X1','Fontsize',16)
                set(gca,'Fontsize',12)
                subplot(2,1,2)
                plot(X2,'linewidth',2)
                title('X2','Fontsize',16)
                set(gca,'Fontsize',12)
                suptitle(strcat(num2str(i),' samples'))
            end
        end
        sh = indtestimpl(1,2,[],[X1 X2],0.05);
        if sh > 0
            fprintf('Independence correcly detected for test %d with HSIC for size %d loop %d\n',counter,i,j);
            stats{counter}(ids,2) = stats{counter}(ids,2)+1;
        else
           if plotflag > 0
                figure()
                subplot(2,1,1)
                plot(X1,'linewidth',2)
                title('X1','Fontsize',16)
                set(gca,'Fontsize',12)
                subplot(2,1,2)
                plot(X2,'linewidth',2)
                title('X2','Fontsize',16)
                set(gca,'Fontsize',12)
                suptitle(strcat(num2str(i),' samples'))
           end
        end
        if plotflag > 0
            if i == 1000 || i == 2000 || i == 3000
                figure()
                subplot(2,1,1)
                plot(X1,'linewidth',2)
                title('X1','Fontsize',16)
                set(gca,'Fontsize',12)
                subplot(2,1,2)
                plot(X2,'linewidth',2)
                title('X2','Fontsize',16)
                set(gca,'Fontsize',12)
                suptitle(strcat(num2str(i),' samples'))
            end
        end
        clear X1 X2;
    end
    stats{counter}(ids,1) = stats{counter}(ids,1)/loopn;
    stats{counter}(ids,2) = stats{counter}(ids,2)/loopn;
end


%non normal same variance
counter=3;
ids = 0;
for i = sizemin:step:sizemax
    ids = ids+1;
    for j = 1:loopn
        X1 = normalizedataset(random_resampling(X,i));
        X2 = normalizedataset(random_resampling(Y,i));
        sf = cond_indep_fisher_z(1,2,[],corr([X1,X2]),i,0.05);
        if sf > 0
            fprintf('Independence correcly detected for test %d with Fisher for size %d loop %d\n',counter,i,j);
            stats{counter}(ids,1) = stats{counter}(ids,1)+1;
        else
            if plotflag > 0
                figure()
                subplot(2,1,1)
                plot(X1,'linewidth',2)
                title('X1','Fontsize',16)
                set(gca,'Fontsize',12)
                subplot(2,1,2)
                plot(X2,'linewidth',2)
                title('X2','Fontsize',16)
                set(gca,'Fontsize',12)
                suptitle(strcat(num2str(i),' samples'))
            end
        end
        sh = indtestimpl(1,2,[],[X1 X2],0.05);
        if sh > 0
            fprintf('Independence correcly detected for test %d with HSIC for size %d loop %d\n',counter,i,j);
            stats{counter}(ids,2) = stats{counter}(ids,2)+1;
        else
           if plotflag > 0
                figure()
                subplot(2,1,1)
                plot(X1,'linewidth',2)
                title('X1','Fontsize',16)
                set(gca,'Fontsize',12)
                subplot(2,1,2)
                plot(X2,'linewidth',2)
                title('X2','Fontsize',16)
                set(gca,'Fontsize',12)
                suptitle(strcat(num2str(i),' samples'))
           end
        end
        if plotflag > 0
            if i == 1000 || i == 2000 || i == 3000
                figure()
                subplot(2,1,1)
                plot(X1,'linewidth',2)
                title('X1','Fontsize',16)
                set(gca,'Fontsize',12)
                subplot(2,1,2)
                plot(X2,'linewidth',2)
                title('X2','Fontsize',16)
                set(gca,'Fontsize',12)
                suptitle(strcat(num2str(i),' samples'))
            end
        end
        clear X1 X2;
    end
    stats{counter}(ids,1) = stats{counter}(ids,1)/loopn;
    stats{counter}(ids,2) = stats{counter}(ids,2)/loopn;
end


%non normal different variance
counter=4;
ids = 0;
for i = sizemin:step:sizemax
    ids = ids+1;
    for j = 1:loopn
        X1 = random_resampling(X,i);
        X2 = random_resampling(Y,i);
        sf = cond_indep_fisher_z(1,2,[],corr([X1,X2]),i,0.05);
        if sf > 0
            fprintf('Independence correcly detected for test %d with Fisher for size %d loop %d\n',counter,i,j);
            stats{counter}(ids,1) = stats{counter}(ids,1)+1;
        else
            if plotflag > 0
                figure()
                subplot(2,1,1)
                plot(X1,'linewidth',2)
                title('X1','Fontsize',16)
                set(gca,'Fontsize',12)
                subplot(2,1,2)
                plot(X2,'linewidth',2)
                title('X2','Fontsize',16)
                set(gca,'Fontsize',12)
                suptitle(strcat(num2str(i),' samples'))
            end
        end
        sh = indtestimpl(1,2,[],[X1 X2],0.05);
        if sh > 0
            fprintf('Independence correcly detected for test %d with HSIC for size %d loop %d\n',counter,i,j);
            stats{counter}(ids,2) = stats{counter}(ids,2)+1;
        else
           if plotflag > 0
                figure()
                subplot(2,1,1)
                plot(X1,'linewidth',2)
                title('X1','Fontsize',16)
                set(gca,'Fontsize',12)
                subplot(2,1,2)
                plot(X2,'linewidth',2)
                title('X2','Fontsize',16)
                set(gca,'Fontsize',12)
                suptitle(strcat(num2str(i),' samples'))
           end
        end
        if plotflag > 0
            if i == 1000 || i == 2000 || i == 3000
                figure()
                subplot(2,1,1)
                plot(X1,'linewidth',2)
                title('X1','Fontsize',16)
                set(gca,'Fontsize',12)
                subplot(2,1,2)
                plot(X2,'linewidth',2)
                title('X2','Fontsize',16)
                set(gca,'Fontsize',12)
                suptitle(strcat(num2str(i),' samples'))
            end
        end
        clear X1 X2;
    end
    stats{counter}(ids,1) = stats{counter}(ids,1)/loopn;
    stats{counter}(ids,2) = stats{counter}(ids,2)/loopn;
end