classdef process < handle
  %process
  %
  %
  % J. Grelet IRD US191 IMAGO - 2017
  
  properties (Access = public)
    rawDir
    cnvDir
    psaDir
    cruisePrefix 
    profileNumber 
  end
  
   properties (Access = private)

    % define location of user preferences mat file
    configFile           = [prefdir, filesep, mfilename, '.mat'];
  end
  
  properties (Access = private, SetObservable)
    hdlFigure
    hdlConfigPanel
    hdlRawDirText
    hdlRawDir
    hdlRawDirSelect
    hdlCnvDirText
    hdlCnvDir
    hdlCnvDirSelect
    hdlPsaDirText
    hdlPsaDir;
    hdlPsaDirSelect
    hdlCruisePrefixText
    hdlCruisePrefix
    hdlProfileNumberText
    hdlProfileNumber
    hdlDatcnvExec
  end
  
  methods % public
      
    % constructor, define main interface
    % ----------------------------------
    function self = process(varargin)
      
      % call destructor when user close the main windows
      self.hdlFigure = figure( ...
        'Name','Processing Seabird',...
        'NumberTitle', 'off', ...
        'MenuBar', 'None',...
        'Toolbar', 'None', ...
        'WindowStyle', 'normal', ...
        'numbertitle', 'off',...
        'HandleVisibility','on',...
        'Position',[100 400 700 620],...
        'Tag','MAIN_FIGURE',...
        'MenuBar','figure',...
        'Color', get( 0, 'DefaultUIControlBackgroundColor'),...
        'CloseRequestFcn', {@(src,evt) delete(self)});
      
      self.hdlConfigPanel = uipanel(self.hdlFigure, ...
        'title', 'Configuration informations', ...
        'position', [0. 0 1 1], ...
        'tag', 'CONFIG_PANEL', ...
        'visible', 'on');
      
      % load configuration from mat file
      loadObj(self);
      
      % call function that define the GUI
      self.setUitoolbar;
      self.setUicontrols;
      
    end % end of constructor process
    
    % destructor
    % ----------
    function delete(self)
      % save configuration inside user preference directory, call static
      % method save_config
      saveObj(self);
      % close figure and listeners
      %             if ~isempty(src) && ishandle(src)
      %                 delete(src);
      %             end
      % self.deleteListeners;
      closereq;
    end
    
    % function setUitoolbar that define Toolbar
    % -----------------------------------------
    function setUitoolbar(self) %#ok<MANU>
    end
    
    % function setUicontrols that define Uicontrols
    % ---------------------------------------------
    function setUicontrols(self)
      self.hdlRawDirText = uicontrol(self.hdlConfigPanel,...
        'style', 'Text', ...
        'units', 'normalized',...
        'position', [0.1 0.95 0.45 0.02],...
        'HorizontalAlignment', 'left',...
        'String', 'Raw files directory');
      
      self.hdlRawDir = uicontrol(self.hdlConfigPanel,...
        'style', 'edit', ...
        'units', 'normalized', ...
        'position', [0.1 0.91 0.6 0.03], ...
        'tag', 'RAWDIR_EDIT', ...
        'string', self.rawDir, ...
        'HorizontalAlignment', 'left',...
        'TooltipString', 'raw files directory .hex');
      
      self.hdlRawDirSelect = uicontrol(self.hdlConfigPanel,...
        'string', 'Select', ...
        'units', 'normalized', ...
        'position', [0.71 0.91 0.1 0.03], ...
        'tag', 'RAWDIR_SELECT', ...
        'callback', {@(src,evt) selectRawDir(self)});
      
      self.hdlCnvDirText = uicontrol(self.hdlConfigPanel,...
        'style', 'Text', ...
        'units', 'normalized',...
        'position', [0.1 0.85 0.45 0.02],...
        'HorizontalAlignment', 'left',...
        'String', 'Cnv files directory');
      
      self.hdlCnvDir = uicontrol(self.hdlConfigPanel,...
        'style', 'edit', ...
        'units', 'normalized', ...
        'position', [0.1 0.81 0.6 0.03], ...
        'tag', 'CNVDIR_EDIT', ...
        'string', self.cnvDir, ...
        'HorizontalAlignment', 'left',...
        'TooltipString', 'raw files directory .hex');
      
      self.hdlCnvDirSelect = uicontrol(self.hdlConfigPanel,...
        'string', 'Select', ...
        'units', 'normalized', ...
        'position', [0.71 0.81 0.1 0.03], ...
        'tag', 'PSADIR_SELECT', ...
        'callback', {@(src,evt) selectCnvDir(self)});
      
      self.hdlPsaDirText = uicontrol(self.hdlConfigPanel,...
        'style', 'Text', ...
        'units', 'normalized',...
        'position', [0.1 0.75 0.45 0.02],...
        'HorizontalAlignment', 'left',...
        'String', 'Psa files directory');
      
      self.hdlPsaDir = uicontrol(self.hdlConfigPanel,...
        'style', 'edit', ...
        'units', 'normalized', ...
        'position', [0.1 0.71 0.6 0.03], ...
        'tag', 'RAWDIR_EDIT', ...
        'string', self.psaDir, ...
        'HorizontalAlignment', 'left',...
        'TooltipString', 'raw files directory .hex');
      
      self.hdlPsaDirSelect = uicontrol(self.hdlConfigPanel,...
        'string', 'Select', ...
        'units', 'normalized', ...
        'position', [0.71 0.71 0.1 0.03], ...
        'tag', 'RAWDIR_SELECT', ...
        'callback', {@(src,evt) selectPsaDir(self)});
      
      % Cruise prefix
      self.hdlCruisePrefixText = uicontrol(self.hdlConfigPanel,...
        'style', 'Text', ...
        'String', 'Cruise prefix', ...
        'units', 'normalized', ...
        'HorizontalAlignment', 'left',...
        'position', [0.1 0.65 0.34 0.02]);
      
      self.hdlCruisePrefix = uicontrol(self.hdlConfigPanel,...
        'style', 'edit', ...
        'units', 'normalized', ...
        'position', [0.1 0.61 0.1 0.03], ...
        'HorizontalAlignment', 'left',...
        'tag', 'CRUISE_PREFIX_EDIT', ...
        'string', self.cruisePrefix, ...
        'callback', {@(src,evt) selectCruisePrefix(self,src)});
      
      % Station number
      self.hdlProfileNumberText = uicontrol(self.hdlConfigPanel,...
        'style', 'Text', ...
        'String', 'Station Number (''XXX'')', ...
        'units', 'normalized', ...
        'HorizontalAlignment', 'left',...
        'position', [0.4 0.65 0.34 0.02]);
      
      self.hdlProfileNumber = uicontrol(self.hdlConfigPanel,...
        'style', 'edit', ...
        'units', 'normalized', ...
        'position', [0.4 0.61 0.1 0.03], ...
        'HorizontalAlignment', 'left',...
        'BackgroundColor', 'white', ...
        'tag', 'PROFILE_NUMBER_PREFIX', ...
        'TooltipString', 'profile number xxx or xxxcc', ...
        'string', self.profileNumber, ...
        'callback', {@(src,evt) selectProfileNumber(self,src)});
      
      % exec
      self.hdlDatcnvExec = uicontrol(self.hdlConfigPanel,...
        'string', 'Execute', ...
        'units', 'normalized', ...
        'position', [0.71 0.61 0.1 0.03], ...
        'tag', 'DATCNV_EXEC', ...
        'callback', {@(src,evt) execDatcnv(self)});
      
    end % end of setUicontrols
    
    % callbacks
    % ---------
    function selectRawDir(self)
      self.rawDir = uigetdir();
      % when cancel is pressed uigetdir return 0
      if self.rawDir == 0; self.rawDir = []; end
      set(self.hdlRawDir, 'string', self.rawDir);
    end
    
    function selectCnvDir(self)
      self.cnvDir = uigetdir();
      % when cancel is pressed uigetdir return 0
      if self.cnvDir == 0; self.cnvDir = []; end
      set(self.hdlCnvDir, 'string', self.cnvDir);
    end
    
    function selectPsaDir(self)
      self.psaDir = uigetdir();
      % when cancel is pressed uigetdir return 0
      if self.psaDir == 0; self.psaDir = []; end
      set(self.hdlPsaDir, 'string', self.psaDir);
    end
    
     function selectCruisePrefix(self, src)
      self.cruisePrefix =  get(src, 'string');
     end
     
     function selectProfileNumber(self, src )
       self.profileNumber =  get(src, 'string');
     end
    
    % only for testing sbe-processing without sbebatch
    function execDatcnv(self)
      station = strcat(self.cruisePrefix, self.profileNumber);
      datcnv = sprintf('!datcnvw /f%s.cnv /i%s/%s.hex /o%s /p%s/datcnv.psa /c%s/%s.xmlcon /s', ...
        station, self.rawDir, station, self.cnvDir, self.psaDir, ...
        self.rawDir, station);
      filter = sprintf('!filterw /f%s.cnv /i%s/%s.cnv /o%s /p%s/filter.psa /c%s/%s.xmlcon /s', ...
        station, self.cnvDir, station, self.cnvDir, self.psaDir, ...
        self.rawDir, station);
      alignctd = sprintf('!alignctdw /f%s.cnv /i%s/%s.cnv /o%s /p%s/alignctd.psa /c%s/%s.xmlcon /s', ...
        station, self.cnvDir, station, self.cnvDir, self.psaDir, ...
        self.rawDir, station);
      celltm = sprintf('!celltmw /f%s.cnv /i%s/%s.cnv /o%s /p%s/celltm.psa /c%s/%s.xmlcon /s', ...
        station, self.cnvDir, station, self.cnvDir, self.psaDir, ...
        self.rawDir, station);
      loopedit = sprintf('!loopeditw /f%s.cnv /i%s/%s.cnv /o%s /p%s/loopedit.psa /c%s/%s.xmlcon /s', ...
        station, self.cnvDir, station, self.cnvDir, self.psaDir, ...
        self.rawDir, station);
      derive = sprintf('!derivew /f%s.cnv /i%s/%s.cnv /o%s /p%s/derive.psa /c%s/%s.xmlcon /s', ...
        station, self.cnvDir, station, self.cnvDir, self.psaDir, ...
        self.rawDir, station);
      binavgd = sprintf('!binavgw /fd%s.cnv /i%s/%s.cnv /o%s /p%s/BinAvg_downcast.psa /c%s/%s.xmlcon /s', ...
        station, self.cnvDir, station, self.cnvDir, self.psaDir, ...
        self.rawDir, station);
      binavgu = sprintf('!binavgw /fu%s.cnv /i%s/%s.cnv /o%s /p%s/BinAvg_upcast.psa /c%s/%s.xmlcon /s', ...
        station, self.cnvDir, station, self.cnvDir, self.psaDir, ...
        self.rawDir, station);
      evalc(datcnv);
      evalc(filter);
      evalc(alignctd);
      evalc(celltm);
      evalc(loopedit);
      evalc(derive);
      evalc(binavgd);
      evalc(binavgu);
    end
    
    % save user preferences to MAT file in user preference directory
    % -------------------------------------------------------------------
    function s = saveObj(self)
      
      % save property values in struct
      s.rawDir = self.rawDir;
      s.cnvDir = self.cnvDir;
      s.psaDir = self.psaDir;
      s.cruisePrefix = self.cruisePrefix;
      s.profileNmumber = self.profileNumber;
      save( self.configFile, 's', '-v7.3')
    end % end of saveObj
    
    % load user preferences from  MAT file in user preference directory
    % -------------------------------------------------------------------
    function loadObj(self)
      
      s = saveToStruct(self);
      
      % test if configFile exist
      if exist(self.configFile, 'file') == 2
        
        % TODOS: add version tag, if change, reload an new empty struct
        
        % load properties values from struct
        load( self.configFile, 's');
        self.rawDir = s.rawDir;
        self.cnvDir = s.cnvDir;
        self.psaDir = s.psaDir;
        self.cruisePrefix = s.cruisePrefix;
        self.profileNumber = s.profileNmumber;
      end
      
    end % end of loadObj
    
  end % end of public methods
  
  methods (Access = private) 
      
      % use this function instead of struct(self)
      % ----------------------------------------
      function s = saveToStruct(self)
          props = properties(self);
          for p = 1:numel(props)          
              s.(props{p}) = self.(props{p});             
          end
      end % end of saveToStruct
  end % end of  private methods
  
end % end of class process

