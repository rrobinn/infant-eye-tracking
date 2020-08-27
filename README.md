# About

This repo contains the code and some example stimuli for a gaze-contingeny eye-tracking task designed for infants. 

## Background  
Infants live in a visually complex world. To efficiently learn from their environments, they must learn to filter out noise and focus on the important information. Data suggest that there are two main drivers attention: "bottom-up" attentional capture from visually compelling stimuli, and "top-down" goal-driven attention. As infants develop, they become better at inhibiting attention from visually compelling distractors, and executing goal-driven attention.  

How do infants learn what's important to pay attention to? One theory is that through rewarding experiences with stimuli (e.g. mom's face, their favorite toy), infants develop attentional biases for attending to those objects. <b>The goal of this study</b> is to examine how rewards boost infant's attentional biases towards specific objects.   

# Running Task  
<b>MATLAB is required for the task to run.</b>  
1. Make sure MATLAB is in the right directory (`~/wdir/SemSal/`).  
2. Type `RunSemanticSalience` in MATLAB's command line. It will take a moment to load the necessary stimuli. When they ahve been successfully loaded, uou will be prompted to enter the User ID.  
3. At that point, a procedure will begin to calibrate the participant to the eye-tracker.  
4. After a successful calibration, the task will begin. If calibration is not successful you will be prompted to try again.  

# Trouble-shooting  
<b> Error messages related to `trackerID` </b>  
- Make sure the eye-tracker is on. It can take a minute to correct.  
- Open the tobii software and makes sure that the name of the eye-tracker matches `trackerId` in `RunSemanticSalience.m` (line 44).  

<b> Error in function `getTrialInformation.m`  </b>
- Make sure that your paths to the stimulus files are set correctly (line 8).    

<b> Other things to check </b>  
- Are the paths in the main script (`RunSemanticSalience.m`, line 28-29) set correctly)?  
  

