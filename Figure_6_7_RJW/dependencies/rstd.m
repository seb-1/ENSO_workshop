function [series_std] = rstd(series,timesteps)

% takes standard deviation in moving window of width timesteps



if mod(timesteps,2) == 1
    r = timesteps-1;
    series_std = zeros(length(series)-r,1);
    is = (r/2+1):(length(series)-r/2);
    for i = 1:length(is)
        series_std(i) = std(series(is(i)-r/2:is(i)+r/2));
    end
else
    series_std = zeros(length(series)-timesteps+1,1);
    is = (timesteps/2):(length(series)-timesteps/2);
    for i = 1:length(is)
        series_std(i) = std(series(is(i)-timesteps/2+1:is(i)+timesteps/2));
    end
end