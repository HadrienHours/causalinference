function [stats,aborts] = test3vars_3(minsize,maxsize,step,loopn,X,Y,flagplot)
%This function test the configuration X -> Z -> Y for X/Y being normal or
%not, the dependences being linear or not, the difference of variances
%between X and Y being different or not and some additional error terms
%or not (in this reverse order). This gives 16 tests which are operated for
%a list of size and a number of loops. Each time we test X indep Y and
%X not indep of Y cond Z for Fisher (bnt toolbox) and HSIC (KCI Gretton)
% usage
%       [stats,aborts] = test3vars_3(minsize,maxsize,step,loopn,X,Y,flagplot)
%               minsize,maxsize,setp define the list of sizes
%               loopn the number of tests for each conf and size
%               X/Y is a non normal variable from which we will generate
%               X/Y with random resampling
%               flagplot: set to 1 plot the dataset for which the
%               independences tested fail
if nargin == 5
    flagplot = 0;
end

s = size([minsize:step:maxsize],2);

stats = cell(1,16);
aborts = cell(1,16);
for i = 1:16
    stats{i} = zeros(s,4);
    aborts{i} = zeros(s,4);
end

%Test1, normal, linear, same variance, no error terms
counter = 1;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    fprintf('Starting test %d for size %d\n',counter,i);
    for j = 1:loopn
        X1 = randn(i,1);
        X2 = randn(i,1);
        X3 = -3*X2 + 5*X1;
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;


%Test2, normal, linear, same variance, error terms
counter = 2;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = randn(i,1);
        X2 = randn(i,1);
        X3 = -3*X2 + 5*X1 +0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;


%Test 3: normal linear diff var no error terms
counter = 3;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = (randn(i,1)*10)+5;
        X2 = (randn(i,1)*100) + 20;
        X3 = -3*X2 + 5*X1;
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;

%Test 4: normal linear diff var error terms
counter = 4;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = (randn(i,1)*10)+5;
        X2 = (randn(i,1)*100) + 20;
        X3 = -3*X2 + 5*X1 + 0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end  
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;

%Test 5: normal non linear same var no error terms
counter = 5;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = randn(i,1);
        X2 = randn(i,1);
        X3 = -3*sqrt((X2+X1-min(X2+X1)+1));
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;

%Test 6: normal non linear diff var error terms
counter = 6;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = randn(i,1);
        X2 = randn(i,1);
        X3 = -3*sqrt((X2+X1-min(X2+X1)+1))+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;


%Test 7: normal non linear diff var no error terms
counter = 7;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = (randn(i,1)*10)+5;
        X2 = (randn(i,1)*100)+20;
        X3 = -3*sqrt((X2+X1-min(X2+X1)+1));
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;

%Test 8: normal non linear diff var error terms
counter = 8;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
       X1 = (randn(i,1)*10)+5;
        X2 = (randn(i,1)*100)+20;
        X3 = -3*sqrt((X2+X1-min(X2+X1)+1))+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;






%%%%%%%%%%%%%%%%%%%%% NON NORMAL CASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Test9, non normal, linear, same variance, no error terms
counter = 9;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = random_resampling(X,i);
        X2 = random_resampling(Y,i);
        X3 = -3*X2 + 5*X1;
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end  
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;


%Test10, normal, linear, same variance, error terms
counter = 10;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = random_resampling(X,i);
        X2 = random_resampling(Y,i);
        X3 = -3*X2 + 5*X1+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;


%Test 11: normal linear diff var no error terms
counter = 11;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = random_resampling(X,i);
        X2 = random_resampling(Y,i);
        X3 = -300*X2+5*X1;
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;

%Test 12: normal linear diff var error terms
counter = 12;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = random_resampling(X,i);
        X2 = random_resampling(Y,i);
        X3 = -300*X2+5*X1+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end  
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;

%Test 13: normal non linear same var no error terms
counter = 13;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = random_resampling(X,i);
        X2 = random_resampling(Y,i);
        X3 = -3*sqrt((X2+X1-min(X2+X1)+1));
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;

%Test 14: normal non linear same var error terms
counter = 14;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = random_resampling(X,i);
        X2 = random_resampling(Y,i);
        X3 = -3*sqrt((X2+X1-min(X2+X1)+1))+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;


%Test 15: normal non linear diff var no error terms
counter = 7;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = random_resampling(X,i);
        X2 = random_resampling(Y,i);
        X3 = -2*sqrt(3*(300*X2+5*X1-min(300*X2+5*X1)+1));
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;

%Test 16: normal non linear diff var error terms
counter = 16;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = random_resampling(X,i);
        X2 = random_resampling(Y,i);
        X3 = -2*sqrt(3*(300*X2+5*X1-min(300*X2+5*X1)+1))+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,2,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence correctly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
        else
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure independence X Y, test ',num2str(counter),', size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        sf = cond_indep_fisher_z(1,2,3,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
            if flagplot > 0
                m = min(min([X1 X2 X3]));
                M = max(max([X1 X2 X3]));
                figure()
                plot(X1,'linewidth',2)
                hold
                plot(X2,'g','linewidth',2)
                plot(X3,'r','linewidth',2)
                legend('Z','X','Y')
                axis([0 i m M])
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end  
        try
            sh = indtestimpl(1,2,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence correclty detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
            else
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,3) = aborts{counter}(idx,3)+1;
        end
        try
            sh = indtestimpl(1,2,3,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
                if flagplot > 0
                    m = min(min([X1 X2 X3]));
                    M = max(max([X1 X2 X3]));
                    figure()
                    plot(X1,'linewidth',2)
                    hold
                    plot(X2,'g','linewidth',2)
                    plot(X3,'r','linewidth',2)
                    legend('Z','X','Y')
                    axis([0 i m M])
                    title(strcat('Dataset for HSIC failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                    set(gca,'Fontsize',14);
                end
            end
        catch
            aborts{counter}(idx,4) = aborts{counter}(idx,4)+1;
        end
        clear X1 X2 X3;
    end
end

stats{counter} = stats{counter} / loopn;













