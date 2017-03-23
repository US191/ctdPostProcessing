classdef readNc  < dynamicprops
  %READNC This class read Netcdf4 file and save group in containers.Map
  % object
  %
  %   Examples:
  %
  % nc = readNc  use uigetfile to select one or more files
  % nc = readNc('C:\git\ctdPostProcessing\examples\fr26\data\nc\dfr26001.nc')
  %
  % nc.raw.keys     give n x 1 cell array
  % nc.keys('raw')  give n x 1 cell array
  % keys(nc.raw)    give 1 x n cell array
  % nc.raw('c0Sm')
  % nc.raw.c0Sm
  %   nc.raw.c0Sm(1:4)
  %    5.381611824035645
  %    5.381980895996094
  %    5.381818771362305
  %    5.381879806518555
  
  %   Global Attributes:
  %            fileName       = 'C:\git\ctdPostProcessing\examples\fr26\data\cnv\dfr26001.cnv'
  %            ctdType        = 'SBE 9 '
  %            seasaveVersion = '3.2'
  %            plateforme     = 'THALASSA'
  %            cruise         = 'PIRATA-FR26'
  %            date_created   = '2017-03-20T12:04:10Z'
  %            created_by     = 'jgrelet'
  %            date_type      = 'OceanSITES profile data'
  %            format_version = '1.2'
  %            netcdf_version = '4.3.3.1'
  %            Conventions    = 'CF-1.6, OceanSITES-1.2'
  %            comment        = 'Data read from readCnv program'
  %            header         = '* Sea-Bird SBE 9 Data File:
  
  properties   (Access = private)
    fileName
    echo        = true               % default
  end
  
  properties
    %     root = containers.Map
    %     raw = containers.Map
  end
  
  methods % public methods
    
    % constructor
    % --------------------------------
    function self = readNc(fileName, varargin)
      
      % pre initialization - select filename
      if nargin < 1 || isempty(fileName)
        [fileName, pathName] = uigetfile({'*.nc','NetCDF (*.nc)'},...
          'Select file');
        if isnumeric(fileName)
          if fileName == 0
            error('readNc: empty fileName');
          end
        end
        self.fileName = fullfile(pathName, fileName);
      else
        self.fileName = fileName;
      end
      if nargin == 2 && islogical(varargin{1})
        self.echo = varargin{1};
      end
      
      % read informations fron netcdf file
      info = ncinfo(self.fileName);
      
      % add dynamic properties for global attributes
      for i = 1: length(info.Attributes)
        attName = info.Attributes(i).Name;
        addprop(self, attName);
        value = info.Attributes(i).Value;
        self.(attName) = value;
      end
      
      % add dynamic properties for group
      root = 'root';
      addprop(self, root);
      self.(root) = containers.Map;
      
      % read variables from root group
      for i = 1: length(info.Variables)
        varName = info.Variables(i).Name;
        value = ncread(self.fileName, varName);
        self.(root)(varName) = value;
      end
      
      % read variables from all group
      for grp = 1: length(info.Groups)
        groupName = info.Groups(grp).Name;
        groupInfo = ncinfo(self.fileName, groupName);
        addprop(self, groupName);
        self.(groupName) = containers.Map;
        for var = 1: length(groupInfo.Variables)
          varName = groupInfo.Variables(var).Name;
          value = ncread(self.fileName, sprintf('%s/%s', groupName, varName));
          self.(groupName)(varName) = value;
        end
      end
      
    end % end of constructor
    
    % overloaded function disp
    % ------------------------
    function disp(self)
      
      % display  properties
      fprintf(1, 'Global Attributes:\n');
      prop = properties(self);
      % decrement loop
      for i = length(prop) : -1 : 1
        property = prop{i};
        if isa(self.(property), 'char')
          match = regexp(self.(property), '^(.*?)\n', 'tokens');
          if ~isempty(match)
            fprintf('\t%-20s:\t%-40s\n', property, ...
              strcat(match{1}{1}, ' ...'));
            fprintf('\t%+27s\n', '...');
          else
            fprintf('\t%-20s:\t%-40s\n', property, self.(property));
          end
        end
      end
      fprintf('\nGroups:\n');
      for i = 1 : length(prop)
        property = prop{i};
        if isobject(self.(property))
          fprintf(1, '\t/%s/\n', property);
          theKey = self.(property).keys;
          for i = 1 : length(theKey)
            fprintf(1, '\t\t%s\n', theKey{i});
          end
        end
      end
    end
    
    % overload the subsref functions
    % works with:
    % nc.raw('c0Sm')
    % nc.raw.c0Sm
    % nc.raw.keys     give n x 1 cell array
    % nc.keys('raw')  give n x 1 cell array
    % keys(nc.raw)    give 1 x n cell array
    % ------------------------------
    function sref = subsref(self,s)
      switch s(1).type
        case '.'
          % implement obj.PropertyName
          if length(s) == 1
            sref = self.(s(1).subs);
          elseif length(s) == 2 && strcmp(s(2).type,'.')
            switch s(2).subs
              % nc.raw.keys
              case { 'keys'}  % give n x 1 cell array
                sref = keys(self.(char(s(1).subs)))';
              otherwise
                val = self.(s(1).subs);
                sref = val(s(2).subs);
            end
          elseif length(s) == 2 && strcmp(s(2).type,'()')
            switch s(1).subs
              % nc.keys('raw')
              case { 'keys'}  % give n x 1 cell array
                sref = keys(self.(char(s(2).subs)))';
              otherwise
                % nc.raw('c0Sm')
                val = self.(s(1).subs);
                sref = val(char(s(2).subs));
            end
            % nc.raw.c0Sm(1:4)
          elseif length(s) == 3 && strcmp(s(3).type,'()')
            map = self.(s(1).subs);
            val = map(char(s(2).subs));
            sref = val(s(3).subs{1});
          end
        case '()'
          error('Not a supported indexing expression')
        case '{}'
          error('Not a supported indexing expression')
      end
    end % end of subsref
    
    
  end % end of public methods
  
end % end of class

