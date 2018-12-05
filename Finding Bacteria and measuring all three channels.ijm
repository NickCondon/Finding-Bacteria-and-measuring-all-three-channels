print("\\Clear")
//	MIT License

//	Copyright (c) 2018 Nicholas Condon n.condon@uq.edu.au

//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:

//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.

//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

scripttitle="Sweet Group - Finding Bacteria and measuring all three channels";
version="0.3";
date="23/08/2018";
description="This script takes 3-colour images (RGB) and detects bacteria (Red & Blue channel) and outputs Bacteria Area, R/G/B Mean and Max Intensity. The bacteria are identified by thresholding (user interactive for DAPI) and combining the Blue/Red Channel results. Changed threshold for DAPI (+Mean4/BS-200)"
    showMessage("Institute for Molecular Biosciences ImageJ Script", "<html>" 
    +"<h1><font size=6 color=Teal>ACRF: Cancer Biology Imaging Facility</h1>
    +"<h1><font size=5 color=Purple><i>The University of Queensland</i></h1>
    +"<h4><a href=http://imb.uq.edu.au/Microscopy/>ACRF: Cancer Biology Imaging Facility</a><\h4>"
    +"<h1><font color=black>ImageJ Script Macro: "+scripttitle+"</h1> "
    +"<p1>Version: "+version+" ("+date+")</p1>"
    +"<H2><font size=3>Created by Nicholas Condon</H2>"	
    +"<p1><font size=2> contact n.condon@uq.edu.au \n </p1>" 
    +"<P4><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a><\h4> </P4>"
    +"<h3>   <\h3>"    
    +"<p1><font size=3 \b i>"+description+"</p1>"
   	+"<h1><font size=2> </h1>"  
	+"<h0><font size=5> </h0>"
    +"");


//Writes to log window script title and acknowledgement
print("");
print("FIJI Macro: "+scripttitle);
print("Version: "+version+" Version Date: "+date);
print("ACRF: Cancer Biology Imaging Facility");
print("By Nicholas Condon (2018) n.condon@uq.edu.au")
print("");
getDateAndTime(year, month, week, day, hour, min, sec, msec);
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
print("");


//Creates a Parameters dialog box
ext = ".lsm";
Dialog.create("Parameters");
	Dialog.addMessage("Select the processing steps you would like to run")
	Dialog.addMessage(" ");
  	Dialog.addChoice("Run Z-Projection prior to steps", newArray("No Projection", "Max Intensity", "Average Intensity", "Sum Slices"));
  	Dialog.addString("Choose your file extension:", ext);
 	Dialog.addMessage("(For example .czi  .lsm  .nd2  .lif  .ims)");
 	Dialog.addMessage(" ");
 	Dialog.addCheckbox("Run in batch mode (Background)", true);
Dialog.show();
  
	projectiontype = Dialog.getChoice();
	ext = Dialog.getString();
	
	
	batch=Dialog.getCheckbox();


		AnalysisMethod = "Whole Bug Thresholding"

//Prints to log your parameters
print("**** Parameters ****")
print("Pre-Projection Method: "+projectiontype);
print("File extension: "+ext);
print("Analysis Method: "+AnalysisMethod);


//defines if batch mode is to be run as per dialog selection above
if (batch==1) {setBatchMode(true); print("Batch Mode: ON");}
if (batch==0) {setBatchMode(false); print("Batch Mode: OFF");}	


//Defines Variable abv for directory and results output to know what type of analysis was used

if (AnalysisMethod== "Whole Bug Thresholding") abv = "WBT";

    
//Directory Location
path = getDirectory("Choose Source Directory ");
list = getFileList(path);
getDateAndTime(year, month, week, day, hour, min, sec, msec);
start = getTime();


//Creates Directory for output images/logs/results table
resultsDir = path+"_Results_"+abv+"_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+"/";
File.makeDirectory(resultsDir);
print("Working Directory Location: "+path);


