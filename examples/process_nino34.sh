#!/bin/bash

# preprocessing Nino3.4 for jupyter notebook. Takes monthly mean 'ts' and uses cdo to compute global mean.
# Assuming that ts over the ocean contains sst for all models

# don't use module load cdo, produces segmentation fault while cdo from conda works fine

basedir_MMLEA=/glade/collections/cdg/data/CLIVAR_LE
basedir_out=/glade/scratch/$USER/SMILEs

# ##################
# # CESM-LENS
# #
# # CESM files are compressed netcdf4, which makes cdo insanely slow. Therefore there is an additional step for decompression first.

# idir=$basedir_MMLEA/cesm_lens/Amon/ts/

# # process 1850 member
# echo processing member 1
# model=cesm-lens
# varstring=ts
# outdir_unzip=${basedir_out}/CESM-LENS/decompressed/${varstring}
# mkdir -p $outdir_unzip
# ifile=${idir}/${varstring}_Amon_CESM1-CAM5_historical_rcp85_r1i1p1_185001-210012.nc
# ofile_unzip=${outdir_unzip}/${varstring}_Amon_CESM1-CAM5_historical_rcp85_r1i1p1_185001-210012.nc
# nccopy -d0 $ifile $ofile_unzip


# outdir=${basedir_out}/CESM-LENS/nino34
# mkdir -p $outdir
# ofile=${outdir}/nino34_${varstring}_${model}_historical_rcp85_r1i1p1_1850-2100.nc
# cdo fldmean -sellonlatbox,-170,-120,-5,5 ${ofile_unzip} ${ofile}
# ofile_DJF=${outdir}/nino34_${varstring}_${model}_historical_rcp85_r1i1p1_1850-2100_DJFmean.nc
# cdo timselmean,3,2 -select,season=DJF ${ofile} ${ofile_DJF}

# # process remaining 39 members starting in 1920
# run_0=2
# run_n=40
# experiment=historical_rcp85
# suffix=i1p1

# for rrr in $(seq $run_0 $run_n); do

#     expid=r$(printf "%01d" $rrr)${suffix}
#     echo ${expid}
#     datdir=${idir}
#     ifile=${datdir}/${varstring}*${experiment}*${expid}*.nc
#     ofile_unzip=${outdir_unzip}/${varstring}_Amon_CESM1-CAM5_${experiment}_${expid}_192001-210012.nc
#     nccopy -d0 $ifile $ofile_unzip

#     ofile=${outdir}/nino34_${varstring}_${model}_${expid}_1920-2100.nc
#     cdo fldmean -sellonlatbox,-170,-120,-5,5 ${ofile_unzip} ${ofile}
#     ofile_DJF=${outdir}/nino34_${varstring}_${model}_${expid}_1920-2100_DJFmean.nc
#     cdo timselmean,3,2 -select,season=DJF ${ofile} ${ofile_DJF}
# done


##################
# MPI-GE
#

idir=$basedir_MMLEA/mpi_lens/Amon/ts/

run_0=84
run_n=100
model=mpi-ge
varstring=ts
suffix=i1p1
outdir=${basedir_out}/MPI-GE/nino34
mkdir -p $outdir

for rrr in $(seq $run_0 $run_n); do

    expid=r$(printf "%01d" $rrr)${suffix}
    echo ${expid}
    datdir=${idir}
    ifiles=${datdir}/${varstring}*${expid}*.nc
    ofile=${outdir}/nino34_${varstring}_${model}_${expid}.nc
    cdo fldmean -sellonlatbox,-170,-120,-5,5 ${ifiles} ${ofile}
    ofile_DJF=${outdir}/nino34_${varstring}_${model}_${expid}_DJFmean.nc
    cdo timselmean,3,2 -select,season=DJF ${ofile} ${ofile_DJF}    
done

##################
# CanESM2
#

idir=$basedir_MMLEA/canesm2_lens/Amon/ts/

run_0=1
run_n=50
model=canesm2
experiment=historical_rcp85
varstring=ts
suffix=i1p1
outdir=${basedir_out}/CanESM2/nino34
mkdir -p $outdir

for rrr in $(seq $run_0 $run_n); do

    expid=r$(printf "%01d" $rrr)${suffix}
    echo ${expid}
    datdir=${idir}
    ifiles=${datdir}/${varstring}*${experiment}*${expid}*.nc
    ofile=${outdir}/nino34_${varstring}_${model}_${expid}.nc
    cdo fldmean -sellonlatbox,-170,-120,-5,5 ${ifiles} ${ofile}
    ofile_DJF=${outdir}/nino34_${varstring}_${model}_${expid}_DJFmean.nc
    cdo timselmean,3,2 -select,season=DJF ${ofile} ${ofile_DJF}    

done

