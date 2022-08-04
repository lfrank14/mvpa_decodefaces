#!/bin/bash
#SBATCH --account=bamlab --output=logs/facat_batch_mvpa_%j.txt#!/bin/bash

subinc='inc41' #'inc41' 'exc41'
classifier='svm'
task=${SLURM_ARRAY_TASK_ID}
expdir=/projects/bamlab/shared/facat13
resdir=${expdir}/analysis/
scriptdir=${expdir}/scripts/mvpa

##############################################
# Make directories for mvpa results if they don't already exist
##############################################

mkdir -p ${resdir}
mkdir -p ${resdir}/mvpa_${subinc}

cd ${expdir}

##############################################
## What subjects do you want to run MVPA on?
##############################################
sbjs="1,2,3,4,5,6,7,8,9,10,11,12,15,16,17,18,19,20,21,22,23,24,25,26,27,28,30,31,32,33,34,35,37,38,39,40,41,42,43,44" # good training data + 41

##############################################
## Binarize Brain Mask for each subject	
##############################################

# for s in $(echo $sbjs | sed "s/,/ /g")
# do
# 	subdir=${expdir}/sub-$s/antsreg
# 	
# 	echo " .............................................."
# 	echo "Binarizing brainmask image for Subject $s"
# 	fslmaths ${subdir}/brainmask_func.nii.gz -bin ${subdir}/brainmask_func_bin.nii.gz
# done
	
##############################################
## What do you want to decode?
##############################################

# Relevant and Irrelevant parents: all 4 runs of training crossvalidation
# echo " .............................................."
# echo "Starting Searchlight Analysis: Training Crossvalidation (all 4 runs)"
# 
# for s in $(echo $sbjs | sed "s/,/ /g")
# do
# 	for decoded in 'relevantPF' 'irrelevantPF'
# 	do
# 		## Set up ROIs
# 		roi="brainmask_func_bin" # entire binarized brainmask in functional space
# 
# 		# Run searchlight crossvalidation on training data launching each subject in parallel
# 		sbatch --account=bamlab --parsable --output=${scriptdir}/logs/facat_mvpa_sl_%j.txt ${expdir}/scripts/mvpa/facat13_classify_trainCV_searchlight.py ${roi} ${classifier} ${decoded} ${s} ${subinc}	
# 	done
# 		
# done
# 
# echo " .............................................."
# echo "Searchlight Launched for all Subjects! Check individual log files for progress."

# ### Relevant and Irrelevant parents: early training (runs 1-2)
# echo " .............................................."
# echo "Starting searchlight Analysis: Early Training Crossvalidation (runs 1-2)"
# 
# # Make results directory for this particular analysis
# mkdir -p ${resdir}/mvpa_${subinc}/train_cvEarly_sl # training searchlight directory
# 
# for s in $(echo $sbjs | sed "s/,/ /g")
# do
# echo " .............................................."
# echo "Starting searchlight for Subject: ${s}"
# 
# 	for decoded in 'relevantPF' 'irrelevantPF'
# 	do
# 		## Set up ROIs
# 		roi="brainmask_func_bin" # entire binarized brainmask in functional space
# 
# 		# Run searchlight crossvalidation on training data launching each subject in parallel
# 		sbatch --account=bamlab --parsable --output=${scriptdir}/logs/facat_mvpa_sl_trainE_%j.txt ${expdir}/scripts/mvpa/facat13_classify_traincvEarly_searchlight.py ${roi} ${classifier} ${decoded} ${s} ${subinc}	
# 	done
# 		
# done
# 
# echo " .............................................."
# echo "Searchlight Launched for all Subjects! Check individual log files for progress."


# ### Relevant and Irrelevant parents: late training (runs 3-4)
# echo " .............................................."
# echo "Starting searchlight Analysis: Late Training Crossvalidation (runs 3-4)"
# 
# # Make results directory for this particular analysis
# mkdir -p ${resdir}/mvpa_${subinc}/train_cvLate_sl # training searchlight directory
# 
# for s in $(echo $sbjs | sed "s/,/ /g")
# do
# 	echo " .............................................."
# 	echo "Starting searchlight for Subject: $s"
# 
# 	for decoded in 'relevantPF' 'irrelevantPF'
# 	do
# 		## Set up ROIs
# 		roi="brainmask_func_bin" # entire binarized brainmask in functional space
# 
# 		# Run searchlight crossvalidation on training data launching each subject in parallel
# 		sbatch --account=bamlab --parsable --output=${scriptdir}/logs/facat_mvpa_sl_trainL_%j.txt ${expdir}/scripts/mvpa/facat13_classify_traincvLate_searchlight.py ${roi} ${classifier} ${decoded} ${s} ${subinc}	
# 	done
# 		
# done
# 
# echo " .............................................."
# echo "Searchlight Launched for all Subjects! Check individual log files for progress."


### Relevant and Irrelevant parents: middle training (runs 2-3)
echo " .............................................."
echo "Starting searchlight Analysis: Middle Training Crossvalidation (runs 2-3)"

# Make results directory for this particular analysis
mkdir -p ${resdir}/mvpa_${subinc}/train_cvMid_sl # training searchlight directory

for s in $(echo $sbjs | sed "s/,/ /g")
do
	echo " .............................................."
	echo "Starting searchlight for Subject: $s"

	for decoded in 'relevantPF' 'irrelevantPF'
	do
		## Set up ROIs
		roi="brainmask_func_bin" # entire binarized brainmask in functional space

		# Run searchlight crossvalidation on training data launching each subject in parallel
		sbatch --account=bamlab --parsable --output=${scriptdir}/logs/facat_mvpa_sl_trainM_%j.txt ${expdir}/scripts/mvpa/facat13_classify_traincvMid_searchlight.py ${roi} ${classifier} ${decoded} ${s} ${subinc}	
	done
		
done

echo " .............................................."
echo "Searchlight Launched for all Subjects! Check individual log files for progress."
