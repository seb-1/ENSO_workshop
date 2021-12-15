function [] = preprocess_cmip5_LE(model_name,year1,year2,averaging,var)

% load SST, compute tropical Pacific indices and S2N patterns

N_EOFS = 100;

%% Input Ensemble and Variable Information

if strcmp(var,'tos')
    realm = 'Omon';
elseif strcmp(var,'ts') || strcmp(var,'ts-sst')
    realm = 'Amon';
else
    disp('Error: Script only meant for tos and ts')
end

% flag for turning ts into sst
if strcmp(var,'ts-sst')
    ts_to_sst = 1;
    var = 'ts';
else
    ts_to_sst = 0;
end

LON_AXIS = (1.25:2.5:358.75)';
LAT_AXIS = (-88.75:2.5:88.75)';

dir = ['/glade/work/sasanch/ENSOworkshop/',model_name,'_lens/'];

save_dir = '/glade/work/rwills/projects_output/ENSO_workshop/';

if ts_to_sst
    save_name = [model_name,'_ts-sst_',num2str(year1),'-',num2str(year2),'_',averaging,'_indices.mat'];
else
    save_name = [model_name,'_',var,'_',num2str(year1),'-',num2str(year2),'_',averaging,'_indices.mat'];
end    

%% Determine Ensemble Size and File Structure

if strcmp(model_name,'cesm1')
    files = get_files('/glade/scratch/nmaher/cesm1_ts/'); % temporarily in this location
    files = select_files(files,'1920');
else
    files = get_files([dir,realm,'/',var,'/']);
end

if strcmp(model_name,'gfdl_spear')
    files = select_files(files,'historical_SSP585'); % CMIP6 model, but formatted like CMIP5
else
    files = select_files(files,'historical_rcp85');
end

% modify based on lon/lat variable names
try
    [lon,lat,field] = get_avg_field_3d(files{1},{'lon','lat',var});
catch
    try
        [lon,lat,field] = get_avg_field_3d(files{1},{'longitude','latitude',var});
    catch
        [lon,lat,field] = get_avg_field_3d(files{1},{'xt_ocean','yt_ocean',var});
    end
end

member = zeros(length(files),1);

for i = 1:length(files)
    k1 = strfind(files{i},'_r'); k1 = k1(end);
    k2 = strfind(files{i},'i1');
    member(i) = str2double(files{i}(k1+2:k2-1));
end

nfiles = length(find(member==1));
ne = length(files)./nfiles;

y1(nfiles) = 0;
y2(nfiles) = 0;

for j = 1:nfiles
    file = files{j+nfiles}; % using second ensemble member because some models have differences in first ensemble member
    if strcmp(model_name,'gfdl_spear')
        k3 = strfind(file,'f1_');
    else
        k3 = strfind(file,'p1_');
    end
    y1(j) = str2double(file(k3+3:k3+6));
    y2(j) = str2double(file(k3+10:k3+13));
end

% find which files are needed for time period of interest
js = find(y1<=year1,1,'last'):find(y2>=year2,1,'first');
y0 = y1(js(1));
yend = y2(js(end));

nt = 12*(year2-year1+1);
ncut0 = 12*(year1-y0);
ncutend = 12*(yend-year2);

if strcmp(model_name,'cesm1') % models where first ensemble member is a different length
    for j = 1:nfiles
        file = files{j}; % first ensemble member
        k3 = strfind(file,'p1_');
        y1(j) = str2double(file(k3+3:k3+6));
        y2(j) = str2double(file(k3+10:k3+13));
    end
    
    % find which files are needed for time period of interest
    js = find(y1<=year1,1,'last'):find(y2>=year2,1,'first');
    y0 = y1(js(1));
    yend = y2(js(end));
    
    ncut0_1 = 12*(year1-y0);
    ncutend_1 = 12*(yend-year2);
else
    ncut0_1 = ncut0;
    ncutend_1 = ncutend;
