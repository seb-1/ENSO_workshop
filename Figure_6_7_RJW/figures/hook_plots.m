function [sst_east_out,sst_west_out] = hook_plots(models,season)

% models = {'access','canesm2','canesm5','cesm1','cesm2','csiro','ec-earth3','gfdl_cm3','gfdl_esm2m_v2','gfdl_spear','ipsl_cm6a','miroc6','miroc_esm2l','mpi'}

%% 5 panel
% hook_plots(models([1 12 14]),1:12);
% hook_plots(models([4 10]),1:12);
% hook_plots(models([7 9 11]),1:12);
% hook_plots(models([3 8 13]),1:12);
% hook_plots(models([2 5 6]),1:12);

%% Modifications for 6 panel
% hook_plots(models([3 6]),1:12);
% hook_plots(models([8 13]),1:12);
% hook_plots(models([2 5]),1:12);

%% 4 Panel
% hook_plots(models([3 10 12 13]),1:12);
% hook_plots(models([2 4 14]),1:12);
% hook_plots(models([1 7 9 11]),1:12);
% hook_plots(models([5 6 8]),1:12);

preprocessed_dir = '/Users/rcwills/Documents/Data/projects_output_tmp/ENSO_Workshop/preprocessed_N100/';
files = get_files(preprocessed_dir);

for j = 1:length(models)
    files_model = select_files(files,models{j});
    if length(files_model)==1
        file = files_model{1};
        load(file,'sst_east','sst_west','sst_nino34')
        k = strfind(file,'-');
        k = k(end);
        year1 = str2double(file(k-4:k-1));
        year2 = str2double(file(k+1:k+4));
        years = year1:year2;
        nyr = length(years);
        ne = length(sst_nino34)/(12*nyr);
        
        sst_nino34 = reshape(sst_nino34,[12*nyr ne]);
        nino34_estd = var(sst_nino34,0,2);
        nino34_estd = reshape(nino34_estd,[12 nyr]);
        
        sst_east = reshape(sst_east,[12*nyr ne]);
        sst_west = reshape(sst_west,[12*nyr ne]);
        
        d = year1-1850;
        d_all(j) = d;
        if d>0
            sst_east = [nan*ones(12*d,ne); sst_east];
            sst_west = [nan*ones(12*d,ne); sst_west];
            sst_nino34 = [nan*ones(12*d,ne); sst_nino34];
            nino34_estd = [nan*ones(12,d), nino34_estd];
        end
        dend = 2100-year2;
        if dend>0
            sst_east = [sst_east; nan*ones(12*dend,ne)];
            sst_west = [sst_west; nan*ones(12*dend,ne)];
            sst_nino34 = [sst_nino34; nan*ones(12*dend,ne)];
            nino34_estd = [nino34_estd, nan*ones(12,dend)];
        end
        nyr = 251;
        
        sst_total_east_all = reshape(sst_east,[12 nyr ne]);
        sst_total_west_all = reshape(sst_west,[12 nyr ne]);
        sst_nino34_all = reshape(sst_nino34,[12 nyr ne]);
        
        sst_east = mean(sst_east,2);
        sst_west = mean(sst_west,2);
        sst_east = reshape(sst_east,[12 nyr]);
        sst_west = reshape(sst_west,[12 nyr]);
        
        sst_east_out(:,:,j) = sst_east;
        sst_west_out(:,:,j) = sst_west;
        
        sst_clim_east(:,j) = mean(sst_east(:,d+1:d+50),2);
        sst_east = sst_east - mean(sst_east(:,d+1:d+50),2);
        sst_clim_west(:,j) = mean(sst_west(:,d+1:d+50),2);
        sst_west = sst_west - mean(sst_west(:,d+1:d+50),2);
        
        for i = 1:12
            sst_east_rmean(i,:,j) = rmean(sst_east(i,:),30);
            sst_west_rmean(i,:,j) = rmean(sst_west(i,:),30);
            for k = 1:ne
                sst_east_rmean_all(i,:,k,j) = rmean(sst_total_east_all(i,:,k),30);
                sst_west_rmean_all(i,:,k,j) = rmean(sst_total_west_all(i,:,k),30);
                nino34_std_rmean_all(i,:,k,j) = rstd(sst_nino34_all(i,:,k),30);
            end
            nino34_estd_rmean(i,:,j) = sqrt(rmean(nino34_estd(i,:),30));
        end

    else
        % Exception for EC-Earth3
        files_model = select_files(files,models{j});
        ne_all = 0;
        clear sst_east_all sst_west_all sst_nino34_all
        for n = 1:length(files_model)
            file = files_model{n};
            load(file,'sst_east','sst_west','sst_nino34')
            k = strfind(file,'-');
            k = k(end);
            year1 = str2double(file(k-4:k-1));
            year2 = str2double(file(k+1:k+4));
            years = year1:year2;
            nyr = length(years);
            ne = length(sst_nino34)/(12*nyr);
            
            sst_nino34 = reshape(sst_nino34,[12*nyr ne]);
            sst_east = reshape(sst_east,[12*nyr ne]);
            sst_west = reshape(sst_west,[12*nyr ne]);
            
            d = year1-1850;
            if d>0
                sst_east = [nan*ones(12*d,ne); sst_east];
                sst_west = [nan*ones(12*d,ne); sst_west];
                sst_nino34 = [nan*ones(12*d,ne); sst_nino34];
            end
            dend = 2100-year2;
            if dend>0
                sst_east = [sst_east; nan*ones(12*dend,ne)];
                sst_west = [sst_west; nan*ones(12*dend,ne)];
                sst_nino34 = [sst_nino34; nan*ones(12*dend,ne)];
            end
            
            sst_east_all(:,ne_all+1:ne_all+ne) = sst_east;
            sst_west_all(:,ne_all+1:ne_all+ne) = sst_west;
            sst_nino34_all(:,ne_all+1:ne_all+ne) = sst_nino34;
            
            ne_all = ne_all + ne;
        end
        d_all(j) = 0;
        nyr = 251; 
        
        sst_east_all(sst_east_all==0) = nan;
        sst_west_all(sst_west_all==0) = nan;
        sst_nino34_all(sst_nino34_all==0) = nan;
            
        nino34_estd = nanvar(sst_nino34_all,0,2);
        nino34_estd = reshape(nino34_estd,[12 nyr]);
        sst_nino34_all = reshape(sst_nino34_all,[12 nyr ne_all]);
        
        sst_total_east_all = reshape(sst_east_all,[12 nyr ne_all]);
        sst_total_west_all = reshape(sst_west_all,[12 nyr ne_all]);
        
        sst_east = nanmean(sst_east_all,2);
        sst_west = nanmean(sst_west_all,2);
        sst_east = reshape(sst_east,[12 nyr]);
        sst_west = reshape(sst_west,[12 nyr]);
        
        sst_east_out(:,:,j) = sst_east;
        sst_west_out(:,:,j) = sst_west;
        
        sst_clim_east(:,j) = mean(sst_east(:,1:50),2);
        sst_east = sst_east - mean(sst_east(:,1:50),2);
        sst_clim_west(:,j) = mean(sst_west(:,1:50),2);
        sst_west = sst_west - mean(sst_west(:,1:50),2);
        
        for i = 1:12
            sst_east_rmean(i,:,j) = rmean(sst_east(i,:),30);
            sst_west_rmean(i,:,j) = rmean(sst_west(i,:),30);
            for k = 1:ne_all
                sst_east_rmean_all(i,:,k,j) = rmean(sst_total_east_all(i,:,k),30);
                sst_west_rmean_all(i,:,k,j) = rmean(sst_total_west_all(i,:,k),30);
                nino34_std_rmean_all(i,:,k,j) = rstd(sst_nino34_all(i,:,k),30);
            end
            nino34_estd_rmean(i,:,j) = sqrt(rmean(nino34_estd(i,:),30));
        end
        
    end
