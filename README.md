# ctdPostProcessing
Matlab code for processing and adjusting CTD cast
readCnv construct object and read seabird cnv file(s)
 
    Examples:
 
  r = readCnv  use uigetfile to select one or more files
  r = readCnv('fr26001.cnv')
 
  r =
    readCnv with properties:
 
             CTD_Type: 'SBE 9 '
      Seasave_Version: '3.2'
          Calibration: []
              Profile: '1'
              Datenum: 7.3640e+05
               Latnum: 11.4650
              Longnum: -23.0002
           Plateforme: 'THALASSA'
               Cruise: 'PIRATA-FR26'
              Sensors: [10 hashtable]
            Variables: [13 hashtable]
 
   r.Sensors
  
      'Frequency 0, Temperature'             '6083'
      'Frequency 1, Conductivity'            '4509'
      'Frequency 2, Pressure, Digiquar…'    '1263'
      'Frequency 3, Temperature, 2'          '6086'
      'Frequency 4, Conductivity, 2'         '4510'
      'A/D voltage 0, Oxygen, SBE 43'        '3261'
      'A/D voltage 1, Oxygen, SBE 43, 2'     '3265'
      'A/D voltage 2, Transmissometer,…'    'CTS1210DR'
      'A/D voltage 3, Fluorometer, WET…'    'FLRTD-1367'
      'A/D voltage 4, Altimeter'             '61768'
 
  keys(r.Variables)
  values(r.Variables)
  temp = r.Variables('t190C')
  temp(1:5)
     24.7254
     24.7250
     24.7248
     24.7244
     24.7246
 
