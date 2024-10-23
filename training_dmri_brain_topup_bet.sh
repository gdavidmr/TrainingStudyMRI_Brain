#!/bin/bash

# ----------------------------------------
# This script estimates the off-resonance field by comparing two images acquired by different gradient schemes (typically opposite phase-encoding polarity). This information will be used to retrospectively correct for susceptibility artifacts in the DWI volumes. Note that correction is not performed at this step. Here, only the off-resonance field is created which will be fed into the eddy algorithm in the next processing step. For more information on the procedure, see: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup
# Second, brain extraction is performed, generating a brain mask which will be applied on all DW images. For more information on the procedure, see: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET/UserGuide
#
# Specific tasks performed:
# 1. estimating off-resonance field, which will be then fed into the eddy algorithm to correct for susceptibility artifacts
# 2. extracting brain tissue by removing removing surrounding tissue
#
#
# Note1: the creation of the brain mask is based on the image created by averaging the first blip-up and blip-down images.
# Note2: the folder structure in the script below might be adjusted for your particular case.
#
# Created by G.David, July 2019
# ----------------------------------------

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


# ======= Get off-resonance field and brain mask ==========

# running topup: estimating the off-resonance field and creating corrected bu and bd volume
topup --imain="$key"-bdbu.nii --datain=$acqparams --config=b02b0.cnf --out="$key"-bdbu_desc-topup --iout="$key"-bdbu_desc-topup -v

# running bet

if [ -f "$key"-bdbu_desc-topup.nii ]; then

# if topup was successful, creating a brain mask on the average of corrected bd and bu volume
fslmaths "$key"-bdbu_desc-topup -Tmean "$key"-bdbu_desc-topup-avg
bet "$key"-bdbu_desc-topup-avg "$key"-bdbu_desc-topup-avg-bet -m -v

else
# if topup was NOT successful, creating a brain mask on the average (bd) volume
fslmaths "$dwi" -Tmean "$key"_desc-avg
bet "$key"_desc-avg "$key"_desc-avg-bet -m -v

fi

# remove unnecessary files
rm "$key"-bd.nii

# create extended bval and bvec files
# sed 's/^/0 /' $subject/"$key".bval > "$key"_ext.bval
# sed 's/^/0 /' $subject/"$key".bvec > "$key"_ext.bvec

done
