function [r] = multitest_indep(i,j,k,D,alpha,names)
%This function is a global function deciding on which test to use for
%testing independence of X(i) and X(j) conditionally of (potentially empty)
%set X(k)
%
%multitest_indep(D,i,j,k,alpha)
%
% Inputs
%       D = n*k dataset
%       i = first vector dimension
%       j = second vector dimension
%       k = list of conditional set dimension
%       names = cell containing names of the variables

% names = {'ts','dist_km','nbbytes','nbpkts','rtt','p','interloss','tocount','rwin_avg','duration','tput'};
% names{i}
% names{j}
% names{k}

if nargin == 5
    names = cell(size(D,1),1);
    for w = 1:size(D,2)
        names{w} = strcat('Parameter ',num2str(w));
    end
end

debug = 1;

%Non conditional test
if isempty(k)
    %Test if first dim is discrete
    if isdiscrete(D,i)
        if isdiscrete(D,j)
            if debug > 1
                fprintf('Test discrete for %s and %s\n',names{i},names{j});
            end
            r = test_discrete(D,i,j,[],alpha);%DONE
            if debug > 0
                if r==1
                    fprintf('%s independent of %s\n',names{i},names{j});
                else
                    if debug > 2
                        fprintf('%s dependent of %s\n',names{i},names{j});
                    end
                end
            end
        else
            if debug > 1
                fprintf('Test half discrete for %s and %s\n',names{i},names{j});
            end
            r = test_half_discrete(D,i,j,alpha);%DONE
            if debug > 0
                if r==1
                    fprintf('%s independent of %s\n',names{i},names{j});
                else
                    if debug > 2
                        fprintf('%s dependent of %s\n',names{i},names{j});
                    end
                end
            end
        end
    else
        if isdiscrete(D,j)
            if debug > 1
                fprintf('Test half discrete for %s and %s\n',names{j},names{i});
            end
            r = test_half_discrete(D,j,i,alpha);%DONE
            if debug > 0
                if r == 1
                    fprintf('%s independent of %s\n',names{j},names{i});
                else
                    if debug > 2
                        fprintf('%s dependent of %s\n',names{j},names{i});
                    end
                end
            end
        else
            if debug > 1
                fprintf('Test continuous for %s and %s\n',names{i},names{j});
            end
            r = test_continuous(D,i,j,[],alpha);%DONE
            if debug > 0
                if r == 1
                    fprintf('%s independent of %s\n',names{i},names{j});
                else
                    if debug > 2
                        fprintf('%s dependent of %s\n',names{i},names{j});
                    end
                end
            end
        end
    end
