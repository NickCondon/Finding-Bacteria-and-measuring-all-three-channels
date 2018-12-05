# Finding-Bacteria-and-measuring-all-three-channels
This script takes 3-colour images (RGB) and detects bacteria (Red &amp; Blue channel) and outputs Bacteria Area, R/G/B Mean and Max Intensity. The bacteria are identified by thresholding (user interactive for DAPI) and combining the Blue/Red Channel results. Changed threshold for DAPI 

Developed by Dr Nicholas Condon.

[ACRF:Cancer Biology Imaging Facility](https://imb.uq.edu.au/microscopy), 
Institute for Molecular Biosciences, The University of Queensland
Brisbane, Australia 2018.

This script is written in the ImageJ1 Macro Language.


Background
-----

This script is designed to take RGB images of bacteria and associated reporters, identify the bacteria (blue channel) by user inputed thresholding and add the found bacteria to the ROI manager. It then uses these regions to measure intensity values within the other channels (red & green channels), outputing the results into a .csv file.

Running the script
-----
The first dialog box to appear explains the script, acknowledges the creator and the ACRF:Cancer Biology Imaging Facility.

The second dialog to open will prompt the user to select parameters for the script to run. These include whether a pre-processing step of a z-projection (eg max, average orsum) should be performed, the expected file's extension (eg, .lsm, .tif, etc) and whether to run in batch mode (background).

The file extension is actually a file ‘filter’ running the command ‘ends with’ which means for example .tif may be different from .txt in your folder only opening .tif files. Perhaps you wish to process files in a folder containing <Filename>.tif and <Filename>+deconvolved.tif you could enter in the box here deconvolved.tif to select only those files. It also uses this information to tidy up file names it creates (i.e. no example.tif.avi)

Running the script in batch mode won’t open the files into your OS, instead it runs in the background, which is faster and more memory efficient.

The next window to open will be the input file directory location.

The final dialog box is an alert to the user that the batch is completed. 


Output files
-----
Files are put into a results directory called 'Results_WBT_<date&time>' within the chosen working directory. Files will be saved as either a .tif or .txt for the log file. Original filenames are kept and have tags appended to them based upon the chosen parameters.

A text file called log.txt is included which has the chosen parameters and date and time of the run.


￼
