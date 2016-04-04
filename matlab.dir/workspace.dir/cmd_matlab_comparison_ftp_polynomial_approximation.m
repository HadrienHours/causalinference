figure
plot(dsr(I,2),dsr(I,3),'g','linewidth',2)
grid on
hold on
plot(dsr(I,2),zpoly(I,3),'b','linewidth',2)
hold on
plot(dsr(I,2),dsr(I,3) - zpoly(I,3),'r','linewidth',3)
xlabel('RTT','Fontsize',16)
ylabel('Duration','Fontsize',16)
legend('Real values','Values from regression function','Error = y - y\'')
title('Comparison of the real values and approximation by regression','Fontsize',16,'Fontweight','bold')
set(gca,'Fontsize',16)


I120 = find(dsr(:,2) <= 0.180);
%remove the extreme value of    1.5000e-05 s 
pos = find(dsr(:,2) == 1.5e-05);
I120_pos = find(I120 ~= pos);
I120 = I120(I120_pos);
%Compute squarred difference
Err120 = zeros(size(I120,1),1);
for i=1:size(I120,1)
Err120(i) = (zpoly(I120(i),3) - dsr(I120(i),3))^2;
end
e120 = sqrt(mean(Err120))/range(dsr(I120,3));
fprintf('The Normalized Mean Squarred Error is %f for a number of sample %d\n',e120,size(I120,1))

err = zeros(11,2);
idx=0;
for i=[0.1:0.01:0.2]
idx=idx+1;
I = find(dsr(:,2) <= i);
%remove the extreme value of    1.5000e-05 s 
pos = find(dsr(:,2) == 1.5e-05);
I_pos = find(I ~= pos);
I = I(I_pos);
%Compute squarred difference
Err = zeros(size(I,1),1);
for j=1:size(I,1)
Err(j) = (zpoly(I(j),3) - dsr(I(j),3))^2;
end
err(idx,:) = [i, sqrt(mean(Err))/range(dsr(I,3))];
end