//This generates csv file and creates the titles for each column
summaryFile = File.open(resultsDir+"Results_"+abv+"_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+".xls");
print(summaryFile,"Image\t Image Number \t Bug Number \t Bug Area \t Blue Mean \t Blue Max  \t Green Mean \t Green Max \t Red Mean \t Red Max");


//turns on the correct measurement parameters
run("Set Measurements...", "area mean standard modal min shape feret's redirect=None decimal=3");
run("Clear Results");
roiManager("reset");


//This is the first level loop, if more than one file continue until all files are completed. 
for (i=0; i<list.length; i++) {
	if (endsWith(list[i],ext)){
  		open(path+list[i]);
		print("");
		
  		
  		//Projecion Loop
		if (projectiontype!="No Projection") {
			print("Performing Z-Projection");
			run("Z Project...", "projection=["+projectiontype+"] all");
			}


	//Gets filename and shortens extension from the file name	
	windowtitle = getTitle();
  	windowtitlenoext = replace(windowtitle, ext, "");
  	print("Opening File: "+(i+1)+" of "+list.length+"  Filename: "+windowtitle);	

  	//Splits out the channels & renames them, and clears the results table
   	run("Split Channels");
  	run("Clear Results");
	selectWindow("C3-"+windowtitle);
		rename("Blue");
	selectWindow("C2-"+windowtitle);
		rename("Green");
	selectWindow("C1-"+windowtitle);
		rename("Red");

	//creates a red/blue window to threshold and leaves original red/blue window for measuring later
	selectWindow("Red");
  	run("Duplicate...", "title=Red2");
	selectWindow("Blue");
  	run("Duplicate...", "title=Blue2");

			//Finds total blue bacteria
			selectWindow("Blue2");
				run("Mean...", "value=4");
				//run("Subtract Background...", "rolling=200");

				setMinAndMax(30, 1109);
				setAutoThreshold("Default dark no-reset");
				//setAutoThreshold("Default dark no-reset");	//uses this threshold to ensure nuclei are preserved and not 'chunky'
				waitForUser("Adjust the threshold to select your DAPI labelled bugs");
				run("Threshold...");
				setOption("BlackBackground", false);
				run("Convert to Mask");

				run("Analyze Particles...", "size=0.3-2.0 show=Masks  exclude"); //excludes nuclei
				rename("BluePoints");
				run("Duplicate...", "title=BluePoints2");
				run("Subtract...", "value=254");

			selectWindow("Red2");
				setAutoThreshold("MaxEntropy dark no-reset"); //uses this threshold to find total red bugs
				run("Threshold...");
				setOption("BlackBackground", false);
				run("Convert to Mask");

				run("Analyze Particles...", "size=0.3-5.5 show=Masks  exclude");
				rename("RedPoints");
				run("Duplicate...", "title=RedPoints2");
				run("Subtract...", "value=254");

		//Combines found blue bugs and found red bugs into one image
		imageCalculator("Add create", "RedPoints","BluePoints");
		selectWindow("Result of RedPoints");
		rename("TotalBugs");
		run("Multiply...", "value=255");

		//finds total bugs now
		run("Analyze Particles...", "size=0.3-5.5 show=Masks display exclude add");
		rename("MaskofBugs");
		
		print("Number of bacteria found: "+nResults);

		
  		//Sets up arrays needed for script
		BugArea=newArray(nResults);
		BlueMean=newArray(nResults);
 		BlueMax=newArray(nResults);
 		GreenMean=newArray(nResults);
 		GreenMax=newArray(nResults);
		RedMean=newArray(nResults);
 		RedMax=newArray(nResults);

		run("Clear Results");

 		
		//Measures blue channel
		selectWindow("Blue");
		roiManager("multi-measure measure_all");
		
		for (r=0; r<nResults();r++){
			BugArea[r] = getResult("Area",r);	
			BlueMean[r] = getResult("Mean",r);
			BlueMax[r] = getResult("Max",r);
			}

 		//Measures Green channel
 		run("Clear Results");
 		selectWindow("Green");
 		roiManager("multi-measure measure_all");
 		
 		for (bl=0; bl<nResults();bl++){
			GreenMean[bl] = getResult("Mean",bl);
			GreenMax[bl] = getResult("Max", bl);
 			}

		//Measures Red Chanenl
		run("Clear Results");
 		selectWindow("Red");
 		roiManager("multi-measure measure_all");
 		
 		for (bl=0; bl<nResults();bl++){
			RedMean[bl] = getResult("Mean",bl);
			RedMax[bl] = getResult("Max", bl);
 			}

			
    	//creates a loop for the number of nuclei found above, moves through each of the many arrays created above taking the corresponding line and changing it to a 
    	//new variable (with a similar name) to print out as a string into the spreadsheet created at the start. Repeats each line into the spreadsheet for each nuclei.
 		for (j=0 ; j<nResults ; j++) {  
    	
    		window =i+1;
    		bugnumber = j+1;   		
    		Bugarea = BugArea[j];
    		Bluemean = BlueMean[j];
       		Bluemax = BlueMax[j];
       		Greenmean = GreenMean[j];
       		Greenmax = GreenMax[j];
       		Redmean = RedMean[j];
       		Redmax = RedMax[j];
    		print(summaryFile,windowtitlenoext+"\t"+window+"\t"+bugnumber+"\t"+Bugarea+"\t"+Bluemean+"\t"+Bluemax+"\t"+Greenmean+"\t"+Greenmax+"\t"+Redmean+"\t"+Redmax);
  	   		} 

		//empties results table
  		run("Clear Results");

	//Outputing results files into subdirectory called 'Results.' The script will close and clear all relevant
	//information before moving onto the next file in the list, until finished.
	selectWindow("RedPoints");
  		saveAs("Tiff", resultsDir+ windowtitlenoext + "Red-thresh.tif");
	//selectWindow("Green");
  	//	saveAs("Tiff", resultsDir+ windowtitlenoext + "Green.tif");
	selectWindow("BluePoints");
  		saveAs("Tiff", resultsDir+ windowtitlenoext + "Blue-thresh.tif");
	selectWindow("MaskofBugs");
  		saveAs("Tiff", resultsDir+ windowtitlenoext + "TotalfoudnBugs.tif");
  	
	//saves the roi's found as defined above and empties the list before moving onto the next image
	roiManager("Save", resultsDir+ windowtitlenoext + "RoiSet.zip");
  	run("Clear Results");
  	roiManager("reset");
	
	print("Output files saved to directory");


//closes anything left open
	while (nImages>0) { 
		selectImage(nImages); 
        close(); 
      	} 
     	
}}

print("");
print("Batch Completed");
print("Total Runtime was:");
print((getTime()-start)/1000); 

//saves log
selectWindow("Log");
saveAs("Text", resultsDir+"Log.txt");

//exit message to notify user that the script has finished.
title = "Batch Completed";
msg = "Put down that coffee! Your analysis is finished";
waitForUser(title, msg);          
