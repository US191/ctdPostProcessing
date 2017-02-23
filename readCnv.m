classdef readCnv
  % J. Grelet IRD US191 IMAGO - 2017
  
  properties   (Access = private)
    fileNames
  end
  
  properties (SetAccess = public)
    CTD_Type;
    Seasave_Version;
    Sensor_TEMP_SN;
    Sensor_CNDC_SN;
    Calibration;
    Profile;
    Datenum;            % internal Matlab date representation
    Latnum;
    Longnum;
    Plateform;
    Cruise;
    Vars = containers.Map;
  end
  
  methods % public methods
    function self = readCnv(fileNames, varargin)
      
      % pre initialization - select filename
      if nargin < 1 || isempty(fileNames)
        [fileNames, pathName] = uigetfile({'*.cnv','Seabird cnv (*.cnv)'},...
          'Select files','MultiSelect','on');
        
        if isempty(fileNames)
          error(message('MATLAB:reportReader:Empty fileName'));
        else
          fileNames = fullfile(pathName, fileNames);
        end
      end
      
      % post initialization
      if ischar(fileNames)
        fileNames = {fileNames};
      end
      self.fileNames = fileNames;
      
      for f = self.fileNames
        file = char(f);
        read(self, file);
        
      end
      
      
    end % end of constructor
    
    % read files and fill containers.Map
    % -----------------------------------------
    function  read(self,file)
      
      fprintf(1, 'read file: %s\n', file);
      fid = fopen(file);
  
      % read the header
      while ~feof(fid) 
            tline = fgetl(fid);
        disp(tline)
        if ~isempty(strfind(tline,'*END'))  % end of header
          break;
        end
        % extract CTD type
        % ex: * Sea-Bird SBE 9 Data File:
        % ex: * Sea-Bird SBE19plus Data File:
        % -----------------------------------
        match = regexp( tline,...
          '^*\s*Sea-Bird\s*(.+)\s*Data File:', 'tokens');
        if ~isempty(match)
          self.CTD_Type = match{1}{1};
          continue
        end
        
        % extract Software version
        % return structure array containing the name and text of each named token
        % captured by regexp.
        % ex: * Software Version Seasave V 7.16
        % -------------------------------------
        s = regexp(tline,...
          '^*\s*Software Version Seasave.*(?<VERSION>\d+\.\d+)', 'names');
        if ~isempty(s)
          self.Seasave_Version = s.VERSION;
          continue
        end
        
        % extract Temperature sensor serial number
        % ex: * Temperature SN = 2441
        % ----------------------------------------
        match = regexp( tline,...
          '^*\s*Temperature SN =\s*(\d+)', 'tokens');
        if ~isempty(match)
          self.Sensor_TEMP_SN = match{1}{1};
          continue
        end
        
        % extract Conductivity sensor serial number
        % ex: * Conductivity SN = 2072
        % ----------------------------------------
        match = regexp( tline,...
          '^*\s*Conductivity SN =\s*(\d+)', 'tokens');
        if ~isempty(match)
          self.Sensor_CNDC_SN = match{1}{1};
          continue
        end
        
        % extract date of launch
        % ex: * System UpLoad Time = Oct 03 2008 16:45:05
        % -----------------------------------------------
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
          % ----------------------------------------------------------
          self.Datenum = datenum([year month day hour min sec],'yyyymmmddHHMMSS');
          continue
        end
        
        % extract NMEA Latitude
        % a revoir l'utilisation de DegMin_2_Dec et dd2dm dans oceano
        % a mettre sous forme de package us191.datagui.util
        % ---------------------------
        match = regexp( tline,...
          '^*\s*NMEA Latitude\s*=\s*(\d+)\s+(\d+\.\d+)\s*(\w{1})', 'tokens');
        if ~isempty(match)
          deg  = str2double(match{1}{1});
          min  = str2double(match{1}{2});
          hemi = match{1}{3};
          self.Latnum = str2double(DegMin_2_Dec(sprintf('%02d%08.5f', deg, min), hemi));
          continue
        end
        
        % extract NMEA Longitude
        % ----------------------
        match = regexp( tline,...
          '^*\s*NMEA Longitude\s*=\s*(\d+)\s+(\d+\.\d+)\s*(\w{1})', 'tokens');
        if ~isempty(match)
          deg  = str2double(match{1}{1});
          min  = str2double(match{1}{2});
          hemi  = match{1}{3};
          self.Longnum = str2double(DegMin_2_Dec(sprintf('%03d%08.5f',deg, min), hemi));
          continue
        end
        
        % extract plateform name (eg ship or navire)
        % ex: ** Ship: BIC Olaya
        % ----------------------
        match = regexp( tline,...
          '^**\s*Ship\s*:\s*(\w.+)$', 'tokens');
        if ~isempty(match)
          self.Plateform = match{1}{1};
          continue
        end
        
        % extract cruise name
        % ex: ** Cruise:   PIRATA-FR18
        % ----------------------------
        match = regexp( tline,...
          '^**\s*Cruise\s*:\s*(\w.+)$', 'tokens');
        if ~isempty(match)
          self.Cruise = match{1}{1};
          continue
        end
        
        % extract profile number
        % ex: ** Station: 001
        % ----------------------
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
        % -------------------------------------------------
        match = regexp( tline,...
          '^#\s*name\s*(\d+)\s*=\s*(.+):', 'tokens');
        if ~isempty(match)
          self.Vars(match{1}{1}) = match{1}{2};
          continue
        end
       
      end
      fclose(fid);
    end % end of read
    
  end % end of public methods
  
end

