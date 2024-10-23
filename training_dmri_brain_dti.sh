#!/bin/bash

# ----------------------------------------
# Goal:
# The script performs diffusion tensor fitting. For more information on the procedure, see: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuidehttps://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide
#
# Specific tasks performed:
# 1. diffusion tensor fitting, creating maps of eigenvectors, eigenvectors, and scalar maps
#
# Input: a text file containing the subject folders 
# Usage:
# FSL_dtifit_forBrainDTI folderlist.txt
#
# Note1: dtifit can fit the tensor only using OLS or WLS algorithms. Robust fitting is not implemented. Recommemded option is WLS.
# Note2: the diffusion tensor is fitted only on the blip-up volumes. For this reason, the last line from the rotated bvec file has to be deleted
# Note3: the folder structure in the script below might be adjusted for your particular case
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
bvecs=$(find $subject/dmri_brain -name sub-*_ses-*_acq-dmri-brain_desc-deno-topup-eddy.eddy_rotated_bvecs)





# ======= Diffusion Tensor Fitting ==========

mkdir dmri_brain/dti_wls

if [ -f "$key"-bdbu_desc-topup.nii ]; then
# if topup was successful

# create mask consisting of ones thoughout
fslmaths "$key"-bdbu_desc-topup-avg-bet_mask.nii -mul 0 -add 1 "$key"_desc-const1_mask.nii

# fit diffusion tensor
dtifit --data="$key"_desc-deno-topup-eddy.nii \
--mask="$key"_desc-const1_mask.nii \
--bvals="$bvals" \
--bvecs="$bvecs" \
--out="$key"_desc-deno-topup-eddy-wls \
--wls \
--save_tensor \
--sse \
--verbose

else
# if topup was NOT successful

# create mask consisting of ones thoughout
fslmaths "$key"_desc-avg-bet_mask.nii -mul 0 -add 1 "$key"_desc-const1_mask.nii

# fit diffusion tensor
dtifit --data="$key"_desc-deno-eddy.nii \
--mask="$key"_desc-const1_mask.nii \
--bvals="$bvals" \
--bvecs="$key"_desc-deno-eddy.eddy_rotated_bvecs \
--out="$key"_desc-deno-eddy-wls \
--wls \
--save_tensor \
--sse \
--verbose

fi

mv dmri_brain/*-wls_*.nii dmri_brain/dti_wls

done
