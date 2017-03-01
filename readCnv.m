classdef readCnv < hashtable
    %readCnv construct object and read seabird cnv file(s)
    %
    %   Examples:
    %
    % r = readCnv  use uigetfile to select one or more files
    % r = readCnv('examples/fr26/data/raw/fr26001.hex')
    %
    % r =
    %   readCnv with properties:
    %
    %            CTD_Type: 'SBE 9 '
    %     Seasave_Version: '3.2'
    %         Calibration: []
    %             Profile: '1'
    %             Datenum: 7.3640e+05
    %              Latnum: 11.4650
    %             Longnum: -23.0002
    %          Plateforme: 'THALASSA'
    %              Cruise: 'PIRATA-FR26'
    %             Sensors: [10 hashtable]
    %           Variables: [13 hashtable]
    %
    %  r.Sensors
    % ...
    %     'Frequency 0, Temperature'             '6083'
    %     'Frequency 1, Conductivity'            '4509'
    %     'Frequency 2, Pressure, Digiquar…'    '1263'
    %     'Frequency 3, Temperature, 2'          '6086'
    %     'Frequency 4, Conductivity, 2'         '4510'
    %     'A/D voltage 0, Oxygen, SBE 43'        '3261'
    %     'A/D voltage 1, Oxygen, SBE 43, 2'     '3265'
    %     'A/D voltage 2, Transmissometer,…'    'CTS1210DR'
    %     'A/D voltage 3, Fluorometer, WET…'    'FLRTD-1367'
    %     'A/D voltage 4, Altimeter'             '61768'
    %
    % keys(r.Variables)
    % values(r.Variables)
    % temp = r.Variables('t190C')
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
        VarList     = hashtable;
    end
    
    properties (SetAccess = public)
        CTD_Type;
        Seasave_Version;
        Calibration;
        Profile;
        Datenum;            % internal Matlab date representation
        Latnum;
        Longnum;
        Plateforme;
        Cruise;
        VarNames    = hashtable;
        Sensors     = hashtable;
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
            fid = fopen(file);
            
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
                
                % extract sensors name and serial number to map
                % ex: * Temperature SN = 2441
                % ----------------------------------------
                match = regexp( tline,...
                    '^#\s+<!--\s*(.*?)\s*-->', 'tokens');
                if ~isempty(match)
                    param = match{1}{1};
                    fgetl(fid);          % skip next line
                    tline = fgetl(fid);  % read next line
                    match = regexp( tline,...
                        '^#\s+<SerialNumber>(.*?)</SerialNumber>', 'tokens');
                    if ~isempty(match)
                        self.Sensors(param) = match{1}{1};
                        continue
                    end
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
                    self.Latnum = str2double(degMinToDec(self, sprintf('%02d%08.5f', deg, min), hemi));
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
                    self.Longnum = str2double(degMinToDec(self, sprintf('%03d%08.5f',deg, min), hemi));
                    continue
                end
                
                % extract Plateforme name (eg ship or navire)
                % ex: ** Ship: BIC Olaya
                % ----------------------
                match = regexp( tline,...
                    '^**\s*Ship\s*:\s*(\w.+)$', 'tokens');
                if ~isempty(match)
                    self.Plateforme = match{1}{1};
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
                    '^#\s*name\s*(\d+)\s*=\s*(.+?):\s*(.+?)$', 'tokens');
                if ~isempty(match)
                    self.VarList(match{1}{1}) = match{1}{2};
                    self.VarNames(match{1}{2}) = match{1}{3};
                    continue
                end
            end % end of header
            
            % get all keys in hashtable containing the list of columns name
            % -------------------------------------------------------------
            theKeys = keys(self.VarList);
            
            % number of keys corresponding to column number to read
            % -----------------------------------------------------
            columns = length(theKeys);
            
            % read the end-of-file
            % --------------------
            data = fscanf(fid, '%g', [columns Inf]);
            data = data'; % transpose matrix
            
            % set oceano Data property with hashtable from matrix data
            % --------------------------------------------------------
            for key = theKeys
                ind = str2double(char(key));
                put(self,self.VarList(char(key)), data(:,ind+1));
            end
            
            fclose(fid);
        end % end of read
        
        % overloaded function disp
        % ------------------------
        function disp(self)
            
            % display aditionnals sbe911 properties
            % -------------------------------------
            fprintf('\tCruise:          %s\n', self.Cruise);
            fprintf('\tPlateforme name: %s\n', self.Plateforme);
            fprintf('\tProfile:         %s\n', self.Profile);
            fprintf('\tDate:            %f\n', self.Datenum);
            fprintf('\tLatitude:        %f\n', self.Latnum);
            fprintf('\tLongitude:       %f\n', self.Longnum);
            fprintf('\tCTD Type:        %s\n', self.CTD_Type);
            fprintf('\tSeasave version: %s\n', self.Seasave_Version);
            disp@hashtable(self.VarNames);
            disp@hashtable(self.Sensors);
            
            % call superclass disp method
            % ---------------------------
            disp@hashtable(self);
            
        end
        
        
        % Converts a GPS latitude or longitude degrees minutes string to a decimal
        % degrees latitude or longitude
        %
        % Returns -1 if called with input argument in wrong format
        % Returns -2 if not called with input arguments
        %
        % Inputs:       degmin - latitude or longitude string to convert
        %               EWNS - East, West, North, South indicator from NMEA string,
        %               or use a NULL field ('') if not used
        % Returns:      dec - decimal degrees version of input
        % ------------------------------------------------------------------------
        
        function dec = degMinToDec(~, degmin, EWNS)
            % Latitude string format: ddmm.mmmm (dd = degrees)
            % Longitude string format: dddmm.mmmm (ddd = degrees)
            
            if nargin ~= 3
                dec = '-2';
            else
                % Determine  if data is latitude or longitude
                switch length(strtok(degmin,'.'))
                    case 4
                        % latitude data
                        deg = str2double(degmin(1:2)); % extract degrees portion of latitude string and convert to number
                        min_start = 3;              % position in string for start of minutes
                    case 5
                        % longitude data
                        deg = str2double(degmin(1:3)); % extract degrees portion of longitude string and convert to number
                        min_start = 4;              % position in string for start of minutes
                    otherwise
                        % data not in correct format
                        dec = '-1';
                        return;
                end
                
                minutes = (str2double(degmin(min_start:length(degmin))))/60; % convert minutes to decimal degrees
                
                dec = num2str(deg + minutes,'%11.10g'); % degrees as decimal number
                
                % add negative sign to decimal degrees if south of equator or west
                switch EWNS
                    case 'S'
                        % south of equator is negative, add -ve sign
                        dec = strcat('-',dec);
                    case 'W'
                        % west of Greenwich meridian is negative, add -ve sign
                        dec = strcat('-',dec);
                    otherwise
                        % do nothing
                end
            end
            
        end % end of degMinToDec
        
        
    end % end of public methods
    
end % end of class readCnv

