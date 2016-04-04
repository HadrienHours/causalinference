function [] = plotVariableBinWidthHist(Edges,Values,BinWidths)

figure()
hold on
for ii = 1:length(Edges)
    rectangle('Position',[Edges(ii)-BinWidths(ii)/2,0,BinWidths(ii),Values(ii)+eps],'FaceColor','b','EdgeColor','k','linewidth',2)
end

set(gca,'XTick',Edges)
% set(gca,'XTickLabel',num2cell(Edges))
set(gca,'fontsize',24)
set(gca,'ygrid','on')