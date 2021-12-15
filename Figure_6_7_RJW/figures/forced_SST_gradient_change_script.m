
models = {'access','canesm2','canesm5','cesm1','cesm2','csiro_mk36','ec-earth3','gfdl_cm3','gfdl_esm2m_v2','gfdl_spear','ipsl_cm6a','miroc6','miroc_esm2l','mpi'};

[sst_east_out,sst_west_out] = hook_plots(models(1:14),1:12);
close all
gradient_clim(:,:,1) = nanmean(sst_east_out(:,1951-1850+1:1980-1850+1,:),2)-nanmean(sst_west_out(:,1951-1850+1:1980-1850+1,:),2);
gradient_clim(:,:,2) = nanmean(sst_east_out(:,2071-1850+1:2100-1850+1,:),2)-nanmean(sst_west_out(:,2071-1850+1:2100-1850+1,:),2);
load('ERSST5_indices_1900_2019.mat')
ersst5_gradient = reshape(ersst5_east-ersst5_west,[12 120]);
ersst5_gradient_clim = mean(ersst5_gradient(:,52:81),2);
gradient_all = sst_east_out-sst_west_out;

s2n = 0; % setting this to zero uses simple ensemble average instead of S2N patterns analysis

varnam = {'tos','tos','tos','ts-sst','tos','tos','tos','ts-sst','tos','tos','tos','tos','tos','tos'};
year1 = [1850 1950 1850 1920 1850 1850 1850 1920 1861 1921 1850 1850 1850 1850];
year2 = [2100 2100 2100 2100 2100 2100 2100 2100 2100 2100 2100 2100 2100 2099];
ne = [10 50 25 40 99 30 73 20 30 30 11 50 10 100];
titles = {'ACCESS-ESM1-5 (10, SSP370)','CanESM2 (50, RCP85)','CanESM5 (25, SSP370)','CESM1-LE (40, RCP85)','CESM2-LE (99, SSP370)', ...
    'CSIRO-Mk36 (30, RCP85)','EC-EARTH3 (73, SSP585)','GFDL-CM3 (20, RCP85)','GFDL-ESM2M (30, RCP85)','GFDL-SPEAR-MED (30, RCP85)', ...
    'IPSL-CM6A-LR (11, SSP370)','MIROC6 (50, SSP585)','MIROC-ES2L (10, SSP585)','MPI-GE (100, RCP85)'};

for i = 1:14%[1:6 8:14] % skip EC-Earth3
    if(s2n==1)
        load([models{i},'_',varnam{i},'_',num2str(year1(i)),'-',num2str(year2(i)),'_monthly_indices.mat'])
        N_FPs = find(s>0.15,1,'last')
        forced_SST_gradient_change(tk,FPs,icol_ret,icol_disc,LON_AXIS,LAT_AXIS,ne(i),N_FPs,year1(i):year2(i),gradient_clim(:,i,1),ersst5_gradient_clim,gradient_clim(:,i,2));
    else
        forced_SST_gradient_change_simple(gradient_all(:,:,i),1850:2100,gradient_clim(:,i,1),ersst5_gradient_clim,gradient_clim(:,i,2));
    end
    title(titles{i})
end

%% EC-Earth3

if(s2n==1)
    load('ec-earth3_tos_1850-2100_monthly_indices.mat')
    N_FPs = find(s>0.15,1,'last')
    gradient = forced_SST_gradient_change(tk,FPs,icol_ret,icol_disc,LON_AXIS,LAT_AXIS,8,N_FPs,1850:2100);
    close
    
    gradient_avg = gradient;
    gradient_avg(:,1:120) = gradient_avg(:,1:120).*8./23;
    gradient_avg(:,121:165) = gradient_avg(:,121:165).*8./73;
    gradient_avg(:,166:251) = gradient_avg(:,166:251).*8./58;
    
    load('ec-earth3_tos_1850-2014_monthly_indices.mat')
    N_FPs = find(s>0.15,1,'last')
    gradient = forced_SST_gradient_change(tk,FPs,icol_ret,icol_disc,LON_AXIS,LAT_AXIS,15,N_FPs,1850:2014);
    close
    
    gradient_avg(:,1:120) = gradient_avg(:,1:120) + gradient(:,1:120).*15./23;
    gradient_avg(:,121:165) = gradient_avg(:,121:165) + gradient(:,121:165).*15./73;
    
    load('ec-earth3_tos_1970-2100_monthly_indices.mat')
    N_FPs = find(s>0.15,1,'last')
    gradient = forced_SST_gradient_change(tk,FPs,icol_ret,icol_disc,LON_AXIS,LAT_AXIS,50,N_FPs,1970:2100);
    close
    
    % re-reference to 1951-1980 (from 1970-1999)
    offset = mean(gradient_avg(:,1970-1850+1:1999-1850+1),2);
    gradient = gradient + offset;
    
    gradient_avg(:,121:165) = gradient_avg(:,121:165) + gradient(:,1:45).*50./73;
    gradient_avg(:,166:251) = gradient_avg(:,166:251) + gradient(:,46:end).*50./58;
    
    figure;
    subplot('position',[0.04 0.2 0.135 0.7])
    plot(gradient_clim(:,7,1),1:12,'k','linewidth',1.5)
    hold on; plot(ersst5_gradient_clim,1:12,'k--','linewidth',1)
    hold on; plot(gradient_clim(:,7,2),1:12,'r','linewidth',1.5)
    set(gca,'ylim',[1 12])
    set(gca,'xgrid','on')
    set(gca,'xlim',[-5.5 -0.5]);
    pretty_figure(600,250,'none','none',-5:1:-1,1:12,16,{'-5','','-3','','-1'},{'','','','','','','','','','','',''});
    hold on; subplot('position',[0.25 0.2 0.7 0.7])
    plot_field_div_replace(1850:2100,1:12,gradient_avg([12 1:11],:)',linspace(-1,1.6,27));
    pretty_figure(600,250,'none','none',1850:50:2100,1:12,16,1850:50:2100,{'Dec','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov'});
    set(gca,'xlim',[1900 2100])
    title('EC-EARTH3 (73, SSP585)')
else
    gradient_avg = gradient_all(:,:,7);
    % already plotted above for simple analysis
end

%% Plot ensemble mean

if(s2n==0)
    forced_SST_gradient_change_simple(nanmean(gradient_all,3),1850:2100,mean(gradient_clim(:,:,1),2),ersst5_gradient_clim,mean(gradient_clim(:,:,2),2));
    title('Multi-Model Mean (Mixed Scenarios)')
end