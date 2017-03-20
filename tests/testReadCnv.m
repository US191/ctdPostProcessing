classdef testReadCnv < TestCase
  %testReadCnv
  % runxunit('tests')
  
  properties
    cnvFilename;
    cnvId
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
      self.cnvId = readCnv(self.cnvFilename);
      saveNc(self.cnvId);
      msg = sprintf('can''t locate %s file', self.cnvFilename);
      assertEqual(self.cnvId.fileName, self.cnvFilename , msg);
    end
    
    
    % tests header
    % ---------------
    %     ctdType
    %     seasaveVersion
    %     calibration
    %     profile
    %     date           % internal Matlab date representation
    %     julian
    %     latitude
    %     longitude
    %     plateforme
    %     cruise
    %     header      =  containers.Map('KeyType','int32','ValueType','char')
    %     varNames    =  containers.Map
    %     sensors     =  containers.Map
    function testGlobalAttributes( self )
      assertEqual(self.cnvId.plateforme, 'THALASSA');
      assertEqual(self.cnvId.cruise, 'PIRATA-FR26');
      assertEqual(self.cnvId.profile, '1');
      assertElementsAlmostEqual(self.cnvId.date, 736398.728414);
      assertElementsAlmostEqual(self.cnvId.julian, 24174.728414);
      assertElementsAlmostEqual(self.cnvId.latitude, 11.465000);
      assertElementsAlmostEqual(self.cnvId.longitude, -23.000167);
      assertEqual(self.cnvId.ctdType, 'SBE 9 ');
      assertEqual(self.cnvId.seasaveVersion, '3.2');
      assertEqual(self.cnvId.header(1), '* Sea-Bird SBE 9 Data File:')
      assertEqual(self.cnvId.header(302), '# file_type = ascii');
    end
    
  end
  
end

