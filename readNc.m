classdef readNc  < dynamicprops
  %UNTITLED2 Summary of this class goes here
  %   Detailed explanation goes here
  
  properties   (Access = private)
    fileName
  end
  
  properties
    root = containers.Map
    raw = containers.Map
  end
  
  methods % public methods
    
    % constructor
    % --------------------------------
    function self = readNc(fileName)
      
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
      
      % read variables from root group
      info = ncinfo(self.fileName);
      for i = 1: length(info.Variables)
        varName = info.Variables(i).Name;
        value = ncread(self.fileName, varName);
        self.root(varName) = value;
      end
      
      % read variables from raw group
      info = ncinfo(self.fileName, 'raw');
      for i = 1: length(info.Variables)
        varName = info.Variables(i).Name;
        value = ncread(self.fileName, sprintf('raw/%s', varName));
        self.raw(varName) = value;
      end
    end % end of constructor
    
  end % end of public methods
  
end % end of class

