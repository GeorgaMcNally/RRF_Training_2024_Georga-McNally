/*******************************************************************************
							Template Main do-file							   
*******************************************************************************/

	* Set version
	version 18

	* Set project global(s)	
	// User: you 
	display "`wb612454'" 	//Check username and copy to set project globals by user
	
	* Add file paths to DataWork folder and the Github folder for RRF2024
	if "`wb612454'" == "" {
        global onedrive "C:\Users\wb612454\OneDrive - WBG\Career Development\RRF 2024\DataWork"
		global github 	"C:\Users\wb612454\Downloads\RRF 2024\RRF_Training_2024_Georga-McNally"
    }
	
	
	* Set globals for sub-folders 
	global data 	"${onedrive}/Data"
	global code 	"${github}/Stata/Code"
	global outputs 	"${github}/Stata/Outputs"
	
	sysdir set PLUS "${Code}/ado"


/* Install packages 
	local user_commands	ietoolkit iefieldkit winsor sumstats estout keeporder grc1leg2 //Add required user-written commands

	foreach command of local user_commands {
	   capture which `command'
	   if _rc == 111 {
		   ssc install `command'
	   }
	}
*/

ssc install ietoolkit
ssc install iefieldkit
ssc install winsor
ssc install sumstats
ssc install estout
ssc install keeporder
ssc install grc1leg2

	* Run do files 
	* Switch to 0/1 to not-run/run do-files  
	if (1) do "${code}/01-processing-data.do"
	if (1) do "${code}/02-constructing-data.do"
	if (1) do "${code}/03-analyzing-data.do"
	


* End of do-file!	