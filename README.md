# ctdPostProcessing
Matlab code for :
process.m: processing raw Seabird CTD .hex cast to .cnv file
readCnv.m: read seabird cnv file(s) using containers.Map object
 
    Examples:
 
  r = readCnv  use uigetfile to select one or more files
  r = readCnv('C:\git\ctdPostProcessing\examples\fr26\data\cnv\dfr26001.cnv')
  r = 

	cruise:          PIRATA-FR26
	plateforme:      THALASSA
	profile:         1
	date:            736398.728414
	julian:          24174.728414
	latitude:        11.465000
	longitude:       -23.000167
	ctdType:         SBE 9 
	seasaveVersion:  3.2

varNames:  27×2 cell array

    'scan'          'Scan Count'                                
    'timeJ'         'Julian Days'                               
    'prDM'          'Pressure, Digiquartz [db]'                 
    'depSM'         'Depth [salt water, m]'                     
    't090C'         'Temperature [ITS-90, deg C]'               
    't190C'         'Temperature, 2 [ITS-90, deg C]'            
    'c0S/m'         'Conductivity [S/m]'                        
    'c1S/m'         'Conductivity, 2 [S/m]'                     
    'sbeox0V'       'Oxygen raw, SBE 43 [V]'                    
    'sbeox1V'       'Oxygen raw, SBE 43, 2 [V]'                 
    'sbox1dV/dT'    'Oxygen, SBE 43, 2 [dov/dt]'                
    'sbox0dV/dT'    'Oxygen, SBE 43 [dov/dt]'                   
    'latitude'      'Latitude [deg]'                            
    'longitude'     'Longitude [deg]'                           
    'timeS'         'Time, Elapsed [seconds]'                   
    'flECO-AFL'     'Fluorescence, WET Labs ECO-AFL/FL [mg/m^3]'
    'CStarTr0'      'Beam Transmission, WET Labs C-Star [%]'    
    'sbox0Mm/Kg'    'Oxygen, SBE 43 [umol/kg], WS = 2'          
    'sbox1Mm/Kg'    'Oxygen, SBE 43, 2 [umol/kg], WS = 2'       
    'sal00'         'Salinity, Practical [PSU]'                 
    'sal11'         'Salinity, Practical, 2 [PSU]'              
    'sigma-é00'     'Density [sigma-theta, kg/m^3]'             
    'sigma-é11'     'Density, 2 [sigma-theta, kg/m^3]'          
    'svCM'          'Sound Velocity [Chen-Millero, m/s]'        
    'svCM1'         'Sound Velocity, 2 [Chen-Millero, m/s]'     
    'nbin'          'number of scans per bin'                   
    'flag'          'flag'                                      

sensors:  10×2 cell array

    'Frequency 0, Temperature'                         '6083'      
    'Frequency 1, Conductivity'                        '4509'      
    'Frequency 2, Pressure, Digiquartz with TC'        '1263'      
    'Frequency 3, Temperature, 2'                      '6086'      
    'Frequency 4, Conductivity, 2'                     '4510'      
    'A/D voltage 0, Oxygen, SBE 43'                    '3261'      
    'A/D voltage 1, Oxygen, SBE 43, 2'                 '3265'      
    'A/D voltage 2, Transmissometer, WET Labs C-…'    'CTS1210DR' 
    'A/D voltage 3, Fluorometer, WET Labs ECO-AF…'    'FLRTD-1367'
    'A/D voltage 4, Altimeter'                         '61768'     

  27×2 cell array

    'scan'          'scan'      
    'timeJ'         'timeJ'     
    'prDM'          'prDM'      
    'depSM'         'depSM'     
    't090C'         't090C'     
    't190C'         't190C'     
    'c0S/m'         'c0S/m'     
    'c1S/m'         'c1S/m'     
    'sbeox0V'       'sbeox0V'   
    'sbeox1V'       'sbeox1V'   
    'sbox1dV/dT'    'sbox1dV/dT'
    'sbox0dV/dT'    'sbox0dV/dT'
    'latitude'      'latitude'  
    'longitude'     'longitude' 
    'timeS'         'timeS'     
    'flECO-AFL'     'flECO-AFL' 
    'CStarTr0'      'CStarTr0'  
    'sbox0Mm/Kg'    'sbox0Mm/Kg'
    'sbox1Mm/Kg'    'sbox1Mm/Kg'
    'sal00'         'sal00'     
    'sal11'         'sal11'     
    'sigma-é00'     'sigma-é00' 
    'sigma-é11'     'sigma-é11' 
    'svCM'          'svCM'      
    'svCM1'         'svCM1'     
    'nbin'          'nbin'      
    'flag'          'flag'      
 
 keys(r.varNames)
 values(r.varNames)
 temp = r('t190C');
 temp(1:5)

ans =

   24.7249
   24.7268
   24.7250
   24.7252
   24.7256
 
