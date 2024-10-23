#!/bin/bash

# ----------------------------------------
# This script estimates the off-resonance field by comparing two images acquired by different gradient schemes (typically opposite phase-encoding polarity). This information will be used to retrospectively correct for susceptibility artifacts in the DWI volumes. Note that correction is not performed at this step. Here, only the off-resonance field is created which will be fed into the eddy algorithm in the next processing step. For more information on the procedure, see: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup
# Second, brain extraction is performed, generating a brain mask which will be applied on all DW images. For more information on the procedure, see: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET/UserGuide

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


# ===================== Denoising =====================

mrconvert "$key"_dwi.nii "$key"_dwi.mif
dwidenoise "$key"_dwi.mif "$key"_desc-deno_dwi.mif
mrconvert "$key"_desc-deno_dwi.mif "$key"_desc-deno_dwi.nii

rm "$key"_dwi.mif
rm "$key"_desc-deno_dwi.mif

done
