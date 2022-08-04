#!/usr/bin/python

# mask name = any ROI in antsreg/masks folder
# algorithm = SVM or SMLR

from numpy import *
import pylab as plt
from scipy.io import *
from random import sample
import os
import sys
from mvpa2.base.node import *
from mvpa2.datasets.mri import *
from mvpa2.clfs.knn import *
from mvpa2.clfs.meta import *
from mvpa2.clfs.svm import *
from mvpa2.clfs.smlr import *
from mvpa2.clfs.plr import *
from mvpa2.clfs.stats import *
from mvpa2.featsel.base import *
from mvpa2.featsel.helpers import *
from mvpa2.generators.permutation import *
from mvpa2.generators.partition import *
from mvpa2.generators.base import *
from mvpa2.mappers.detrend import *
from mvpa2.mappers.zscore import *
from mvpa2.mappers.fx import *
from mvpa2.measures.base import *
from mvpa2.measures import *
from mvpa2.measures.searchlight import *
from mvpa2.measures.anova import *
from mvpa2.misc.stats import *

mask = sys.argv[1] #'b_fus' 
alg =  sys.argv[2]  # 'svm' or 'smlr' classifier algorithm
decoded = sys.argv[3] # label for what's decoded (relevantPF, irrelevantPF)?
sbjs = sys.argv[4].split(',') 
phase = sys.argv[5] # pre or post-exposure
deriv = sys.argv[6] # td or ntd

basedir = '/projects/bamlab/shared/aepet2/'
resultdir = basedir+'group/mvpa/expo/'

# Does the result directory exist? If not, then create it
if not os.path.exists(resultdir):
    os.makedirs(resultdir)

# Do we want to use feature selection and save our results?
featsel = True    # use feature selection
featseln = 100   # number of features selected
saveres = True   # save test prediction results

# Create variable to which data will be loaded at the end
data_Expo = []

# Classification within Training for each subject
for sbj in sbjs:

    sbjdir = basedir+'sub-'+sbj+'/'
    maskdir = sbjdir+'anat/antsreg/masks/'
    datadir = sbjdir+'func/expo/single_trial/betas/'
    behavedir = basedir+'behave/'
    
    print "Starting "+sbj+": "+time.strftime('%H:%M:%S',time.localtime())

    ## read in behavioral data file and concatenated betas
    onset,run,expo,trial,id,relevantPF,irrelevantPF,category_rel,category_irrel,eventrials,oddtrials = loadtxt(behavedir+'sub-'+sbj+'_behave.txt',unpack=1)
    betas = datadir+'betas_all_'+deriv+'.nii.gz'
    expds = fmri_dataset(betas,mask=maskdir+mask+'.nii.gz')
    
    # Set up experimental dataset (what is being training and what is being tested)
    expds.sa['chunks'] = run
    expds.sa['targets'] = eval(decoded)

    # Pull out the expo data 
    if phase=='pre':
        expds_expo=expds[expds.chunks < 2.5] # pre-expo data = runs 1-2
    elif phase=='post':
        expds_expo=expds[expds.chunks > 2.5] # post-expo data = runs 3-4
    
    # Standardize
    zscore(expds_expo,chunks_attr='chunks')
 
    ## classification
    print "-- starting classification: "+time.strftime('%H:%M:%S',time.localtime())

    if alg=='svm':
        clf = LinearCSVMC(probability=1,enable_ca=['probabilities'])
    elif alg=='smlr':
        clf = SMLR()

    if featsel:
        tailsel = FixedNElementTailSelector(featseln,mode='select',tail='upper')
        fsel = SensitivityBasedFeatureSelection(OneWayAnova(),tailsel)
        fsclf = FeatureSelectionClassifier(clf,fsel)
    else:
        fsclf = clf
    
    # Train and Test Classifier on the Training data using Crossvalidation Procedure 
    # (leave one "chunk out" is the default for NFoldPartitioner(), which in this case is a run)
    cv = CrossValidation(fsclf,NFoldPartitioner(),enable_ca=['stats'])
    res = cv(expds_expo)
    acc = 1-mean(res.samples)
    data_Expo.append(acc)
    
    
if saveres:
    savetxt(resultdir+mask+'_'+deriv+'_'+alg+'_'+phase+'expo_'+decoded,data_Expo,fmt='%.6f')
    

print "-- finished: "+time.strftime('%H:%M:%S',time.localtime())

