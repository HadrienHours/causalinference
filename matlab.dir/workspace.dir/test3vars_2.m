function [stats,aborts] = test3vars_2(minsize,maxsize,step,loopn,X,flagplot)
%This function test the configuration X1 -> X2 -> X3 for X1 being normal or
%not, the dependences being linear or not, the difference of variances
%between X2 and X3 being different or not and some additional error terms
%or not (in this reverse order). This gives 16 tests which are operated for
%a list of size and a number of loops. Each time we test X1 indep X3 given
%X2 and X1 not indep of X2 for Fisher (bnt toolbox) and HSIC (KCI Gretton)
% usage
%       [stats,aborts] = test3vars_2(minsize,maxsize,step,loopn,X,flagplot)
%               minsize,maxsize,setp define the list of sizes
%               loopn the number of tests for each conf and size
%               X is a non normal variables from which we will generate X1
%               with random resampling
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
        X2 = 5*X1;
        X3 = -3*X2;
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
        X2 = 5*X1+0.1*randn(i,1);
        X3 = -3*X2+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
        X1 = randn(i,1);
        X2 = 2*X1;
        X3 = -300*X2;
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
        X1 = randn(i,1);
        X2 = 2*X1+0.1*randn(i,1);
        X3 = -300*X2+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end  
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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

%Test 5: normal non linear diff var no error terms
counter = 5;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = randn(i,1);
        X2 = sqrt(5*(X1-min(X1)+1));
        X3 = -3*sqrt((X2-min(X2)+1));
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
        X2 = sqrt(5*(X1-min(X1)+1))+0.1*randn(i,1);
        X3 = -3*sqrt((X2-min(X2)+1))+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
        X1 = randn(i,1);
        X2 = 3*sqrt(500*(X1-min(X1)+1));
        X3 = -2*sqrt(3*(X2-min(X2)+1));
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
        X1 = randn(i,1);
        X2 = 3*sqrt(500*(X1-min(X1)+1))+0.1*randn(i,1);
        X3 = -2*sqrt(3*(X2-min(X2)+1))+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
        X2 = 5*X1;
        X3 = -3*X2;
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end  
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
        X2 = 5*X1+0.1*randn(i,1);
        X3 = -3*X2+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
        X2 = 2*X1;
        X3 = -300*X2;
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
        X2 = 2*X1+0.1*randn(i,1);
        X3 = -300*X2+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end  
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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

%Test 13: normal non linear diff var no error terms
counter = 13;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = random_resampling(X,i);
        X2 = sqrt(5*(X1-min(X1)+1));
        X3 = -3*sqrt((X2-min(X2)+1));
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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

%Test 14: normal non linear diff var error terms
counter = 14;
idx = 0;
for i = minsize:step:maxsize
    idx = idx+1;
    for j = 1:loopn
        X1 = random_resampling(X,i);
        X2 = sqrt(5*(X1-min(X1)+1))+0.1*randn(i,1);
        X3 = -3*sqrt((X2-min(X2)+1))+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
        X2 = 3*sqrt(500*(X1-min(X1)+1));
        X3 = -2*sqrt(3*(X2-min(X2)+1));
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
        X2 = 3*sqrt(500*(X1-min(X1)+1))+0.1*randn(i,1);
        X3 = -2*sqrt(3*(X2-min(X2)+1))+0.1*randn(i,1);
        sf = cond_indep_fisher_z(1,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(1,3,2,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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
                title(strcat('Dataset for Fisher failure X Y cond Z, test ',num2str(counter),' size ',num2str(i)),'Fontsize',16);
                set(gca,'Fontsize',14);
            end
        end  
        try
            sh = indtestimpl(1,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(1,3,2,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Z cond Y for test %d, size %d, loop %d\n',counter,i,j);
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













