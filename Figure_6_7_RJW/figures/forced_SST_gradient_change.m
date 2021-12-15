function [gradient] = forced_SST_gradient_change(tk,icol_ret,icol_disc,LON_AXIS,LAT_AXIS,ne,num_FPs,years,FPs,gradient_clim,gradient_obs,gradient_2100)

FPs = insert_cols(FPs,icol_ret,icol_disc);

forced_response = tk(:,1:num_FPs)*FPs(1:num_FPs,:);
forced_response = ensemble_average_timeseries(forced_response,ne);

nlon = length(LON_AXIS); nlat = length(LAT_AXIS); n = size(forced_response,1);
field = reshape(forced_response',[nlon,nlat n]);
gradient = mean_in_a_box(LON_AXIS,LAT_AXIS,field,[-6 6],[210 270]) - mean_in_a_box(LON_AXIS,LAT_AXIS,field,[-6 6],[120 180]);
gradient = reshape(gradient,[12 n/12]);

year0 = years(1);
dy = 1951-year0; % select 1951-1980
try
    gradient = gradient - nanmean(gradient(:,dy+1:dy+30),2);
catch
    disp('EC-Earth3 ensemble members referenced to first 30 years')
    gradient = gradient - nanmean(gradient(:,1:30),2);
end

figure; 
if nargin > 9
    subplot('position',[0.04 0.2 0.135 0.7]) 
    plot(gradient_clim,1:12,'k','linewidth',1.5)
    if nargin > 10
        hold on; plot(gradient_obs,1:12,'k--','linewidth',1)
        if nargin > 11
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