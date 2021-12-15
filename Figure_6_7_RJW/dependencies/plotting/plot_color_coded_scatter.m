function [] = plot_color_coded_scatter(x,y,c,ctrs,cmap,shape)

% Scatter plot with a color to show a 3rd dimension with value c

s = length(x);
cs = size(cmap);
% if cs(1) ~= length(ctrs)
%     disp('Warning: incompatible lengths for ctrs and cmap')
% end
ctrs = [-inf ctrs inf];

hold on; plot(x,y,'k-')

for i = 1:s
    hold on;
    ci = find(c(i)>ctrs,1,'last');
    ci = ci - 1;
    ci(ci == 0) = 1;
    ci(ci == cs(1)+1) = cs(1);
    plot(x(i),y(i),shape,'color',cmap(ci,:),'MarkerFaceColor',cmap(ci,:),'markersize',8,'linewidth',2);
    plot(x(i),y(i),shape,'color','k','markersize',8,'linewidth',1);
    %plot(x(i),y(i),'ko','markersize',8,'linewidth',2);
    %plot(x(i),y(i),'o','color',cmap(ci,:),'MarkerFaceColor',cmap(ci,:),'markersize',6,'linewidth',2);
end