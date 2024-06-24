# Preparing Raw Timing Files for Event-Related fMRI Study
 
Project scripts for processing raw timing files for an event-related fMRI study

## Description

This is a part of the preprocessing stage of an event-related fMRI study where participants undergo an event-based fMRI paradigm before completing a post-scan memory recall test. There are three types of stimuli used for the event-based paradigm: 1) words, 2) faces, and 3) pictures. Participants are given one of five codes depending on their performance during the post-scan memory recall test: 1) true positive (shown and remembered), 2) false positive (not shown but remembered), 3) true negative (not shown and not remembered), 4)false negative (shown and not remembered), and 5) invalid response.


For each of the specified stimuli (the default argument is all three conditions), two contrast timing text files are created for each participant corresponding to correctly remembered stimuli and incorrectly remembered stimuli, respectively. For each timing file, the respective stimuli items correctly or incorrectly identified by the participant during the post scan recall test will be coded as "1", while all other items and TRs which occured when the participant viewed a fixation crosshair will be coded as "0". The timing files are sorted by the TR/acquision time order (ascending order) prior to their use in FSL for GLM contrasts.

## Getting Started

The notebook file "timing_file.ipynb" creates a function called createTiming(), which produces correctly remembered and incorrectly remembered contrast timing files for the specified stimulus conditions, and takes three arguments: 1) the directory where your raw data is stored within your working directory, 2) the condition you are making a contrast sheet for ("Picture", "Word", or "Face"), and 3) the ID number of the participant (e.g., 3 for 003, 5 for 005, etc.). The function will read the csv file identified by the directory and the participant ID, create a dataframe with the modified edata, and export it into txt files.

### Dependencies
* pandas (v. 2.2.2)
* numpy (v. 1.26.4)

## Authors

Isaac Cormier 
@icormier0021@gmail.com

## License

This project is licensed under the MIT License - see the LICENSE.md file for details

## Acknowledgments
Thank you to the developers of numpy and pandas. You and your packages are all awesome!