end

%% 

X_all = [];
Xtot_all = [];
Xe = 0;

for i = 1:ne
    disp(['Processing Ensemble Member ',num2str(i)])
    is = (i-1)*nfiles+1:i*nfiles;
    is = is(js);
    
    if i == 1
        field = concatenate_fields(files(is),var,0);
        field = field(:,:,ncut0_1+1:end-ncutend_1);
    else
        field = concatenate_fields(files(is),var,0);
        field = field(:,:,ncut0+1:end-ncutend);
    end
    
    if strcmp(var,'tos')
        field(abs(field)>1e10) = nan;
    end
    
    if ts_to_sst==1
        field(field<271.4) = 271.4;
        if i == 1
            [Y,X] = meshgrid(lat,lon);
            X(X>180) = X(X>180)-360;
            land = landmask(Y,X);
            land = repmat(land,[1 1 size(field,3)]);
        end
        field(land) = nan;
    end
            
    months = repmat(1:12,[1 nt/12]);
    years = reshape(repmat(year1:year2,[12 1]),[nt 1])';
    t = year1:year2; t= t';
    switch averaging
        case 'Amean'
            field = monthly_to_seasonal(months,years,field,1:12,3);
        case 'DJF'
            field = monthly_to_seasonal(months,years,field,[12 1 2],3);
            t = t(2:end);
        case 'JJA'
            field = monthly_to_seasonal(months,years,field,6:8,3);
        otherwise
            t = year1:1/12:year2+11/12; t = t'; % monthly
    end
    
    %% interpolate data and compute covariance matrix
    % note, the local version of preprocess_field_interp does not calculate
    % the covariance matrix
    [~,~,xtf,~,Mt,LON_AXIS,LAT_AXIS,AREA_WEIGHTS,icol_ret,icol_disc] = preprocess_field_interp(lon,lat,field,var,'Global',LON_AXIS,LAT_AXIS);
    
    X = insert_cols(xtf,icol_ret,icol_disc);
    M = insert_cols(Mt,icol_ret,icol_disc);
    
    Xe = Xe + X./ne;
    X_all = [X_all; X];

    Xtot = X + repmat(M,[size(xtf,1)/12 1]);
    Xtot_all = [Xtot_all; Xtot];
    
end

sst = reshape(Xtot_all',[length(LON_AXIS) length(LAT_AXIS) size(X_all,1)]);

sst_east = mean_in_a_box(lon,lat,sst,[-5 5],[210 270]);
sst_west = mean_in_a_box(lon,lat,sst,[-5,5],[120 180]);
sst_nino34 = mean_in_a_box(lon,lat,sst,[-5 5],[190 240]);
sst_nino4 = mean_in_a_box(lon,lat,sst,[-5 5],[160 210]);
sst_nino5 = mean_in_a_box(lon,lat,sst,[-5 5],[120 160]);
sst_pacific = mean_in_a_box(lon,lat,sst,[-5 5],[120 280]);

% scale by square root of grid cell area such that covariance is area
% weighted
normvec          = AREA_WEIGHTS' ./ sum(AREA_WEIGHTS);
scale    = sqrt(normvec);

if sum(sum(isnan(X_all(:,icol_ret))))>0
    scale = insert_rows(scale,icol_ret,icol_disc);
    icol_ret = find(~isnan(mean(X_all,1)));
    icol_disc = find(isnan(mean(X_all,1)));
    scale = scale(icol_ret);
end 

[tk, FPs, fingerprints, s, pvar, pcs, EOFs, N, pvar_FPs, s_eofs] = forced_pattern_analysis(X_all(:,icol_ret),Xe(:,icol_ret),N_EOFS,scale);

%%

save([save_dir,save_name],'LON_AXIS','LAT_AXIS','sst_east','sst_west','sst_nino34','sst_nino4','sst_nino5','sst_pacific','tk','FPs','icol_ret','icol_disc','s','pvar')