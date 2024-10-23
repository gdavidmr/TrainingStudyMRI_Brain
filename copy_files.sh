#!/bin/bash

subjects=$(cat $1)

for subject in $subjects
do
	
echo $subject
	
key=$(echo -n $subject | tail -c 10)
echo "$key"

cd /Volumes/Tim_backup/Balgrist_backup/$subject/ep2d_diff_wholebrain_66_0011/
cp -r normalised /Volumes/tim_2_balgrist/$subject/ep2d_diff_wholebrain_66_0011

done
