# ctdPostProcessing

## Matlab code useful for

* **process.m:**  process raw Seabird CTD .hex data cast to .cnv file

* **readCnv.m:**  read seabird cnv file(s) using containers.Map object, save result as .mat or NetCDF 4 file

* **readNc.m:**   read NetCDF file

* **runtests.m:** unit tests

## Examples

### r = readCnv

without parameter use uigetfile to select a file

    >> cnv = readCnv('tests/test.cnv')

    cnv =
    Cruise:          PIRATA-FR26
    Plateforme:      THALASSA
    Profile:         1
    Date:            2016-03-09T17:28:55Z
    Julian:          24174.728414
    Latitude:        11.46500000
    Longitude:       -23.00016667
    CtdType:         SBE 9
    SeasaveVersion:  3.2

    varNames:  27×2 cell array

    'scan'         'Scan Count'
    'timeJ'        'Julian Days'
    'prDM'         'Pressure, Digiquartz [db]'
    'depSM'        'Depth [salt water, m]'
    't090C'        'Temperature [ITS-90, deg C]'
    't190C'        'Temperature, 2 [ITS-90, deg C]'
    'c0Sm'         'Conductivity [S/m]'
    'c1Sm'         'Conductivity, 2 [S/m]'
    'sbeox0V'      'Oxygen raw, SBE 43 [V]'
    'sbeox1V'      'Oxygen raw, SBE 43, 2 [V]'
    'sbox1dVdT'    'Oxygen, SBE 43, 2 [dov/dt]'
    'sbox0dVdT'    'Oxygen, SBE 43 [dov/dt]'
    'latitude'     'Latitude [deg]'
    'longitude'    'Longitude [deg]'
    'timeS'        'Time, Elapsed [seconds]'
    'flECO-AFL'    'Fluorescence, WET Labs ECO-AFL/FL [mg/m…'
    'CStarTr0'     'Beam Transmission, WET Labs C-Star [%]'
    'sbox0MmKg'    'Oxygen, SBE 43 [umol/kg], WS = 2'
    'sbox1MmKg'    'Oxygen, SBE 43, 2 [umol/kg], WS = 2'
    'sal00'        'Salinity, Practical [PSU]'
    'sal11'        'Salinity, Practical, 2 [PSU]'
    'sigma-00'     'Density [sigma-theta, kg/m^3]'
    'sigma-11'     'Density, 2 [sigma-theta, kg/m^3]'
    'svCM'         'Sound Velocity [Chen-Millero, m/s]'
    'svCM1'        'Sound Velocity, 2 [Chen-Millero, m/s]'
    'nbin'         'number of scans per bin'
    'flag'         'flag'

    sensors:  10×2 cell array

    'Frequency 0, Temperature'                     '6083'
    'Frequency 1, Conductivity'                    '4509'
    'Frequency 2, Pressure, Digiquartz with TC'    '1263'
    'Frequency 3, Temperature, 2'                  '6086'
    'Frequency 4, Conductivity, 2'                 '4510'
    'A/D voltage 0, Oxygen, SBE 43'                '3261'
    'A/D voltage 1, Oxygen, SBE 43, 2'             '3265'
    'A/D voltage 2, Transmissometer, WET Lab…'    'CTS1210DR'
    'A/D voltage 3, Fluorometer, WET Labs EC…'    'FLRTD-1367'
    'A/D voltage 4, Altimeter'                     '61768'

    'scan'                     [24 x 1]
    'timeJ'                    [24 x 1]
    'prDM'                     [24 x 1]
    'depSM'                    [24 x 1]
    't090C'                    [24 x 1]
    't190C'                    [24 x 1]
    'c0Sm'                     [24 x 1]
    'c1Sm'                     [24 x 1]
    'sbeox0V'                  [24 x 1]
    'sbeox1V'                  [24 x 1]
    'sbox1dVdT'                [24 x 1]
    'sbox0dVdT'                [24 x 1]
    'latitude'                 [24 x 1]
    'longitude'                [24 x 1]
    'timeS'                    [24 x 1]
    'flECO-AFL'                [24 x 1]
    'CStarTr0'                 [24 x 1]
    'sbox0MmKg'                [24 x 1]
    'sbox1MmKg'                [24 x 1]
    'sal00'                    [24 x 1]
    'sal11'                    [24 x 1]
    'sigma-00'                 [24 x 1]
    'sigma-11'                 [24 x 1]
    'svCM'                     [24 x 1]
    'svCM1'                    [24 x 1]
    'nbin'                     [24 x 1]
    'flag'                     [24 x 1]

    >> keys(cnv)

    ans =
     1×27 cell array
     Columns 1 through 7
     'CStarTr0'    'c0Sm'    'c1Sm'    'depSM'    'flECO-AFL'    'flag'    'latitude'
     Columns 8 through 14
     'longitude'    'nbin'    'prDM'    'sal00'    'sal11'    'sbeox0V'    'sbeox1V'
     ...

    >> values(cnv)

    ans =
     1×27 cell array
     Columns 1 through 5
     [24×1 double]    [24×1 double]    [24×1 double]    [24×1 double]    [24×1 double]
     ...

    >> cnv.t090C

    ans =
     24.7243
     24.7270
     24.7248
     24.7249
     24.7255
     24.7260
     24.7268
    ...

    >> cnv('t090C')    % same

    cnv.t090C(1:4)

    ans =
     24.7243
     24.7270
     24.7248
     24.7249

