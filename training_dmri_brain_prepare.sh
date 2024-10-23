#!/bin/bash

# ----------------------------------------
# This script is to prepare the blip-up (bu) and blip-down (bd) images for subsequent processing steps (topup, eddy, etc.).
# Therefore, this script should be run first in the dwi processing pipeline.
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

# ======= Manipulate blip-up (bu) and blip-down (bd) images ==========

# save last b0 volume of the 4D dmri dataset (this was acquired temporally the closest to the single blip-up volume)
fslroi $dwi "$key"-bd 66 1
dwi_bd="$key"-bd.nii

# produce a file containing the first bu and bd volume (2 volumes in total)
fslmerge -t "$key"-bdbu $dwi_bd $dwi_bu

# merge all files (bu + all bd)
# fslmerge -t "$key"_ext "$key"_bu.nii.gz $dwi

done
