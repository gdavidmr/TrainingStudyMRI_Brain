#!/bin/bash

subjects=$(cat $1)

for subject in $subjects
do

echo 'Processing: '$subject
cd $subject/dmri_brain

if [ -f *-bdbu_desc-topup.nii ]; then

rm *_acq-dmri-brain_desc-avg.nii
rm *_acq-dmri-brain_desc-avg-bet.nii
rm *_acq-dmri-brain_desc-avg-bet_mask.nii

fi

done
