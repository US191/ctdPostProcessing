classdef testReadNc < TestCase
  %testReadCnv
  % runxunit('tests')
  
  properties
    ncFilename;
    ncid
  end
  
  methods
    
    % Constructor
    %------------
    function self = testReadNc(testMethod)
      self = self@TestCase(testMethod);
    end
    
    function setUp(self)
      
      % get the location of directory test class dynaload
      pathStr = fileparts(mfilename('fullpath'));
      
      % construct test filename
      self.ncFilename = fullfile(pathStr, 'test.nc');
      self.ncid = netcdf.open(self.ncFilename, 'NOWRITE');
%       assertExceptionThrown(netcdf.open('dummy.nc', 'NOWRITE'),...
%         'MATLAB:imagesci:validate:fileOpen');
    end
    
    function tearDown(self)
      netcdf.close(self.ncid);
    end

    
    % tests header
    % ---------------
    % seasaveVersion = '3.2'
    % plateforme     = 'THALASSA'
    % cruise         = 'PIRATA-FR26'
    % date_created   = '2017-03-20T12:04:10Z'
    % created_by     = 'jgrelet'
    % data_type      = 'OceanSITES profile data'
    % format_version = '1.2'
    % netcdf_version = '4.3.3.1'
    % Conventions    = 'CF-1.6, OceanSITES-1.2'
    % comment        = 'Data read from readCnv program'
    % header         = '* Sea-Bird SBE 9 Data File:
    function testGlobalAttributes( self )
      assertEqual(ncreadatt(self.ncFilename,'/', 'ctdType'), 'SBE 9 ');
      assertEqual(ncreadatt(self.ncFilename,'/', 'plateforme'), 'THALASSA');
      assertEqual(ncreadatt(self.ncFilename,'/', 'cruise'), 'PIRATA-FR26');
      assertEqual(ncreadatt(self.ncFilename,'/', 'date_type'), 'OceanSITES profile data');
      assertEqual(ncreadatt(self.ncFilename,'/', 'created_by'), 'jgrelet');
      assertEqual(ncreadatt(self.ncFilename,'/', 'format_version'), '1.2');
      assertEqual(ncreadatt(self.ncFilename,'/', 'netcdf_version'), '4.3.3.1');
      assertEqual(ncreadatt(self.ncFilename,'/', 'Conventions'), 'CF-1.6, OceanSITES-1.2');
      assertEqual(ncreadatt(self.ncFilename,'/', 'comment'), 'Data read from readCnv program');
      header = ncreadatt(self.ncFilename,'/', 'header');
      assertTrue(logical(strfind(header, '* Sea-Bird SBE 9 Data File:')));
    end
    
   
    
  end
  
end

