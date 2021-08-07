#!/bin/bash

# preprocessing GSAT for jupyter notebook. Takes global monthly mean 'tas' and uses cdo to compute global mean.

module load cdo

basedir_MMLEA=/glade/collections/cdg/data/CLIVAR_LE
basedir_out=/glade/scratch/$USER

##################
# CESM-LENS
#
# CESM files are compressed netcdf4, which makes cdo insanely slow. Therefore there is an additional step for decompression first.

idir=$basedir_MMLEA/cesm_lens/Amon/tas/

# process 1850 member
echo processing member 1
model=cesm-lens
varstring=tas
outdir_unzip=${basedir_out}/CESM-LENS/decompressed/${varstring}
mkdir -p $outdir_unzip
ifile=${idir}/tas_Amon_CESM1-CAM5_historical_rcp85_r1i1p1_185001-210012.nc
ofile_unzip=${outdir_unzip}/tas_Amon_CESM1-CAM5_historical_rcp85_r1i1p1_185001-210012.nc
nccopy -d0 $ifile $ofile_unzip


outdir=${basedir_out}/CESM-LENS/global_mean
mkdir -p $outdir
ofile=${outdir}/${varstring}_${model}_historical_rcp85_r1i1p1_1850-2100_globalmean.nc
cdo fldmean ${ofile_unzip} ${ofile}

# process remaining 39 members starting in 1920
run_0=2
run_n=40
model=cesm-lens
experiment=historical_rcp85
varstring=tas
suffix=i1p1
outdir=${basedir_out}/CESM-LENS/global_mean
outdir_unzip=${basedir_out}/CESM-LENS/decompressed/${varstring}
mkdir -p $outdir
mkdir -p $outdir_unzip

for rrr in $(seq $run_0 $run_n); do

    expid=r$(printf "%01d" $rrr)${suffix}
    echo ${expid}
    datdir=${idir}
    ifile=${datdir}/${varstring}*${experiment}*${expid}*.nc
    ofile_unzip=${outdir_unzip}/${varstring}_Amon_CESM1-CAM5_${experiment}_${expid}_185001-210012.nc
    nccopy -d0 $ifile $ofile_unzip

    ofile=${outdir}/${varstring}_${model}_${expid}_1920-2100_globalmean.nc
    cdo fldmean ${ofile_unzip} ${ofile}
done


##################
# MPI-GE
#

idir=$basedir_MMLEA/mpi_lens/Amon/tas/

run_0=1
run_n=100
model=mpi-ge
varstring=tas
suffix=i1p1
outdir=${basedir_out}/MPI-GE/global_mean
mkdir -p $outdir

for rrr in $(seq $run_0 $run_n); do

    expid=r$(printf "%01d" $rrr)${suffix}
    echo ${expid}
    datdir=${idir}
    ifiles=${datdir}/${varstring}*${expid}*.nc
    ofile=${outdir}/${varstring}_${model}_${expid}_globalmean.nc
    cdo fldmean ${ifiles} ${ofile}
done

##################
# CanESM2
#

idir=$basedir_MMLEA/canesm2_lens/Amon/tas/

run_0=1
run_n=50
model=canesm2
experiment=historical_rcp85
varstring=tas
suffix=i1p1
outdir=${basedir_out}/CanESM2/global_mean
mkdir -p $outdir

for rrr in $(seq $run_0 $run_n); do

    expid=r$(printf "%01d" $rrr)${suffix}
    echo ${expid}
    datdir=${idir}
    ifiles=${datdir}/${varstring}*${experiment}*${expid}*.nc
    ofile=${outdir}/${varstring}_${model}_${expid}_globalmean.nc
    cdo fldmean ${ifiles} ${ofile}
done