### get sensors name

    >> values(r.sensors)

    ans =
     1×10 cell array
     Columns 1 through 7
    '3261'    '3265'    'CTS1210DR'    'FLRTD-1367'    '61768'    '6083'    '4509'
    Columns 8 through 10
    '1263'    '6086'    '4510'

### get serial number for a sensor

    >> r.sensors.('A/D voltage 0, Oxygen, SBE 43')

    ans =
     3261

### save object to mat file

    >> saveObj(r)
     writing mat file: tests\test.mat

### save object to NetCDF file

    >> saveNc(r)

writing netcdf file: tests\test.nc

### use high level Matlab function to display and get data from NetCDF file

    >> ncdisp('tests/test.nc')
    Source:
           C:\git\ctdPostProcessing\tests\test.nc
    Format:
           netcdf4
    Global Attributes:
           filename       = 'tests/test.cnv'
           ctdtype        = 'SBE 9'
           seasaveversion = '3.2'
           plateforme     = 'THALASSA'
           cruise         = 'PIRATA-FR26'
           date_created   = '2017-04-06T14:51:38Z'
           created_by     = 'jgrelet'
           date_type      = 'OceanSITES profile data'
           format_version = '1.2'
           netcdf_version = '4.3.3.1'
           Conventions    = 'CF-1.6, OceanSITES-1.2'
           comment        = 'Data read from readCnv program'
           header         = '* Sea-Bird ....
           ...

    Dimensions:
           TIME      = 1
           LATITUDE  = 1
           LONGITUDE = 1
           DEPTH     = 24
    Variables:
      TIME
           Size:       1x1
           Dimensions: TIME
           Datatype:   double
           Attributes:
                       standard_name = 'time'
                       long_name     = 'Time of measurements'
                       units         = 'days since 1950-01-01T00:00:00Z'
                       _FillValue    = -9999
      LATITUDE
           Size:       1x1
           Dimensions: LATITUDE
           Datatype:   double
           Attributes:
                       standard_name = 'latitude'
                       long_name     = 'Station latitude'
                       units         = 'degrees_north'
                       _FillValue    = -9999
      LONGITUDE
           Size:       1x1
           Dimensions: LONGITUDE
           Datatype:   double
           Attributes:
                       standard_name = 'longitude'
                       long_name     = 'Station longitude'
                       units         = 'degrees_east'
                       _FillValue    = -9999
    Groups:
      /raw/
          Attributes:
                   comment = 'This group contains raw data'
          Variables:
              scan
                   Size:       24x1
                   Dimensions: /DEPTH,/TIME
                   Datatype:   double
                   Attributes:
                               name       = 'scan'
                               long_name  = 'Scan Count'
                               _FillValue = -9999
              timeJ
                   Size:       24x1
                   Dimensions: /DEPTH,/TIME
                   Datatype:   double
                   Attributes:
                               name       = 'timeJ'
                               long_name  = 'Julian Days'
                               _FillValue = -9999
              prDM
                   Size:       24x1
                   Dimensions: /DEPTH,/TIME
                   Datatype:   double
                   Attributes:
                               name       = 'prDM'
                               long_name  = 'Pressure, Digiquartz'
                               units      = 'db'
                               _FillValue = -9999
              depSM
                   Size:       24x1
                   Dimensions: /DEPTH,/TIME
                   Datatype:   double
                   Attributes:
                               name       = 'depSM'
                               long_name  = 'Depth'
                               units      = 'salt water, m'
                               _FillValue = -9999
              t090C
                   Size:       24x1
                   Dimensions: /DEPTH,/TIME
                   Datatype:   double
                   Attributes:
                               name       = 't090C'
                               long_name  = 'Temperature'
                               units      = 'ITS-90, deg C'
                               _FillValue = -9999
          ...
          ...
          % end of file

    >> t = ncread('tests/test.nc', 'raw/t090C')

    t =
     24.7243
     24.7270
     24.7248
     24.7249
     ...

### nc = readNc

use uigetfile to select file

    >> nc = readNc('tests/test.nc')

    nc =

    Global Attributes:

    seasaveversion      :    3.2
    comment             :    Data read from readCnv program
    Conventions         :    CF-1.6, OceanSITES-1.2
    filename            :    C:\git\ctdPostProcessing\tests\test.cnv
    created_by          :    jgrelet
    date_created        :    2017-03-24T10:36:58Z
    ctdtype             :    SBE 9
    format_version      :    1.2
    cruise              :    PIRATA-FR26
    header              :    * Sea-Bird SBE 9 Data File: ...
                            ...
    plateforme          :    THALASSA
    netcdf_version      :    4.3.3.1
    date_type           :    OceanSITES profile data

    Groups:

    /root/
        LATITUDE
        LONGITUDE
        TIME
    /filtered/
    /raw/
        CStarTr0
        c0Sm
        c1Sm
        depSM
        flECO-AFL
        flag
        latitude
        longitude
        nbin
        prDM
        sal00
        sal11
    ....

    >> nc.root.LATITUDE

    ans =
     11.4650

    >> nc.raw.sal00(1:4)

    ans =
     35.7712
     35.7715
     35.7717
     35.7717

### Run test cases

    >> runtests
    Running TReadAll
    ......
    Done TReadAll