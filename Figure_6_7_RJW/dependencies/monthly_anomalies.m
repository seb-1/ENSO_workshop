function [anomalies,mean_seasonal_cycle] = monthly_anomalies(data,nmonths,dim)

if nargin < 3
    dim = 3;
end
if nargin < 2
    nmonths = 12;
end

anomalies = data;

data(data>1e20) = nan;

switch dim
    case 4
        mean_seasonal_cycle = zeros(size(data(:,:,:,1:nmonths)));
        for i = 1:nmonths
            mean_seasonal_cycle(:,:,:,i) = nanmean(data(:,:,:,i:nmonths:end),4);
            anomalies(:,:,:,i:nmonths:end) = anomalies(:,:,:,i:nmonths:end) - mean_seasonal_cycle(:,:,:,i);
        end
    case 3
        mean_seasonal_cycle = zeros(size(data(:,:,1:nmonths)));
        for i = 1:nmonths
            mean_seasonal_cycle(:,:,i) = nanmean(data(:,:,i:nmonths:end),3);
            anomalies(:,:,i:nmonths:end) = anomalies(:,:,i:nmonths:end) - mean_seasonal_cycle(:,:,i);
        end
    case 2
        mean_seasonal_cycle = zeros(size(data(:,1:nmonths)));
        for i = 1:nmonths
            mean_seasonal_cycle(:,i) = nanmean(data(:,i:nmonths:end),2);
            anomalies(:,i:nmonths:end) = anomalies(:,i:nmonths:end) - mean_seasonal_cycle(:,i);
        end
    case 1
        mean_seasonal_cycle = zeros(size(data(1:nmonths,:)));
        for i = 1:nmonths
            mean_seasonal_cycle(i,:) = nanmean(data(i:nmonths:end,:),1);
            anomalies(i:nmonths:end,:) = anomalies(i:nmonths:end,:) - mean_seasonal_cycle(i,:);
        end
end

