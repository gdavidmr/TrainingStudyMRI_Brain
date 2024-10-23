#!/bin/bash

# ----------------------------------------
# The script performs artifact correction including eddy-current and motion correction as well as susceptibility artifact correction for the DW volumes using FSL's eddy algorithm. For more information on the procedure, see: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/eddy
#
# Specific tasks performed:
# 1. performing eddy-curent and motion correction and susceptibility artifact correction using eddy
#
# Usage:
#
# Note1: the volumes passed for eddy should contain both blip directions, i.e. both blip-up and blip-down volumes
# Note2: eddy performs the both eddy-current and motion correction and susceptibility artifact correction in one step. It means that the images are resliced only once
# Note3: the b vector will be rotated after this correction. Use this rotated b vector for further calculations
# Note4: the folder structure in the script below might be adjusted for your particular case
#
# Created by G.David, July 2019
# ---------------------------------------

# =================== Set variables ===================

subjects=$(cat $1)

FSLOUTPUTTYPE=NIFTI

for subject in $subjects
do

echo "Processing: $subject"
cd $subject

# get filenames of the dMRI files
dwi=$(find $subject/dmri_brain -name sub-*_ses-*_acq-dmri-brain_dwi.nii)
dwi_bu=$(find $subject/dmri_brain_bu -name sub-*_ses-*_acq-dmri-brain-bu.nii)

suffix=_dwi.nii
key="${dwi%$suffix}"

# specify full path to the acqparams file
acqparams=/home/neuroimaging1/dmri/acq_params_forBrain/acqparams_brain_training.txt

# specify full path to the index file
index=/home/neuroimaging1/dmri/acq_params_forBrain/index_brain_training.txt 

# specify full path to the bvals file
bvals=/home/neuroimaging1/dmri/acq_params_forBrain/diffpars_brain_training.bval

# specify full path to the bvecs file
bvecs=/home/neuroimaging1/dmri/acq_params_forBrain/diffpars_brain_training.bvec


# ======= Motion and eddy-current correction ==========

# running eddy
if [ -f "$key"-bdbu_desc-topup.nii ]; then

# if topup was successful, apply it with eddy
eddy \
--imain="$key"_desc-deno_dwi.nii \
--mask="$key"-bdbu_desc-topup-avg-bet_mask.nii \
--acqp=$acqparams \
--index=$index \
--bvals=$bvals \
--bvecs=$bvecs \
--topup="$key"-bdbu_desc-topup \
--out="$key"_desc-deno-topup-eddy \
--verbose

else
# if topup was NOT successful, don't appy it with eddy
eddy \
--imain="$key"_desc-deno_dwi.nii \
--mask="$key"_desc-avg-bet_mask.nii \
--acqp=$acqparams \
--index=$index \
--bvals=$bvals \
--bvecs=$bvecs \
--out="$key"_desc-deno-eddy \
--verbose

fi

done
