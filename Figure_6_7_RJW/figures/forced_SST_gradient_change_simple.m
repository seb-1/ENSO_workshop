function [gradient] = forced_SST_gradient_change_simple(gradient_input,years,gradient_clim,gradient_obs,gradient_2100)

gradient = nan*ones(size(gradient_input));

year0 = years(1);
dy = 1951-year0; % select 1951-1980
try
    gradient_input = gradient_input - nanmean(gradient_input(:,dy+1:dy+30),2);
catch
    disp('EC-Earth3 ensemble members referenced to first 30 years')
    gradient_input = gradient_input - nanmean(gradient_input(:,1:30),2);
end

for i = 1:12
    gradient(i,3:end-2) = rmean(gradient_input(i,:),5); % 5-year running mean
end

figure; 
if nargin > 2
    subplot('position',[0.04 0.2 0.135 0.7]) 
    plot(gradient_clim,1:12,'k','linewidth',1.5)
    if nargin > 3
        hold on; plot(gradient_obs,1:12,'k--','linewidth',1)
        if nargin > 4
            hold on; plot(gradient_2100,1:12,'r','linewidth',1.5)
        end
    end
    set(gca,'ylim',[1 12])
    set(gca,'xgrid','on')
    set(gca,'xlim',[-5.5 -0.5]);
    pretty_figure(600,250,'none','none',-5:1:-1,1:12,16,{'-5','','-3','','-1'},{'','','','','','','','','','','',''});
    hold on; subplot('position',[0.25 0.2 0.7 0.7])
end
plot_field_div_replace(years,1:12,gradient([12 1:11],:)',linspace(-1,1.6,27));
pretty_figure(600,250,'none','none',1850:50:2100,1:12,16,1850:50:2100,{'Dec','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov'});
set(gca,'xlim',[1900 2100])
set(gca,'color',[0.9 0.9 0.9])