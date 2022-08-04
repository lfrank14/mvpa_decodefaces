#!/bin/bash

# This script calculates the multivoxel pattern analysis to test for:
# 1. the existence of information relating to the category of the stimulus presented 
# Regions of interest are:
# - Hippocampus
# - Inferior Parietal cortex
# - Posterior Fusiform
# - Superior Parietal cortex
# - Parahippocampal cortex
# - Lateral Occipital cortex
# Requires:
# - classify_preexpo.py in batch/11a_mvpa folder
# - classify_postexpo.py in batch/11a_mvpa folder
# - classify_pre2post.py in batch/11a_mvpa folder
# - classify_post2pre.py in batch/11a_mvpa folder
# - roi masks in each subject's refspace folder
# - smoothed concatenated betaseries in each subject's beta folder
# - event onset files in each subject's beh folder. 
# Results will appear in the group/mvpa folder.
# How to run: sbatch 11a_batch_mvpa.sh

#SBATCH --account=bamlab --output=logs/11a_batch_mvpa_%j.txt
expdir=/projects/bamlab/shared/aepet2
resdir=${expdir}/group/mvpa/

# Make directories for mvpa results if they don't already exist
mkdir -p ${resdir}
mkdir -p ${resdir}/expo
mkdir -p ${resdir}/expo_cross

# What subjects do you want to run MVPA on?
sbjs="1,2,3,7,8,11,12,701,702,1001" 
rois="b_phip b_hip b_phc b_ca1 b_ca3 b_dentate b_subiculum b_amtl b_erc b_lofc b_mofc b_lo b_striatum b_supar b_ipar b_ifg b_angular b_pfus b_tmppole b_amtg b_pmtg"
#rois="b_ahip"

# Run MVPA
echo Started MVPA on: `date`

for classifier in 'smlr' 'svm'
do
	for phase in 'pre' 'post'
	do
		for decoded in 'relevantPF' 'irrelevantPF'
		do
			for roi in ${rois}
			do
				for deriv in 'td' 'ntd'
				do
					echo ${classifier}_${decoded}_${deriv}_${roi}

					${expdir}/scripts/11a_mvpa/classify_expo.py ${roi} ${classifier} ${decoded} ${sbjs} ${phase} ${deriv} &&
					${expdir}/scripts/11a_mvpa/classify_expo_cross.py ${roi} ${classifier} ${decoded} ${sbjs} ${phase} ${deriv}	

				
					echo "Classification Complete"
					echo ".............................................."
				done 
			done
		done
	done
done

echo Finished MVPA on: `date`