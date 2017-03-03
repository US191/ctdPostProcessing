classdef readCnv < containers.Map & handle
  %readCnv construct object and read seabird cnv file(s)
  %
  %   Examples:
  %
  % r = readCnv  use uigetfile to select one or more files
  % r = readCnv('C:\git\ctdPostProcessing\examples\fr26\data\cnv\dfr26001.cnv')
  % read file: C:\git\ctdPostProcessing\examples\fr26\data\cnv\dfr26001.cnv
  %
  % r =
  %
  % 	cruise:          PIRATA-FR26
  % 	plateforme:      THALASSA
  % 	profile:         1
  % 	date:             736398.728414
  % 	julian:          24174.728414
  % 	latitude:        11.465000
  % 	longitude:       -23.000167
  % 	ctdType:         SBE 9
  % 	seasaveVersion:  3.2
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
  % r.latitude
  %    11.4650
  % r.date
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
  %
  % J. Grelet IRD US191 IMAGO - 2017
  
  properties   (Access = private)
    fileNames
    varList     =  containers.Map;
    % the iteration order over containers.Maps is ordered.
    % these properties are used to store keys
    varNamesList = {}
    sensorsList  = {}
  end
  
  properties (SetAccess = public)
    ctdType
    seasaveVersion
    calibration
    profile
    date           % internal Matlab date representation
    julian
    latitude
    longitude
    plateforme
    cruise
    varNames    =  containers.Map
    sensors     =  containers.Map
  end
  
  methods % public methods
    
    % constructor
    % --------------------------------
    function self = readCnv(fileNames)
      
      % pre initialization - select filename
      if nargin < 1 || isempty(fileNames)
        [fileNames, pathName] = uigetfile({'*.cnv','Seabird cnv (*.cnv)'},...
          'Select files','MultiSelect','on');
        if fileNames == 0
          error('readCnv: empty fileName');
        else
          fileNames = fullfile(pathName, fileNames);
        end
      end
      
      % post initialization
      if ischar(fileNames)
        fileNames = {fileNames};
      end
      self.fileNames = fileNames;
      
      % read and extract data from file(s)
      for f = self.fileNames
        file = char(f);
        read(self, file);
      end
    end % end of constructor
    
    % read files and fill containers.Map
    % -----------------------------------------
    function  read(self,file)
      
      fprintf(1, 'read file: %s\n', file);
      [fid, errmsg] = fopen(file);
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
        
        % extract CTD type
        % ex: * Sea-Bird SBE 9 Data File:
        % ex: * Sea-Bird SBE19plus Data File:
        match = regexp( tline,...
          '^*\s*Sea-Bird\s*(.+)\s*Data File:', 'tokens');
        if ~isempty(match)
          self.ctdType = match{1}{1};
          continue
        end
        
        % extract Software version
        % return structure array containing the name and text of each named token
        % captured by regexp.
        % ex: * Software Version Seasave V 7.16
        s = regexp(tline,...
          '^*\s*Software Version Seasave.*(?<VERSION>\d+\.\d+)', 'names');
        if ~isempty(s)
          self.seasaveVersion = s.VERSION;
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
          self.date   = datenum([year month day hour min sec],'yyyymmmddHHMMSS');
          self.julian = datenumToJulian(self, self.date);
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
          self.latitude = degMinToDec(self, deg, min, hemi);
          continue
        end
        
        % extract NMEA Longitude
        match = regexp( tline,...
          '^*\s*NMEA Longitude\s*=\s*(\d+)\s+(\d+\.\d+)\s*(\w{1})', 'tokens');
        if ~isempty(match)
          deg  = str2double(match{1}{1});
          min  = str2double(match{1}{2});
          hemi  = match{1}{3};
          self.longitude = degMinToDec(self, deg, min, hemi);
          continue
        end
        
        % extract Plateforme name (eg ship or navire)
        % ex: ** Ship: BIC Olaya
        match = regexp( tline,...
          '^**\s*Ship\s*:\s*(\w.+)$', 'tokens');
        if ~isempty(match)
          self.plateforme = match{1}{1};
          continue
        end
        
        % extract cruise name
        % ex: ** Cruise:   PIRATA-FR18
        match = regexp( tline,...
          '^**\s*Cruise\s*:\s*(\w.+)$', 'tokens');
        if ~isempty(match)
          self.cruise = match{1}{1};
          continue
        end
        
        % extract profile number
        % ex: ** Station: 001
        match = regexp( tline,...
          '^**\s*[Ss]tation\s*:\s*(\d+)', 'tokens');
        if ~isempty(match)
          self.profile = match{1}{1};
          continue
        end
        
        % extract sensors name
        % ex: # name 0 = prDM: Pressure, Digiquartz [db]
        %     # name 1 = t090C: Temperature [ITS-90, deg C]
        %     # ...
        match = regexp( tline,...
          '^#\s*name\s*(\d+)\s*=\s*(.+?):\s*(.+?)$', 'tokens');
        if ~isempty(match)
          self.varNamesList = [self.varNamesList, match{1}{2}];
          self.varList(match{1}{1}) = match{1}{2};
          self.varNames(match{1}{2}) = match{1}{3};
          continue
        end
      end % end of header
      
      % get all keys in  containers.Map containing the list of columns name
      theKeys = keys(self.varList);
      
      % number of keys corresponding to column number to read
      columns = length(theKeys);
      
      % read the end-of-file
      theData = fscanf(fid, '%g', [columns Inf]);
      theData = theData'; % transpose matrix
      
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
      fprintf('\tcruise:          %s\n', self.cruise);
      fprintf('\tplateforme:      %s\n', self.plateforme);
      fprintf('\tprofile:         %s\n', self.profile);
      fprintf('\tdate:            %f\n', self.date);
      fprintf('\tjulian:          %f\n', self.julian);
      fprintf('\tlatitude:        %f\n', self.latitude);
      fprintf('\tlongitude:       %f\n', self.longitude);
      fprintf('\tctdType:         %s\n', self.ctdType);
      fprintf('\tseasaveVersion:  %s\n', self.seasaveVersion);
      fprintf('\nvarNames:');
      display(self.elements(self.varNames, self.varNamesList));
      fprintf('sensors:');
      display(self.elements(self.sensors, self.sensorsList));
      display(self.elements(self, self.varNamesList));
    end
    
    % Converts a GPS latitude or longitude degrees minutes string to a decimal
    % degrees latitude or longitude
    % ------------------------------------------------------------------------
    function dec = degMinToDec(~, deg, min, EWNS)
      
      % convert to decimal
      dec = deg + min/60;
      
      % add negative sign to decimal degrees if south of equator or west
      switch EWNS
        case 'S'
          % south of equator is negative, add -ve sign
          dec = dec * -1;
        case 'W'
          % west of Greenwich meridian is negative, add -ve sign
          dec = dec * -1;
        otherwise
          % do nothing
      end
    end % end of degMinToDec
    
    % converts Matlab datenum to its equivalent Julian day with days since
    % 1950-01-01 00:00:00.
    % --------------------------------------------------------------------
    function julian = datenumToJulian(~, dateNum)
      julian = dateNum - datenum(1950, 1, 1);
    end
    
  end % end of public methods
  
  methods(Static)
    
    % get elements from hashtable in cell array
    % -----------------------------------------
    function theValue = elements(map, list)
      if ~isempty(keys(map)) && ~isempty(values(map))
        theValue = cell(length(list),2);
        if isempty(list)
          theValue(:,1) = keys(map);
          theValue(:,2) = values(map);
        else
          for i = 1 : length(list)
            theValue(i,1) = {list{i}};
            if strcmp(class(map), mfilename)
              theValue(i,2) = list(i);
            else
              theValue(i,2) = {map(list{i})};
            end
          end
        end
      else
        theValue = {};
      end
    end % end of elements
     
  end % end of static methods
  
end % end of class readCnv