end
       
%%

x = squeeze(mean(sst_east_rmean(season,10:15:end,:)-sst_west_rmean(season,10:15:end,:),1));
xc = mean(sst_clim_east(season,:)-sst_clim_west(season,:),1);
y = sqrt(squeeze(mean(nino34_estd_rmean(season,10:15:end,:).^2,1)));

years = 1865:2086;
ctrs = 1860:20:2100;
cmap = parula(13);
cmap = cmap(1:12,:);
shape = {'o','d','^','v','s','>','<','o','d','^','v','s','>','<'};

x1 = squeeze(mean(sst_east_rmean_all(season,10:15:end,:,:)-sst_west_rmean_all(season,10:15:end,:,:),1));
y1 = sqrt(squeeze(mean(nino34_std_rmean_all(season,10:15:end,:,:),1).^2));
y1(y1==0) = nan;

figure;
if length(models)>1
    for i = 1:length(models)
        if d_all(i) == 0
            index = 1;
        else
            index = 1+ceil((d_all(i)-9)/15);
        end
        %color_rescaled = [1-0.7*(1-cmap(index,1)), 1-0.7*(1-cmap(index,2)), 1-0.4*(1-cmap(index,3))];
        scatter(x1(index,:,i),y1(index,:,i),25,cmap(index,:),shape{i},'filled','markerfacealpha',0.6);
        hold on;
        %cmapref = cmap(end,:);
        %color_rescaled = [1-0.9*(1-cmapref(1)), 1-0.9*(1-cmapref(2)), 1-0.9*(1-cmapref(3))];
        scatter(x1(end,:,i),y1(end,:,i),25,cmap(end,:),shape{i},'filled','markerfacealpha',0.6);
        plot_color_coded_scatter(x(:,i)+xc(i),y(:,i),years(10:15:end),ctrs,cmap,shape{i})
        %text(x(end,i)+xc(i),y(end,i),models(i))
    end
else
    if d_all(1) == 0
        index = 1;
    else
        index = 1+ceil((d_all(1)-9)/15);
    end
    %color_rescaled = [1-0.7*(1-cmap(index,1)), 1-0.7*(1-cmap(index,2)), 1-0.4*(1-cmap(index,3))];
    scatter(x1(index,:),y1(index,:),25,cmap(index,:),shape{1},'filled','markerfacealpha',0.6);
    hold on;
    %cmapref = cmap(end,:);
    %color_rescaled = [1-0.9*(1-cmapref(1)), 1-0.9*(1-cmapref(2)), 1-0.9*(1-cmapref(3))];
    scatter(x1(end,:),y1(end,:),25,cmap(end,:),shape{1},'filled','markerfacealpha',0.6);
    plot_color_coded_scatter(x+xc,y,years(10:15:end),ctrs,cmap,shape{1})
end
pretty_figure(500,350,'Mean-State Pacific SST Gradient (°C)','Nino3.4 Standard Deviation (°C)','none','none',16)
hc = colorbar;
colormap(cmap);
set(hc,'ytick',0:1/12:1); set(hc,'yticklabel',1860:20:2100);

set(gca,'xgrid','on'); set(gca,'ygrid','on')
set(gca,'xlim',[-4.5 -1.75]); set(gca,'ylim',[0.5 1.80001])
set(gca,'xtick',-4.5:0.5:-2); set(gca,'ytick',0.6:0.2:1.8)