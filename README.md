# ENSO_workshop
Scripts for the ENSO/SMILE workshop August 2021

Use https://jupyterhub.hpc.ucar.edu to run the notebooks and select the Pangeo Kernel.

Examples include simple steps like loading large ensemble output, doing simple calculations, and plotting.

## data on Cheyenne

MMLEA: `/glade/collections/cdg/data/CLIVAR_LE`

CMIP6 SMILEs: `/glade/scratch/rwills/cmip6_ensembles`


Prerocessed GSAT and Nino3.4 SST for some models: `/glade/scratch/milinski/SMILEs`

## custom environment
(optional, more flexibility)

To use a custom conda environment on CISL systems that allows installing your own packages, such as python cdo bindings, do the following:

Download the conda installer into your home directory:
`wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh`

and run `bash  Miniconda3-latest-Linux-x86_64.sh`

Create a new environment:
`conda create --name jlab_37 python=3.7 jupyterlab matplotlib cartopy cdo netcdf4 numpy pandas python-cdo scipy seaborn tqdm xarray ipykernel dask`

Note that python >3.7 can cause problems with jupyterhub at CISL. ipykernel is required so that jupyterhub can use the environment.

Consider moving the environments (which can be ~4GB) to a different location. This can be done by creating the file ~/.condarc with the following content:

```
envs_dirs:
  - /glade/work/USER/conda/conda-envs
pkgs_dirs:
  - /glade/scratch/USER/conda/conda-pkgs
changeps1: false
auto_activate_base: false
channels:
  - conda-forge
  - defaults
```
