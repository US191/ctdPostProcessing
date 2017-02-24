classdef process < handle
    %process
    %
    %
    % J. Grelet IRD US191 IMAGO - 2017
    
    properties % public
        % get pathname
        DEFAULT_PATH_FILE;
        ProfileName
        rawDir
        cnvDir
        psaDir
        
        % define where save user preferences
        configFile           = [prefdir, filesep, mfilename, '.mat'];
    end
    
    properties (Access = public, SetObservable)
        hdlFigure;
        hdlConfigPanel;
        hdlRawDirText;
        hdlRawDir
        hdlRawDirSelect;
    end
    
    methods % public
        % constructor
        % -----------
        function self = process(varargin)
            
            % initialize the default path
            self.DEFAULT_PATH_FILE = fileparts(mfilename('fullpath'));
            
            % define main interface
            % call destructor when user close the main windows
            % ------------------------------------------------
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
            
            % call function that define the GUI
            % ---------------------------------
            self.setUitoolbar;
            self.setUicontrols;
            
        end % end of constructor process
        
        % destructor
        % ----------
        function delete(self)
            % save configuration inside user preference directory, call static
            % method save_config
            process.SaveConfig(self);
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
                %'callback', {@get_mission_para, 'config_FILENAME'});
            
            self.hdlRawDirSelect = uicontrol(self.hdlConfigPanel,...
                'string', 'Select', ...
                'units', 'normalized', ...
                'position', [0.71 0.91 0.1 0.03], ...
                'tag', 'RAWDIR_SELECT', ...
                'callback', {@(src,evt) selectRawDir(self)});
            
        end % end of setUicontrols
        
        function selectRawDir(self)
            self.rawDir = uigetdir(self.rawDir);
            % add some tests
            set(self.hdlRawDir, 'string', self.rawDir);
        end
        
    end % end of public methods
    
    % static methods
    % ---------------
    methods(Static)
        
        % save user preferences to MAT file in user preference directory
        %
        % -------------------------------------------------------------------
        function SaveConfig(self)
            
            % save property values in struct
            % S.climatology_value = self.climatology_value; %#ok<STRNU>
            save( self.configFile, 'self', '-v7.3')
            % return struct for save function to write to MAT-file
        end
        
        % load user preferences from  MAT file in user preference directory
        % -------------------------------------------------------------------
        function LoadConfig(self)
            
            % test if configFile exist
            % -------------------------
            if exist(self.configFile, 'file') == 2
                
                % load properties values from struct
                % ----------------------------------
                load( self.configFile, 'v');
                %self.map_value = S.map_value;
                
                
            end
            
        end % end of loadConfig method
        
    end % end of static methods
    
end

