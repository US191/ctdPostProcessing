classdef readNc  < dynamicprops
  %UNTITLED2 Summary of this class goes here
  %   Detailed explanation goes here
  
  properties   (Access = private)
    fileName
  end
  
  properties
%     root = containers.Map
%     raw = containers.Map
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
      
      % add dynamic properties for group
      
      % read variables from root group
      info = ncinfo(self.fileName);
      addprop(self, 'root');
      self.root = containers.Map;
      for i = 1: length(info.Variables)
        varName = info.Variables(i).Name;
        value = ncread(self.fileName, varName);
        self.root(varName) = value;
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
    
  end % end of public methods
  
end % end of class

