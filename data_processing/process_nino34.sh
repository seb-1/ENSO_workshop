#!/bin/bash

# preprocessing Nino3.4
#
# - monthly mean
# 

basedir_MMLEA=/glade/scratch/rwills/cmip6_ensembles
basedir_out=/glade/scratch/milinski/ESGF_downloads/NINO34

# ##################
# # MIROC6
# #
# # tos_mon_MIROC6_historical_r10i1p1f1_g025.nc

# idir=$basedir_MMLEA/miroc6_lens/Omon/tos

# run_0=1
# run_n=50
# model=miroc
# experiment=historical
# varstring=ts
# suffix=i1p1f1

# experiment=historical
# outdir=${basedir_out}/MIROC6/${experiment}
# mkdir -p $outdir
# for rrr in $(seq $run_0 $run_n); do

#     expid=r$(printf "%01d" $rrr)${suffix}
#     echo ${expid}
#     datdir=${idir}
#     ifiles=${datdir}/tos_mon_MIROC6_${experiment}_${expid}_g025.nc
#     ofile=${outdir}/tos_mon_MIROC6_${experiment}_${expid}_g025_nino34.nc
#     cdo fldmean -sellonlatbox,-170,-120,-5,5 ${ifiles} ${ofile}

# done

# experiment=ssp585
# outdir=${basedir_out}/MIROC6/${experiment}
# mkdir -p $outdir
# for rrr in $(seq $run_0 $run_n); do

#     expid=r$(printf "%01d" $rrr)${suffix}
#     echo ${expid}
#     datdir=${idir}
#     ifiles=${datdir}/tos_mon_MIROC6_${experiment}_${expid}_g025.nc
#     ofile=${outdir}/tos_mon_MIROC6_${experiment}_${expid}_g025_nino34.nc
#     cdo fldmean -sellonlatbox,-170,-120,-5,5 ${ifiles} ${ofile}

# done

# ##################
# # MIROC6
# #
# # tos_mon_MIROC6_historical_r10i1p1f1_g025.nc

# idir=$basedir_MMLEA/canesm5_lens/Omon/tos

# run_0=1
# run_n=25
# model=CanESM5
# experiment=historical
# varstring=ts
# suffix=i1p1f1
# suffix_p2=i1p2f1

# experiment=historical
# outdir=${basedir_out}/${model}/${experiment}
# mkdir -p $outdir
# for rrr in $(seq $run_0 $run_n); do

#     expid=r$(printf "%01d" $rrr)${suffix}
#     echo ${expid}
#     expid_p2=r$(printf "%01d" $rrr)${suffix_p2}


#     datdir=${idir}
#     ifiles=${datdir}/tos_mon_${model}_${experiment}_${expid}_g025.nc
#     ofile=${outdir}/tos_mon_${model}_${experiment}_${expid}_g025_nino34.nc
#     cdo fldmean -sellonlatbox,-170,-120,-5,5 ${ifiles} ${ofile}
#     ifiles_p2=${datdir}/tos_mon_${model}_${experiment}_${expid_p2}_g025.nc
#     ofile_p2=${outdir}/tos_mon_${model}_${experiment}_${expid_p2}_g025_nino34.nc
#     cdo fldmean -sellonlatbox,-170,-120,-5,5 ${ifiles_p2} ${ofile_p2}

# done

# experiment=ssp585
# outdir=${basedir_out}/${model}/${experiment}
# mkdir -p $outdir
# for rrr in $(seq $run_0 $run_n); do

#     expid=r$(printf "%01d" $rrr)${suffix}
#     echo ${expid}
#     expid_p2=r$(printf "%01d" $rrr)${suffix_p2}


#     datdir=${idir}
#     ifiles=${datdir}/tos_mon_${model}_${experiment}_${expid}_g025.nc
#     ofile=${outdir}/tos_mon_${model}_${experiment}_${expid}_g025_nino34.nc
#     cdo fldmean -sellonlatbox,-170,-120,-5,5 ${ifiles} ${ofile}
#     ifiles_p2=${datdir}/tos_mon_${model}_${experiment}_${expid_p2}_g025.nc
#     ofile_p2=${outdir}/tos_mon_${model}_${experiment}_${expid_p2}_g025_nino34.nc
#     cdo fldmean -sellonlatbox,-170,-120,-5,5 ${ifiles_p2} ${ofile_p2}

# done

##################
# CESM2-LENS
#

experiment=historical
model=CESM2-LENS

idir=$basedir_MMLEA/cesm2_lens/lens/historical/SST

run_0=1
run_n=50
experiment=BHISTcmip6
initialisation=(1001.001 1021.002 1041.003 1061.004 1081.005 1101.006 1121.007 1141.008 1161.009 1181.010 1231.001 1231.002 1231.003 1231.004 1231.005 1231.006 1231.007 1231.008 1231.009 1231.010 1251.001 1251.002 1251.003 1251.004 1251.005 1251.006 1251.007 1251.008 1251.009 1251.010 1281.001 1281.002 1281.003 1281.004 1281.005 1281.006 1281.007 1281.008 1281.009 1281.010 1301.001 1301.002 1301.003 1301.004 1301.005 1301.006 1301.007 1301.008 1301.009 1301.010)

outdir=${basedir_out}/${model}/${experiment}
mkdir -p $outdir

for i in $(seq $run_0 $run_n); do
    init=${initialisation[$i-1]}
    expid=member$(printf "%01d" $i)
    echo ${expid}
    echo ${init}
    ifiles=${idir}/b.e21.${experiment}.f09_g17.LE2-${init}.cam.h0.SST.*.nc
    ofile=${outdir}/sst_mon_${model}_${experiment}_${expid}_nino34.nc
    cdo fldmean -sellonlatbox,-170,-120,-5,5 -mergetime ${ifiles} ${ofile}
done


run_0=1
run_n=50
experiment=BHISTsmbb
initialisation=(1011.001 1031.002 1051.003 1071.004 1091.005 1111.006 1131.007 1151.008 1171.009 1191.010 1231.011 1231.012 1231.013 1231.014 1231.015 1231.016 1231.017 1231.018 1231.019 1231.020 1251.011 1251.012 1251.013 1251.014 1251.015 1251.016 1251.017 1251.018 1251.019 1251.020 1281.011 1281.012 1281.013 1281.014 1281.015 1281.016 1281.017 1281.018 1281.019 1281.020 1301.011 1301.012 1301.013 1301.014 1301.015 1301.016 1301.017 1301.018 1301.019 1301.020)

outdir=${basedir_out}/${model}/${experiment}
mkdir -p $outdir

for i in $(seq $run_0 $run_n); do
    init=${initialisation[$i-1]}
    expid=member$(printf "%01d" $i)
    echo ${expid}
    echo ${init}
    ifiles=${idir}/b.e21.${experiment}.f09_g17.LE2-${init}.cam.h0.SST.*.nc
    ofile=${outdir}/sst_mon_${model}_${experiment}_${expid}_nino34.nc
    cdo fldmean -sellonlatbox,-170,-120,-5,5 -mergetime ${ifiles} ${ofile}
done


