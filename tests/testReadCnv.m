classdef testReadCnv < TestCase
  %UNTITLED2 Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    cnvFilename;
  end
  
  methods
    
    function setUp(self)
      
      % get the location of directory test class dynaload
      pathStr = fileparts(mfilename('fullpath'));
      
      % construct test filename
      self.cnvFilename = fullfile(pathStr, 'test.cnv');
    end
    
    % Constructor
    %------------
    function self = readCnv(testMethod)
      % Creates the test case
      self = self@TestCase(testMethod);
    end % End of contructor
    
    %% tests files
    % --------------------------------------------------------------
    function testLocateCnvFile( self )
      d = readCnv(self.cnvFilename);
      msg = sprintf('can''t locate %s file', self.cnvFilename);
      assertEqual(d.fileName, self.cnvFilename , msg);
    end
    
  end
  
end

