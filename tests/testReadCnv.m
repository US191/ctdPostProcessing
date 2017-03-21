classdef testReadCnv < TestCase
  %testReadCnv
  % runxunit('tests')
  
  properties
    cnvFilename;
    cnvObj
  end
  
  methods
    
    % Constructor
    %------------
    function self = testReadCnv(testMethod)
      self = self@TestCase(testMethod);
    end
    
    function setUp(self)
      
      % get the location of directory test class dynaload
      pathStr = fileparts(mfilename('fullpath'));
      
      % construct test filename
      self.cnvFilename = fullfile(pathStr, 'test.cnv');
      self.cnvObj = readCnv(self.cnvFilename, false);
      saveNc(self.cnvObj);
      msg = sprintf('can''t locate %s file', self.cnvFilename);
      assertEqual(self.cnvObj.fileName, self.cnvFilename , msg);
    end
    
    function testProperties( self )
      assertEqual(self.cnvObj.Plateforme, 'THALASSA');
      assertEqual(self.cnvObj.Cruise, 'PIRATA-FR26');
      assertEqual(self.cnvObj.Profile, '1');
      assertElementsAlmostEqual(self.cnvObj.Date, 736398.728414);
      assertElementsAlmostEqual(self.cnvObj.Julian, 24174.728414);
      assertElementsAlmostEqual(self.cnvObj.Latitude, 11.465000);
      assertElementsAlmostEqual(self.cnvObj.Longitude, -23.000167);
      assertEqual(self.cnvObj.CtdType, 'SBE 9 ');
      assertEqual(self.cnvObj.SeasaveVersion, '3.2');
      assertEqual(self.cnvObj.Header(1), '* Sea-Bird SBE 9 Data File:')
      assertEqual(self.cnvObj.Header(302), '# file_type = ascii');
    end
    
    function testVarNames(self)
      theKeys = {'scan','timeJ','prDM','depSM','t090C','t190C','c0Sm','c1Sm',...
        'sbeox0V','sbeox1V','sbox1dVdT','sbox0dVdT','latitude','longitude',...
        'timeS','flECO-AFL','CStarTr0','sbox0MmKg','sbox1MmKg','sal00','sal11',...
        'sigma-00','sigma-11','svCM','svCM1','nbin','flag'};
      theValues = {'Scan Count','Julian Days','Pressure, Digiquartz [db]','Depth [salt water, m]',...
        'Temperature [ITS-90, deg C]','Temperature, 2 [ITS-90, deg C]','Conductivity [S/m]',...
        'Conductivity, 2 [S/m]','Oxygen raw, SBE 43 [V]','Oxygen raw, SBE 43, 2 [V]',...
        'Oxygen, SBE 43, 2 [dov/dt]','Oxygen, SBE 43 [dov/dt]','Latitude [deg]',...
        'Longitude [deg]','Time, Elapsed [seconds]','Fluorescence, WET Labs ECO-AFL/FL [mg/m^3]',...
        'Beam Transmission, WET Labs C-Star [%]','Oxygen, SBE 43 [umol/kg], WS = 2',...
        'Oxygen, SBE 43, 2 [umol/kg], WS = 2','Salinity, Practical [PSU]',...
        'Salinity, Practical, 2 [PSU]','Density [sigma-theta, kg/m^3]',...
        'Density, 2 [sigma-theta, kg/m^3]','Sound Velocity [Chen-Millero, m/s]',...
        'Sound Velocity, 2 [Chen-Millero, m/s]','number of scans per bin','flag'};
      
      theMap = containers.Map( theKeys, theValues,'UniformValues',true);
      
      for k = keys(theMap)
        key = char(k);
        assertTrue(isKey(self.cnvObj.varNames,key), ...
          sprintf('The specified key: (%s) is not present in this container.',key));
        assertEqual(theMap(key), self.cnvObj.varNames(key), ...
          sprintf('Value: (%s) is not equal for key: (%s) in this container.',...
          key, theMap(key)));
      end
    end
    
    function testSensors(self)
      theKeys = {'Frequency 0, Temperature','Frequency 1, Conductivity',...
        'Frequency 2, Pressure, Digiquartz with TC',...
        'Frequency 3, Temperature, 2','Frequency 4, Conductivity, 2',...
        'A/D voltage 0, Oxygen, SBE 43','A/D voltage 1, Oxygen, SBE 43, 2',...
        'A/D voltage 2, Transmissometer, WET Labs C-Star',...
        'A/D voltage 3, Fluorometer, WET Labs ECO-AFL/FL','A/D voltage 4, Altimeter'};
      theValues = {'6083','4509','1263','6086','4510','3261','3265','CTS1210DR',...
        'FLRTD-1367','61768'};
      theMap = containers.Map( theKeys, theValues,'UniformValues',true);
      
      for k = keys(theMap)
        key = char(k);
        assertTrue(isKey(self.cnvObj.sensors, key), ...
          sprintf('The specified key: (%s) is not present in this container.',key));
        assertEqual(theMap(key), self.cnvObj.sensors(key), ...
          sprintf('Value: (%s) is not equal for key: (%s) in this container.',...
          key, theMap(key)));
      end
    end
    
    % test inherited keys/values
    function testData(self)
      data = self.cnvObj;
      for k = keys(data)
        key = char(k);
        % test notations: data.sal00 and data('sal00')
        assertEqual(size(data.(key)), size(data(key)),...
          sprintf('Invalid size for key: (%s).',key));
      end
      % test logical indexing
      assertEqual(data.scan(1:4),[-234;504;2324;2723]);
    end
    
  end
  
end

