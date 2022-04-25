addpath(genpath('/glade/u/home/rwills/Climate_analysis/projects/ENSO_workshop'))

models = {'access','canesm5','ipsl_cm6a','miroc6','miroc_esm2l','ec-earth3','ec-earth3','ec-earth3','cesm2'};
ssp_name = {'ssp370','ssp370','ssp370','ssp585','ssp585','ssp585','none','ssp585','ssp370'};

members{1} = 1:40; %1:10
members{2} = 1:25;
members{3} = [1:10,14];
members{4} = 1:50;
members{5} = 1:10;
% ec-earth3 (3 subsets)
members{6} = [1 3 4 6 9 11 13 15];
members{7} = [2 7 10 12 14 16:25];
members{8} = 101:150;
cesm2_macro1 = [100101 102102 104103 106104 108105 110106 112107 114108 116109 118110];
cesm2_macro2 = cesm2_macro1+1000;
members{9} = [123101:123120, 125101:125120, 128101:128120, 130101:130120, cesm2_macro1, cesm2_macro2(1:9)];

year1 = [1850 1850 1850 1850 1850 1850 1850 1970 1850];
year2 = [2100 2099 2100 2100 2100 2100 2014 2100 2100];
var = {'tos','tos','tos','tos','tos','tos','tos','tos','tos'};

for i = 1%:length(models)
    if strcmp(ssp_name{i},'none')
        preprocess_cmip6_LE_no_ssp(models{i},members{i},year1(i),year2(i),'monthly',var{i});
    else
        preprocess_cmip6_LE(models{i},ssp_name{i},members{i},year1(i),year2(i),'monthly',var{i});
    end
end