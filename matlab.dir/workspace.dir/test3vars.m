function [stats,aborts] = test3vars(minsize,maxsize,step,loopn,X,flagplot)
%This functions makes 16 tests for both criteria Fisher and hsic and for
%fdifferent sizes testing X <- Z -> Y . 
%The tests are
%linear/nonlinear,normal/nonnormal,samevar/diffvar,noerrorterm/errorterm
% The order is the previously mentionned four parameters with two
% possibilities each as [1 1 1 1],[1 1 1 2],[1 1 2 1], etc...
% For each scenario we test I1: X indep Y (should be false = 0) and I2 X indep Y
% cond Z (should be true 1). For each scenario, each size we return outcome
% from Fisher for I1 and I2 and outcome for HSIC for I1 and I2
%Usage
%       [stats,aborts] = test3vars(minsize,maxsize,step,loopn,X,flagplot)
%           stats given the success rate for each of the 16 test, for each
%           of the size for loopn tests
%           aborts is the number of abortion due to matlab error for each
%           test and size

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
        X3 = -3*X1;
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -3*X1+0.1*randn(i,1);
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -300*X1;
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -300*X1+0.1*randn(i,1);
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -3*sqrt((X1-min(X1)+1));
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -3*sqrt((X1-min(X1)+1))+0.1*randn(i,1);
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -2*sqrt(3*(X1-min(X1)+1));
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -2*sqrt(3*(X1-min(X1)+1))+0.1*randn(i,1);
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -3*X1;
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -3*X1+0.1*randn(i,1);
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -300*X1;
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -300*X1+0.1*randn(i,1);
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -3*sqrt((X1-min(X1)+1));
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -3*sqrt((X1-min(X1)+1))+0.1*randn(i,1);
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -2*sqrt(3*(X1-min(X1)+1));
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
        X3 = -2*sqrt(3*(X1-min(X1)+1))+0.1*randn(i,1);
        sf = cond_indep_fisher_z(2,3,[],corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,1) = stats{counter}(idx,1)+1;
            fprintf('Independence wrongly detected by Fisher between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
        sf = cond_indep_fisher_z(2,3,1,corr([X1 X2 X3]),i,0.05);
        if sf > 0
            stats{counter}(idx,2) = stats{counter}(idx,2)+1;
            fprintf('Independence correclty detected by Fisher between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,[],[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,3) = stats{counter}(idx,3)+1;
                fprintf('Independence wrongly detected by HSIC between X and Y for test %d, size %d, loop %d\n',counter,i,j);
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
            sh = indtestimpl(2,3,1,[X1 X2 X3],0.05);
            if sh > 0
                stats{counter}(idx,4) = stats{counter}(idx,4)+1;
                fprintf('Independence correclty detected by HSIC between X and Y cond Z for test %d, size %d, loop %d\n',counter,i,j);
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