else
    %X is discrete
    if isdiscrete(D,i)
        if isdiscrete(D,j)
            if isdiscrete(D,k) == 1
                if debug > 1
                    fprintf('Test discrete between %s and %s conditionally on',names{i},names{j});
                    names{k}
                end
                
                r = test_discrete(D,i,j,k,alpha);%DONE
                if debug > 0
                    if r == 1
                        fprintf('%s independent of %s conditionally on ',names{i},names{j});
                        names{k}
                    else
                        if debug > 2
                            fprintf('%s dependent of %s conditionally on',names{i},names{j});
                            names{k}
                        end
                    end
                end
            elseif isdiscrete(D,k) == 0
                %test_cont_cont_dis is test_continuous(D,i,j,alpha) for
                %each value of D(k)
                if debug > 1
                    fprintf('Test discrete discrete continuous between %s and %s conditionally on',names{i},names{j});
                    names{k}
                end
                r = test_disc_disc_cont(D,i,j,k,alpha);%DONE
                if debug > 0
                    if r == 1
                        fprintf('%s independent of %s conditionally on',names{i},names{j});
                        names{k}
                    else
                        if debug > 2
                            fprintf('%s dependent of %s conditionally on',names{i},names{j});
                            names{k}
                        end
                    end
                end
            %Case when dim(Z) > 1 and mix between discrete and continous
            else
                Z = discretize_z(D,k,alpha);
                D1 = [D(:,i),D(:,j),Z];
                s = size(Z,2);
                r = test_disc_disc_disc(D1,1,2,[3:3+s-1]);
                if debug > 0
                    if r == 1
                        fprintf('%s is independent of %s conditionally on:',names{i},names{j});
                        names{k}
                    else
                        if debug > 2
                            fprintf('%s is dependent of %s conditionally on:',names{i},names{j});
                            names{k}
                        end
                    end
                end
            end
        else
            if isdiscrete(D,k) == 1
                %k discrete, same as unconditional disc cont for each
                %discrete value of k
                if debug > 1
                    fprintf('Test discrete continous discrete between %s and %s conditionally on',names{i},names{j});
                    names{k}
                end
                r = test_disc_cont_disc(D,i,j,k,alpha);%DONE
                if debug > 0
                    if r == 1
                        fprintf('%s independent of %s conditionally on',names{i},names{j});
                        names{k}
                    else
                        if debug > 2
                            fprintf('%s dependent of %s conditionally on',names{i},names{j});
                            names{k}
                        end
                    end
                end
            elseif isdiscrete(D,k) == 0
                if debug > 1
                    fprintf('Test discrete continous continous between %s and %s conditionally on',names{i},names{j});
                    names{k}
                end
                r = test_disc_cont_cont(D,i,j,k,alpha);%DONE
                if debug > 0
                    if r == 1
                        fprintf('%s independent of %s conditionally on %s\n',names{i},names{j});
                        names{k}
                    else
                        if debug > 2
                            fprintf('%s dependent of %s conditionally on %s\n',names{i},names{j});
                            names{k}
                        end
                    end
                end
            %Case when dim(Z) > 1 and mix between discrete and continous
            else
                Z = discretize_z(D,k,alpha);
                D1 = [D(:,i),D(:,j),Z];
                s = size(Z,2);
                r = test_disc_cont_disc(D1,1,2,[3:3+s-1]);
                if debug > 0
                    if r == 1 
                        fprintf('%s independent of %s conditionally on',names{i},names{j})
                        names{k}
                    else
                        if debug > 2
                            fprintf('%s dependent of %s conditionally on',names{i},names{j})
                            names{k}
                        end
                    end
                end
            end
        end
    %X is continuous
    else
        if isdiscrete(D,j)
            if isdiscrete(D,k) == 1
                %X indep of Y / Z <=> Y indep X / Z
                if debug > 1
                    fprintf('Test discrete continous discrete between %s and %s conditionally on ',names{j},names{i});            
                    names{k};
                end
                r = test_disc_cont_disc(D,j,i,k,alpha); %DONE
                if debug > 0
                    if r == 1
                        fprintf('%s independent of %s conditionally on ',names{j},names{i});
                        names{k};
                    else
                        if debug > 2
                            fprintf('%s dependent of %s conditionally on ',names{j},names{i});
                            names{k};
                        end
                    end
                end
            elseif isdiscrete(D,k) == 0
                if debug > 1
                    fprintf('Test discrete continuous continuous between %s and %s conditionally on ',names{j},names{i});
                    names{k}
                end
                r = test_disc_cont_cont(D,j,i,k,alpha); %DONE
                if debug > 0
                    if r==1
                        fprintf('%s independent of %s conditionally on ',names{j},names{i});
                        names{k}
                    else
                        if debug > 2
                            fprintf('%s dependent of %s conditionally on ',names{j},names{i});
                            names{k}
                        end
                    end
                end
            %Case when dim(Z) > 1 and mix between discrete and continous
            else
            end
        else
            if isdiscrete(D,k)
                if debug > 1
                    fprintf('Test continuous continuous discrete between %s and %s conditionally on ',names{i},names{j});
                    names{k}
                end
                r = test_cont_cont_disc(D,i,j,k,alpha);%DONE
                if debug > 0
                    if r==1
                        fprintf('%s independent of %s conditionally on ',names{j},names{i});
                        names{k}
                    else
                        if debug > 2
                            fprintf('%s dependent of %s conditionally on ',names{j},names{i});
                            names{k}
                        end
                    end
                end
            else
                if debug >  1
                    fprintf('Test continuous between %s and %s conditionally on ',names{i},names{j});
                    names{k}
                end
                r = test_continuous(D,i,j,k,alpha);%DONE
                if debug > 0 
                    if r==1
                        fprintf('%s independent of %s conditionally on ',names{j},names{i});
                        names{k}
                    else
                        if debug > 2
                            fprintf('%s dependent of %s conditionally on ',names{j},names{i});
                            names{k}
                        end
                    end
                end
            end
        end
    end
end