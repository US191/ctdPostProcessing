classdef readCnv < containers.Map & handle
  %readCnv construct object and read seabird cnv file
  %
  %   Examples:
  %
  % r = readCnv  use uigetfile to select a file
  % r = readCnv('tests/test.cnv')
  % read file: tests/test.cnv
  %
  % r =
  %
  % 	Cruise:          PIRATA-FR26
  % 	Plateforme:      THALASSA
  % 	Profile:         1
  % 	Date:             736398.728414
  % 	Julian:          24174.728414
  % 	Latitude:        11.465000
  % 	Longitude:       -23.000167
  % 	CtdType:         SBE 9
  % 	SeasaveVersion:  3.2
  %   Header:          * Sea-Bird SBE 9 Data File:
  %                    * FileName = C:\SEASOFT\PIRATA-FR26\data\fr26001.hex
  %                    * Software Version Seasave V 7.23.2
  %                    * Temperature SN = 6083
  %                    ...
  %
  % varNames: 27×2 cell array
  %
  %     'scan'          'Scan Count'
  %     'timeJ'         'Julian Days'
  %     'prDM'          'Pressure, Digiquartz [db]'
  %     'depSM'         'Depth [salt water, m]'
  %     't090C'         'Temperature [ITS-90, deg C]'
  %     't190C'         'Temperature, 2 [ITS-90, deg C]'
  %     'c0S/m'         'Conductivity [S/m]'
  %     'c1S/m'         'Conductivity, 2 [S/m]'
  %     'sbeox0V'       'Oxygen raw, SBE 43 [V]'
  %     'sbeox1V'       'Oxygen raw, SBE 43, 2 [V]'
  %     'sbox1dV/dT'    'Oxygen, SBE 43, 2 [dov/dt]'
  %     'sbox0dV/dT'    'Oxygen, SBE 43 [dov/dt]'
  %     'latitude'      'Latitude [deg]'
  %     'longitude'     'Longitude [deg]'
  %     'timeS'         'Time, Elapsed [seconds]'
  %     'flECO-AFL'     'Fluorescence, WET Labs ECO-AFL/FL [mg/m^3]'
  %     'CStarTr0'      'Beam Transmission, WET Labs C-Star [%]'
  %     'sbox0Mm/Kg'    'Oxygen, SBE 43 [umol/kg], WS = 2'
  %     'sbox1Mm/Kg'    'Oxygen, SBE 43, 2 [umol/kg], WS = 2'
  %     'sal00'         'Salinity, Practical [PSU]'
  %     'sal11'         'Salinity, Practical, 2 [PSU]'
  %     'sigma-é00'     'Density [sigma-theta, kg/m^3]'
  %     'sigma-é11'     'Density, 2 [sigma-theta, kg/m^3]'
  %     'svCM'          'Sound Velocity [Chen-Millero, m/s]'
  %     'svCM1'         'Sound Velocity, 2 [Chen-Millero, m/s]'
  %     'nbin'          'number of scans per bin'
  %     'flag'          'flag'
  %
  % sensors: 10×2 cell array
  %
  %     'Frequency 0, Temperature'                         '6083'
  %     'Frequency 1, Conductivity'                        '4509'
  %     'Frequency 2, Pressure, Digiquartz with TC'        '1263'
  %     'Frequency 3, Temperature, 2'                      '6086'
  %     'Frequency 4, Conductivity, 2'                     '4510'
  %     'A/D voltage 0, Oxygen, SBE 43'                    '3261'
  %     'A/D voltage 1, Oxygen, SBE 43, 2'                 '3265'
  %     'A/D voltage 2, Transmissometer, WET Labs C-…'    'CTS1210DR'
  %     'A/D voltage 3, Fluorometer, WET Labs ECO-AF…'    'FLRTD-1367'
  %     'A/D voltage 4, Altimeter'                         '61768'
  %
  % 27×2 cell array
  %
  %     'scan'          [2022×1 double]
  %     'timeJ'         [2022×1 double]
  %     'prDM'          [2022×1 double]
  %     'depSM'         [2022×1 double]
  %     't090C'         [2022×1 double]
  %     't190C'         [2022×1 double]
  %     'c0S/m'         [2022×1 double]
  %     'c1S/m'         [2022×1 double]
  %     'sbeox0V'       [2022×1 double]
  %     'sbeox1V'       [2022×1 double]
  %     'sbox1dV/dT'    [2022×1 double]
  %     'sbox0dV/dT'    [2022×1 double]
  %     'latitude'      [2022×1 double]
  %     'longitude'     [2022×1 double]
  %     'timeS'         [2022×1 double]
  %     'flECO-AFL'     [2022×1 double]
  %     'CStarTr0'      [2022×1 double]
  %     'sbox0Mm/Kg'    [2022×1 double]
  %     'sbox1Mm/Kg'    [2022×1 double]
  %     'sal00'         [2022×1 double]
  %     'sal11'         [2022×1 double]
  %     'sigma-é00'     [2022×1 double]
  %     'sigma-é11'     [2022×1 double]
  %     'svCM'          [2022×1 double]
  %     'svCM1'         [2022×1 double]
  %     'nbin'          [2022×1 double]
  %     'flag'          [2022×1 double]
  %
  % r.Latitude
  %    11.4650
  % r.Date
  %    7.3640e+05
  % keys(r)
  % values(r)
  % temp = r('t190C')
  % temp(1:5)
  %    24.7254
  %    24.7250
  %    24.7248
  %    24.7244
  %    24.7246
  %    ...
  % keys(r.varNames)
  % r.varNames.t090C
  %    Temperature [ITS-90, deg C]
  % r.varNames.('t090C')
  % r.varNames.sbeox1dOVdT
  %    Temperature [ITS-90, deg C]
  % r.varNames('sbeox1dOVdT')
  %    Temperature [ITS-90, deg C]
  % keys(r.sensors)
  % values(r.sensors)
  % r.sensors.('A/D voltage 0, Oxygen, SBE 43')
  %    3261
  % % save objet in mat file
  % saveObj(r)
  % % save object in NetCDF4 file under raw group
  % saveNc(r)
  % ncdisp('C:\git\ctdPostProcessing\examples\fr26\data\nc\dfr26001.nc')
  % ncread('C:\git\ctdPostProcessing\examples\fr26\data\nc\dfr26001.nc','raw/t090C')
  % r.Header(:)
  % * Sea-Bird SBE 9 Data File:
  % * FileName = C:\SEASOFT\PIRATA-FR26\data\fr26001.hex
  % * Software Version Seasave V 7.23.2
  % * Temperature SN = 6083
  % ...
  % % run unit test framework :
  % tuntests
  %
  % TODOS:
  % add interactive plots with QC
  %
  % J. Grelet IRD US191 IMAGO - 2017
  
  properties   (Access = private)
    fileName
    echo        = true               % default
    varList     =  containers.Map
    % the iteration order over containers.Maps is ordered.
    % these properties are used to store keys
    varNamesList = {}
    sensorsList  = {}
    headerInd    = 1
    dimension
  end
  
  properties (SetAccess = public)
    CtdType
    SeasaveVersion
    Calibration
    Profile
    Date           % internal Matlab date representation
    Julian
    Latitude
    Longitude
    Plateforme
    Cruise
    Header      =  containers.Map('KeyType','int32','ValueType','char')
    varNames    =  containers.Map
    sensors     =  containers.Map
  end
  
  methods % public methods
    
    % constructor
    % --------------------------------
    function self = readCnv(fileName, varargin)
      
      % pre initialization - select filename
      if nargin < 1 || isempty(fileName)
        [fileName, pathName] = uigetfile({'*.cnv','Seabird cnv (*.cnv)'},...
          'Select file');
        if isnumeric(fileName)
          if fileName == 0
            error('readCnv: empty fileName');
          end
        end
        self.fileName = fullfile(pathName, fileName);
      else
        self.fileName = fileName;
      end
      if nargin == 2 && islogical(varargin{1})
        self.echo = varargin{1};
      end
      
      % read and extract data from file
      read(self);
    end % end of constructor
    
    function fileName = get.fileName(self)
      fileName = self.fileName;
    end
    
    % read files and fill containers.Map
    % -----------------------------------------
    function  read(self)
      
      if self.echo
        fprintf(1, 'read file: %s\n', self.fileName);
      end
      [fid, errmsg] = fopen(self.fileName);
      if fid == -1
        error('readCnv:read', 'error: %s', errmsg);
      end
      
      % read the header
      while ~feof(fid)
        tline = fgetl(fid);
        % disp(tline)
        if ~isempty(strfind(tline,'*END'))  % end of header
          break;
        end
        
        % store each header line in map
        self.Header(self.headerInd) = tline;
        self.headerInd = self.headerInd + 1;
        
        % extract CTD type
        % ex: * Sea-Bird SBE 9 Data File:
        % ex: * Sea-Bird SBE19plus Data File:
        match = regexp( tline,...
          '^*\s*Sea-Bird\s*(.+?)\s*Data File:', 'tokens');
        if ~isempty(match)
          self.CtdType = match{1}{1};
          continue
        end
        
        % extract Software version
        % return structure array containing the name and text of each named token
        % captured by regexp.
        % ex: * Software Version Seasave V 7.16
        s = regexp(tline,...
          '^*\s*Software Version Seasave.*(?<VERSION>\d+\.\d+)', 'names');
        if ~isempty(s)
          self.SeasaveVersion = s.VERSION;
          continue
        end
        
        % extract sensors name and serial number to map
        % ex: * Temperature SN = 2441
        match = regexp( tline,...
          '^#\s+<!--\s*(.*?)\s*-->', 'tokens');
        if ~isempty(match)
          param = match{1}{1};
          fgetl(fid);          % skip next line
          tline = fgetl(fid);  % read next line
          match = regexp( tline,...
            '^#\s+<SerialNumber>(.*?)</SerialNumber>', 'tokens');
          if ~isempty(match)
            self.sensorsList = [self.sensorsList, param];
            self.sensors(param) = match{1}{1};
            continue
          end
        end
        
        % extract date of launch
        % ex: * System UpLoad Time = Oct 03 2008 16:45:05
        match = regexp( tline,...
          '^*\s*System UpLoad Time\s*=\s*(\w+)\s*(\d*)\s*(\d*)\s*(\d{2}):(\d{2}):(\d{2})', 'tokens');
        if ~isempty(match)
          month = match{1}{1};
          day   = match{1}{2};
          year  = match{1}{3};
          hour  = match{1}{4};
          min   = match{1}{5};
          sec   = match{1}{6};
          
          % convert date and time of launch to internal matlab datenum
          self.Date   = datenum([year month day hour min sec],'yyyymmmddHHMMSS');
          self.Julian = datenumToJulian(self, self.Date);
          continue
        end
        
        % extract NMEA Latitude
        % a revoir l'utilisation de DegMin_2_Dec et dd2dm dans oceano
        % a mettre sous forme de package us191.datagui.util
        match = regexp( tline,...
          '^*\s*NMEA Latitude\s*=\s*(\d+)\s+(\d+\.\d+)\s*(\w{1})', 'tokens');
        if ~isempty(match)
          deg  = str2double(match{1}{1});
          min  = str2double(match{1}{2});
          hemi = match{1}{3};
          self.Latitude = degMinToDec(self, deg, min, hemi);
          continue
        end
        
        % extract NMEA Longitude
        match = regexp( tline,...
          '^*\s*NMEA Longitude\s*=\s*(\d+)\s+(\d+\.\d+)\s*(\w{1})', 'tokens');
        if ~isempty(match)
          deg  = str2double(match{1}{1});
          min  = str2double(match{1}{2});
          hemi  = match{1}{3};
          self.Longitude = degMinToDec(self, deg, min, hemi);
          continue
        end
        
        % extract Plateforme name (eg ship or navire)
        % ex: ** Ship: BIC Olaya
        match = regexp( tline,...
          '^**\s*Ship\s*:\s*(\w.+)$', 'tokens');
        if ~isempty(match)
          self.Plateforme = match{1}{1};
          continue
        end
        
        % extract cruise name
        % ex: ** Cruise:   PIRATA-FR18
        match = regexp( tline,...
          '^**\s*Cruise\s*:\s*(\w.+)$', 'tokens');
        if ~isempty(match)
          self.Cruise = match{1}{1};
          continue
        end
        
        % extract profile number
        % ex: ** Station: 001
        match = regexp( tline,...
          '^**\s*[Ss]tation\s*:\s*(\d+)', 'tokens');
        if ~isempty(match)
          self.Profile = match{1}{1};
          continue
        end
        
        % extract sensors name
        % ex: # name 0 = prDM: Pressure, Digiquartz [db]
        %     # name 1 = t090C: Temperature [ITS-90, deg C]
        %     # ...
        match = regexp( tline,...
          '^#\s*name\s*(\d+)\s*=\s*(.+?):\s*(.+?)$', 'tokens');
        if ~isempty(match)
          name = match{1}{2};
          % remove invalid character for netcdflib
          name = strrep(name,'/','');
          name = strrep(name,'é','');
          self.varNamesList = [self.varNamesList, name];
          self.varList(match{1}{1}) = name;
          self.varNames(name) = match{1}{3};
          continue
        end
      end % end of header
      
      % get all keys in  containers.Map containing the list of columns name
      theKeys = keys(self.varList);
      
      % number of keys corresponding to column number to read
      columns = length(theKeys);
      
      % read the end-of-file
      theData = fscanf(fid, '%lf', [columns Inf]);
      theData = theData'; % transpose matrix
      self.dimension = size(theData,1);
      
      % set inherited containers.Map from matrix theData
      % see http://fr.mathworks.com/matlabcentral/newsreader/view_thread/250895
      for key = theKeys
        ind = str2double(char(key));
        theKey = self.varList(char(key));
        % see subsassign, doesn't works,  self(theKey) call constructeur
        % with values as filename
        % self(theKey) = theData(:,ind+1);
        S = substruct('()', theKey);
        self = subsasgn(self, S, theData(:,ind+1));
      end
      fclose(fid);
    end % end of read
    
    % overloaded function disp
    % ------------------------
    function disp(self)
      
      % display aditionnals sbe911 properties
      fprintf('\tCruise:          %s\n', self.Cruise);
      fprintf('\tPlateforme:      %s\n', self.Plateforme);
      fprintf('\tProfile:         %s\n', self.Profile);
      fprintf('\tDate:            %s\n', datestr(self.Date, 'yyyy-mm-ddTHH:MM:SSZ'));
      fprintf('\tJulian:          %12.6f\n', self.Julian);
      fprintf('\tLatitude:        %11.8f\n', self.Latitude);
      fprintf('\tLongitude:       %12.8f\n', self.Longitude);
      fprintf('\tCtdType:         %s\n', self.CtdType);
      fprintf('\tSeasaveVersion:  %s\n', self.SeasaveVersion);
      fprintf('\nvarNames:');
      display(self.elements(self.varNames, self.varNamesList));
      fprintf('sensors:');
      display(self.elements(self.sensors, self.sensorsList));
      %display(self.elements(self, self.varNamesList));
      for v = self.varNamesList
        str = sprintf('''%s''', char(v));
        fprintf(1, '\t%-15s\t\t\t[%d x 1]\n', str, self.dimension);
      end
    end
    
    % Converts a GPS latitude or longitude degrees minutes string to a decimal
    % degrees latitude or longitude
    % ------------------------------------------------------------------------
    function dec = degMinToDec(~, deg, min, EWNS)
      
      % convert to decimal
      dec = deg + min/60.0;
      
      % add negative sign to decimal degrees if south of equator or west
      switch EWNS
        case 'S'
          % south of equator is negative, add -ve sign
          dec = dec * -1;
        case 'W'
          % west of Greenwich meridian is negative, add -ve sign
          dec = dec * -1;
        case {'N','E'}
          % do nothing
        otherwise
          error('readCnv:degMinToDec', 'error: bad hemisphere %s', EWNS);
      end
    end % end of degMinToDec
    
    % converts Matlab datenum to its equivalent Julian day with days since
    % 1950-01-01 00:00:00.
    % --------------------------------------------------------------------
    function julian = datenumToJulian(~, dateNum)
      julian = dateNum - datenum(1950, 1, 1);
    end
    
    % overload the subsref functions
    % ------------------------------
    function sref = subsref(self,s)
      switch s(1).type
        case '.'
          % implement obj.PropertyName
          if length(s) == 1
            switch s.subs
              case { 'fileName','CtdType','SeasaveVersion','Calibration',...
                  'Profile','Date','Julian','Latitude','Longitude',...
                  'Plateforme','Cruise','dimension','Header','echo'}
                sref = self.(s.subs);
              case { 'sensors', 'varNames','varNamesList'}
                sref = self.(s.subs);
              case { 'saveNc', 'saveMat'}
                self.(s.subs);
              otherwise
                s.type = '()';
                sref = subsref@containers.Map(self,s);
            end
          elseif length(s) == 2 && strcmp(s(2).type,'()')
            % implement obj.PropertyName(indices)
            switch s(1).subs
              case { 'sensors','varNames','Header'}
                val = self.(s(1).subs);
                if strcmp(s(2).subs{1}, ':')
                  map = self.(s(1).subs);
                  k = keys(map);
                  sref = '';
                  for i = 1: map.Count
                    %sref = strcat(sref, sprintf('%s\n', hdr(i)));
                    theKey = k{i};
                    if isnumeric(theKey)
                      sref = [sref, sprintf('%s\n', map(k{i}))]; %#ok<AGROW>
                    else
                      sref = [sref, sprintf('%s : %s\n', theKey, map(k{i}))]; %#ok<AGROW>
                    end
                  end
                else
                  sref = val(s(2).subs{1});
                end
              otherwise
                t.type = '()';
                t.subs = s(1).subs;
                val = subsref@containers.Map(self,t);
                sref = val(s(2).subs{1});
            end
          elseif length(s) == 2 && strcmp(s(2).type,'.')
            switch s(1).subs
              case { 'sensors','varNames'}
                val = self.(s(1).subs);
                t.type = '()';
                t.subs = s(2).subs;
                sref = subsref@containers.Map(val,t);
              otherwise
                error('Not a valid indexing expression')
            end
          end
        case '()'
          sref = subsref@containers.Map(self,s);
        case '{}'
          error('Not a supported indexing expression')
      end
    end % end of subsref
    
    % save data in mat file
    % ---------------------
    function saveObj(self)
      
      % change .cnv extention to .mat
      [cnvFolder, baseName, ~] = fileparts( self.fileName);
      matBaseName = sprintf('%s.mat',baseName);
      matFolder = strrep(cnvFolder,'cnv','mat');
      if ~isdir(matFolder)
        mkdir(matFolder)
      end
      matFullName = fullfile(matFolder, matBaseName);
      % display info on console
      if self.echo
        fprintf(1,'writing mat file: %s\n', matFullName);
      end
      save( matFullName, 'self', '-v7.3');
    end % end of saveObj
    
    % save data in netcdf file
    % ------------------------
    function saveNc(self)
      
      % change .cnv extention to .mat
      [cnvFolder, baseName, ~] = fileparts( self.fileName);
      ncBaseName = sprintf('%s.nc',baseName);
      ncFolder = strrep(cnvFolder,'cnv','nc');
      if ~isdir(ncFolder)
        mkdir(ncFolder)
      end
      ncFullName = fullfile(ncFolder, ncBaseName);
      writeNetcdf(self, ncFullName);
      
    end % end of saveObj
    
  end % end of public methods
  
  methods(Static)
    
    % get elements from hashtable in cell array,
    % theList contain all keys with the input order
    % ----------------------------------------------
    function theValue = elements(theMap, theList)
      if ~isempty(keys(theMap)) && ~isempty(values(theMap))
        % initialize theValue
        theValue = cell(length(theList),2);
        if isempty(theList)
          theValue(:,1) = keys(theMap);
          theValue(:,2) = values(theMap);
        else
          for i = 1 : length(theList)
            theValue(i,1) = {theList{i}};
            theValue(i,2) = {theMap(theList{i})};
          end
        end
      else
        theValue = {};
      end
    end % end of elements
    
  end % end of static methods
  
end % end of class readCnv

