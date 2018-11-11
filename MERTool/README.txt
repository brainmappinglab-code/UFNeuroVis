------------------SYSTEM REQUIREMENTS------------------
1. Follow instructions in pdf in this folder
	1a. must install .NET
	1b. must install Visual C++
	1c. Install FHC Guideline 4000 Exporter Tool.
		ftp://ftp.termobit.ro/Public/Exporter/
		Download Exporter__1.3.2.zip
		Login: fhcguest
		Password: ghcguest
2. Navigate to C:\Program Files (x86)\FHC\ and add "FHC Exporter folder to full access permissions
2. Include FHC_matlablib in MATLAB path.
3. Include C:\Program Files (x86)\FHC\FHC Exporter\Matlab in MATLAB path.
4. Include ...\MER-to-xls\data in MATLAB path

------------------FILE REQUIREMENTS--------------------
1. DBS data in one .dbs or .mat file.
2. CRW data in one .crw file
3. ONLY relevant APM files or GLR file in folder

NOTE: .dbs/.mat, .crw, and .apm/.glr can share the same folder.
NOTE: All .apm/.glr files in folder will be taken as input.

---------------------OPERATION-------------------------
1. Run MER_gui from MATLAB command line (">> MER_gui")
2. Use buttons and UI file prompts to select:
	a) .dbs/.mat file
	b) .crw file
	c) folder containing .apm/.glr file(s)
	d) output name, filetype, and destination (optional, required for conversion to .xls)
	NOTE: Program will attempt to predict file selections if all files are in the same folder.
3. Check/uncheck radio buttons for functions
4. Click "Convert" button
5. Wait for progress bar to complete.

-------------------PLOT OPERATION-----------------------
- Click points on trajectory axis to view matching clinical data and recording data.
- Use drop-down menu to change recording data display style
- Click "Export" button to export struct containing recording data from selected point to "...\MER-to-xls"