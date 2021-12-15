addpath(genpath('/glade/u/home/rwills/Climate_analysis/projects/ENSO_workshop'))

models = {'canesm2','csiro_mk36','gfdl_cm3','gfdl_esm2m_v2','gfdl_spear','mpi','cesm1'};
year1 = [1950 1850 1920 1861 1921 1850 1920];
year2 = [2100 2100 2100 2100 2100 2099 2100];
var = {'tos','tos','ts-sst','tos','tos','tos','ts-sst'};

for i = 1:length(models)
    preprocess_cmip5_LE(models{i},year1(i),year2(i),'monthly',var{i});
end