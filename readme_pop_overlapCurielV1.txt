Readme file for Areal Interpolation script.
By: John Curiel (at University of North Carolina Chapel Hill as of June 4, 2019)  

The following script is used to solve areal interpolation problems via population overlap. In order to use this
script, you will need three different types of information: the two sets of polygons of interest (i.e. districts
at time 1 and districts at time 2, ZCTAs with legislative districts, precincts and ZCTAs, etc.) and the population
tabulation districts (i.e. Census Block Groups or Census Blocks). By finding the three way intersection between the
two polygons of interest and population tabulation units, the assumptions made as to population distribution are 
minimized. Note that this methods therefore depends on the quality of the tabulation units of interest. Within the 
American context, this works fairly well, though one will need to ascertain data quality for individual non-American
nations as the need arises. If you have any concerns as to the script's applicability, please contact John A. Curiel
at jcuriel.unc@gmail.com. If a response does not reach you in three days, I can be reached via phone at 
(815) 355-8352. 

How to use:
The following code is used to create a graphic user interface(GUI) in the form of a python toolbox. Therefore, 
the user will need to do the following to make use of this GUI:
	1) Open the text file, pop_overlap_substate_CurielV1.txt 
	2) ctrl + a to select all of the written code. 
	3) copy code 
	4) open either ArcMap or ArcCatalog
	5) Open the catalog sidebar 
	6) Right click on the folder that the user would like to have the python toolbox. Select new, then click
	python toolbox
	7) Name the python toolbox. 
	8) Right click on the python toolbox. Select edit
	9) A Notepad window will open up. Ctrl + A to select all, then erase.
	10) Paste in the pop_overlap_substate_CurielV1.txt text.
	11) Save the toolbox entered text. Close notepad
	12) Click the plus sign next to the python toolbox. Select the script to use. 


Instructions for fields: 

Enter first shapefile 1: This refers to the first polygon shapefile of interest that the user would like to find overlap with. 

Enter Census block shapefile: Enter in a shapefile for census tabulation. Within the American context, this equates 
to either Census blocks or Census Block Groups. The benefit of using the Census Block Groups is that these data also
have demograhpic collected data, such as race and income, that is not true of census blocks. 

Enter Second Shapefile: Enter in the second shapefile of interest that the user would like to interpolate onto. 

Choose a Workspace: Select a folder that the files should be stored in. Note that it is best to create a folder 
solely for the results of interest. If you have not done so already, proper folder/file structure will go a long way
towards increasing quality of life. 

Subnation code for CBGs Field (optional): If you are using a census tabulation unit that applies nation wide, but do
not need to do so given that the interpolation is statewide or less, then choose a field to subset on. This will save
much time in the event that your data has not been subsetted. If it already has, then leave this field blank.

CRS reference shapefile (optional): This field can be entered used in the event that the second shapefile entered is
not defined with a Coordinate Reference System. The field works such that if you know that your undefined data has the
same CRS as some other shapefile that you have used, then simply select the shapefile with a defined CRS, and then the
script will pull out the CRS info and apply it as needed. If the CRS is fine, then leave this field blank. 

Field for Pop Data: This field provides the names of all of the columns within the Census tabulation data provided. 
Select the numeric data that refers to the population of interest. Within US Census data, this will often refer to
POP2000 or POP2010 for example. 

Subnation field for second shapefile (optional): This field can be used in the event that the second shapefile needs
to be subsetted given that the analysis is subnational. In this event, all of the names of the columns will be 
provided. From there, find the appropriate field to subset on. 

State (optional): If the subnation field for second shapefile is entered, then the list of all values for that field
will be offered to the user as potential options. The user then selects the value of interest that should be used 
as the subset for the second shapefile. 

Chosen CBG subnational unit (optional): IF the user earlier chose a field to subset the census tabulation by, then
this field will appear with all of the values to subset on. 

ID Field for first shapefile: The user is provided with all of the column names for the first shapefile. The user 
can then use the provided fields to provide the unique polygon IDs in which dyads can eventually be created. Note that
it is crucial that the ID field be recognizeable and applicable to other data for analysis. For example, while it is 
the case that FIDs are provided for polygons, this is probably not very helpful if the user is trying to determine 
how to weight precincts given that they are split between multiple districts. Therefore, find and use the universal 
precinct name. 

ID Field for the second shapefile: The unique and analytically useable ID field for the second shapefile of interest 
for areal interpolation. The same warning applies as above regarding correct field to use. 


#####Files that will be produced: 

1. CB_prj - These are files related to the projected census tabulation polygons of interest. 

2. State_leg_prj - These files relate to the projected first shapefile provided 

3. StateCBshp - These files refer to the finalized projected (and possibly subsetted) census tabulation data. 

4. US_prj - These files refer to the projected polygon data for the second shapefile inserted. 

5. all_merge1 - These files relate to the unionized data between the first shapefile and Census tabulation data. 
These data contain all of the filled in gaps (i.e. empty polygons) in the event that error checking needs to be 
conducted later on. 

6. all_merge2 - These files are the cleaned unionized data between the first shapefile and census data. Also kept for 
error checking and in the event that the user seeks to analyze and map just the population and demographics of the 
first shapefile. 

7. all_merge3- The polygon data related to the three way intersection between the unionized first shapefile, Census 
data, and second shapefile. These data still contain potential polygon gaps for later error checking if needed. Note
That at this level should a poor field have been chosen by the user, it is possible to take these data and employ R 
to finish the analysis of interest. 

8. all_merge4 - The cleaned (i.e. no polygon gap) data for the three way intersection. Like all_merge3, this data can
be used should mapping be of interest for the user, or the R script that weights and calculates demographics of 
interest. 

9. shp1sum_table.dbf - The collapsed population data for the first shapefile. All data contains the population by the
ID provided by the user. In DBF format. 

10. shp2sum_table.dbf - The collapsed population data for the second shapefile. All data contains the population by 
the ID provided by the user. In DBF format.     

11. shpdyadsum_table.dbf - The collapsed population data for the overlapping dyads between the first and second
shapefiles of interest. In DBF format.  

12. all_table1.dbf - The final table of interest. The table informs the user of all of the populattion data by dyad,
first shapefile and second shapefile. The data's columns are as follows: 
	a) SHP2_ID - The ID name of the second shapefile 
	b) SHP1_ID - The ID name of the first shapefile 
	c) POP1 - The total weighted population within the dyad, the combination of SHP2_ID and SHP1_ID
	d) POP2 - The weighted aggregate population of everyone within the first shapefile provided by the user. 
	e) POP3 - The weighted aggregate population of everyone within the second shapefile provided by the user. 
	f) OVER_SHP1 - The percentage of the first shapefile's population that lives within the specified area of the
	second shapefile (i.e. the value/name provided in SHP2_ID). When allocating and weighting data related to 
	the first shapefile (i.e. how to apportion democratic voters from a precinct divided between two districts)
	then use the value from OVER_SHP1 for these weighting purposes. Note that these data are scaled between 0-100.
	Therefore, divide these results by 100 for weighting. 
	g) OVER_SHP2 - The percentage of the population of those within the area of the specified area from the second
	shapefile that arises from the area from the first shapefile's specified area. Note that these values will be
	Greater than or equal to the values from the OVER_SHP1 field. Only in the event that the borders between the 
	first and second shapefile areas be perfectly coterminuous would both equal 100. As mentioned above, the 
	values range from 0-100 for percentage, so divide by 100 for weighting purposes.   
  