function [] = preprocess_cmip6_LE(model_name,ssp_name,members,year1,year2,averaging,var)

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

if strcmp(model_name,'access')
    dir = '/glade/campaign/cgd/cas/nmaher/access_lens/';
else
    dir = ['/glade/work/sasanch/ENSOworkshop/',model_name,'_lens/'];
end

save_dir = '/glade/work/rwills/projects_output/ENSO_workshop/';

if ts_to_sst
    save_name = [model_name,'_ts-sst_',num2str(year1),'-',num2str(year2),'_',averaging,'_indices.mat'];
else
    save_name = [model_name,'_',var,'_',num2str(year1),'-',num2str(year2),'_',averaging,'_indices.mat'];
end    

files = get_files([dir,realm,'/',var,'/']);

if strcmp(model_name,'cesm2')
%     if strcmp(var,'tos')
%         var = 'SST';
%     elseif strcmp(var,'psl')
%         var = 'PSL';
%     end
    hist_name = 'HIST';
    ssp_name = 'SSP370';
else
    hist_name = 'historical_';
end

%% Determine Ensemble Size and File Structure

files_hist = select_files(files,hist_name);
files_ssp = select_files(files,ssp_name);

if strcmp(model_name,'canesm5')
    files_hist = select_files(files_hist,'p2f1');
    files_ssp = select_files(files_ssp,'p2f1');
end

% modify based on lon/lat variable names
try
    [lon,lat,field] = get_avg_field_3d(files_hist{1},{'lon','lat',var});
catch
    try
        [lon,lat,field] = get_avg_field_3d(files_hist{1},{'longitude','latitude',var});
    catch
        [lon,lat,field] = get_avg_field_3d(files_hist{1},{'xt_ocean','yt_ocean',var});
    end
end

member_hist = zeros(length(files_hist),1);
member_ssp = zeros(length(files_ssp),1);

if strcmp(model_name,'giss_e21g')
    for i = 1:length(files_hist)
        k1 = strfind(files_hist{i},'_r'); k1 = k1(end);
        k2 = strfind(files_hist{i},'i1');
        member_hist(i) = str2double([files_hist{i}(k1+2:k2-1),files_hist{i}(k2+3),files_hist{i}(k2+5)]);
    end
    
    for i = 1:length(files_ssp)
        k1 = strfind(files_ssp{i},'_r'); k1 = k1(end);
        k2 = strfind(files_ssp{i},'i1');
        member_ssp(i) = str2double([files_ssp{i}(k1+2:k2-1),files_ssp{i}(k2+3),files_ssp{i}(k2+5)]);
    end
    
elseif strcmp(model_name,'cesm2')
    for i = 1:length(files_hist)
        k1 = strfind(files_hist{i},'LE2');
        member_hist(i) = str2double([files_hist{i}(k1+4:k1+7),files_hist{i}(k1+10:k1+11)]);
    end
    
    for i = 1:length(files_ssp)
        k1 = strfind(files_ssp{i},'LE2');
        member_ssp(i) = str2double([files_ssp{i}(k1+4:k1+7),files_ssp{i}(k1+10:k1+11)]);
    end
    
else
    for i = 1:length(files_hist)
        k1 = strfind(files_hist{i},'_r'); k1 = k1(end);
        k2 = strfind(files_hist{i},'i1');
        member_hist(i) = str2double(files_hist{i}(k1+2:k2-1));
    end
    
    for i = 1:length(files_ssp)
        k1 = strfind(files_ssp{i},'_r'); k1 = k1(end);
        k2 = strfind(files_ssp{i},'i1');
        member_ssp(i) = str2double(files_ssp{i}(k1+2:k2-1));
    end
    
end

nfiles_hist = length(find(member_hist==member_hist(1)));
nfiles_ssp = length(find(member_ssp==member_ssp(1)));
ne = length(members);

nfiles = nfiles_hist+nfiles_ssp;

clear files1 files2

for i = 1:ne
    is_hist = (i-1)*nfiles+1:(i-1)*nfiles+nfiles_hist;
    is_ssp = (i-1)*nfiles+nfiles_hist+1:i*nfiles;
    files{is_hist} = files_hist{member_hist==members(i)};
    files{is_ssp} = files_ssp{member_ssp==members(i)};
end

y1(nfiles) = 0;
y2(nfiles) = 0;

% Note, assuming no gap between historical and ssp

js = 1:nfiles; % including all files until there is a need to do otherwise
% needs to be modified if time variable is not days since 01.01.1850
%time = get_avg_field_3d(files_hist{nfiles_hist+1},'time');
time = get_avg_field_3d(files{1},'time');
y0 = floor(time(1)./365)+1850;
time = get_avg_field_3d(files{nfiles},'time');
if strcmp(model_name,'cesm2')
    yend = 2100;
elseif strcmp(model_name,'norcpm1')
    yend = 2029;
else
    yend = floor(time(end)./365)+1850-1;
end

nt = 12*(year2-year1+1);
ncut0 = 12*(year1-y0);
ncutend = 12*(yend-year2);

%% 

X_all = [];
Xtot_all = [];
Xe = 0;

for i = 1:ne
    disp(['Processing Ensemble Member ',num2str(i)])
    is = (i-1)*nfiles+1:i*nfiles;
    is = is(js);
    
    field = concatenate_fields(files(is),var,0);
    field = field(:,:,ncut0+1:end-ncutend);
    
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