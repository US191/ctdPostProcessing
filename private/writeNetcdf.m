function writeNetcdf(self, varargin)
% writeNetcdf(self, varargin)
%  write method from netcdf class, create and write data to netcdf file
%  also call by save method
%
% Input
% -----
% self        ........... netcdf object
% varargin{1} ........... netcdf file
% varargin{2} ........... file mode
%
% Output
% ------
% not, value class
%
% example:
% r = readCnv('C:\git\ctdPostProcessing\examples\fr26\data\cnv\dfr26001.cnv')
% saveNc(r)
% ncdisp('C:\git\ctdPostProcessing\examples\fr26\data\nc\dfr26001.nc')
% ncread('C:\git\ctdPostProcessing\examples\fr26\data\nc\dfr26001.nc','raw/t090C')
%
% TODOS:
%
% $Id$

switch length(varargin)
  
  case 1
    fileName = char(varargin{1});
    mode = 'CLOBBER';
    
  case 2
    fileName = char(varargin{1});
    mode = char(varargin{2});
    
  otherwise
    error('readCnv:saveNc', 'one or two arg needed');
    
end

% disp info on console
fprintf(1,'writing netcdf file: %s\n', fileName);

% define useful constants:
NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
fillValue = -9999;

% define mode
cmode = netcdf.getConstant('NETCDF4');
cmode = bitor(cmode,netcdf.getConstant(mode));

% create file
root = netcdf.create(fileName, cmode);

% write global attributes
for i = { 'fileName','ctdType','seasaveVersion', 'plateforme','cruise'}
  att = char(i);
  netcdf.putAtt(root, NC_GLOBAL, att, self.(att));
end
netcdf.putAtt(root, NC_GLOBAL, 'date_created', datestr(now,'yyyy-mm-ddTHH:MM:SSZ'))
if ispc
  netcdf.putAtt(root, NC_GLOBAL, 'created_by', getenv('USERNAME'));
else
  netcdf.putAtt(root, NC_GLOBAL, 'created_by', getenv('LOGNAME'));
end
netcdf.putAtt(root, NC_GLOBAL, 'date_type','OceanSITES profile data')
netcdf.putAtt(root, NC_GLOBAL, 'format_version','1.2')
netcdf.putAtt(root, NC_GLOBAL, 'netcdf_version', netcdf.inqLibVers)
netcdf.putAtt(root, NC_GLOBAL, 'Conventions','CF-1.6, OceanSITES-1.2')
netcdf.putAtt(root, NC_GLOBAL, 'comment', 'Data read from readCnv program');

% add seabird cnv header
header = [];
for i = keys(self.header)
  header = [header, sprintf('%s\n', self.header(i{1}))]; %#ok<AGROW>
end
netcdf.putAtt(root, NC_GLOBAL, 'header', header);

% define dimensions
dimidT = netcdf.defDim(root, 'TIME', length(self.julian));
dimidY = netcdf.defDim(root, 'LATITUDE', length(self.latitude));
dimidX = netcdf.defDim(root, 'LONGITUDE', length(self.longitude));
dimidZ = netcdf.defDim(root, 'DEPTH', self.dimension);

% define axis and put values
varid = netcdf.defVar(root, 'TIME', 'double', dimidT);
netcdf.putAtt(root, varid, 'standard_name', 'time');
netcdf.putAtt(root, varid, 'long_name', 'Time of measurements');
netcdf.putAtt(root, varid, 'units', 'days since 1950-01-01T00:00:00Z');
netcdf.defVarFill(root, varid, false, fillValue);
netcdf.putVar(root, varid, self.julian);

varid = netcdf.defVar(root, 'LATITUDE', 'float', dimidY);
netcdf.putAtt(root, varid, 'standard_name', 'latitude');
netcdf.putAtt(root, varid, 'long_name', 'Station latitude');
netcdf.putAtt(root, varid, 'units', 'degrees_north');
netcdf.defVarFill(root, varid, false, fillValue);
netcdf.putVar(root, varid, self.latitude);

varid = netcdf.defVar(root,'LONGITUDE','float', dimidX);
netcdf.putAtt(root, varid,'standard_name','longitude');
netcdf.putAtt(root, varid,'long_name','Station longitude');
netcdf.putAtt(root, varid,'units','degrees_east');
netcdf.defVarFill(root, varid,false,fillValue);
netcdf.putVar(root, varid,self.longitude);

% define raw group
raw = netcdf.defGrp(root, 'raw');
netcdf.putAtt(raw, NC_GLOBAL,'comment', 'This group contains raw data')

% insert data attributes and value using ordered keys
for k = self.varNamesList
  key = char(k);
  varid = netcdf.defVar(raw, key ,'float',[dimidZ, dimidT]);
  netcdf.putAtt(raw, varid, 'name', key);
  % ex:  Oxygen, SBE 43, 2 [dov/dt] -> longName =  and unit = dov/dt
  str = self.varNames(key);
  match = regexp( str, '(.*?)\s*\[(.*?)\]', 'tokens');
  if ~isempty(match)
    netcdf.putAtt(raw, varid, 'long_name', match{1}{1});
    netcdf.putAtt(raw, varid, 'units', match{1}{2});
  else
    netcdf.putAtt(raw, varid, 'long_name', str);
  end
  netcdf.defVarFill(raw, varid, false, fillValue);
  netcdf.putVar(raw, varid, self(key));
end

% define filtered group
filtered = netcdf.defGrp(root, 'filtered');
netcdf.putAtt(filtered, NC_GLOBAL, 'comment', 'This group contains filtered data')

netcdf.close(root)

