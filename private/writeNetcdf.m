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
% ncread('C:\git\ctdPostProcessing\examples\fr26\data\nc\dfr26001.nc','raw/SST')
% 
% TODOS: 
%
% $Id$

%% check arguments
% TODOS: modify and test
% ----------------------
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

% Define useful constants:
NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
fillValue = -9999.9;

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
netcdf.putAtt(root, NC_GLOBAL, 'Comment', 'Data read from readCnv program');

% define raw group
raw    = netcdf.defGrp(root, 'raw');
netcdf.putAtt(raw, NC_GLOBAL,'Comment', 'This group contains raw data')

% Define dimensions:
dimidT = netcdf.defDim(raw,'TIME',length(self.julian));    
dimidY = netcdf.defDim(raw,'LATITUDE',length(self.latitude));
dimidX = netcdf.defDim(raw,'LONGITUDE',length(self.longitude));
dimidZ = netcdf.defDim(raw,'DEPTH',self.dimension);

% Define axis:
varid = netcdf.defVar(raw, 'TIME', 'double', [dimidT]);         
netcdf.putAtt(raw, varid, 'standard_name', 'time');
netcdf.putAtt(raw, varid, 'long_name', 'Time of measurements');
netcdf.putAtt(raw, varid, 'units', 'days since 1950-01-01T00:00:00');
netcdf.defVarFill(raw, varid, false, fillValue);
netcdf.putVar(raw, varid, self.julian);

varid = netcdf.defVar(raw, 'LATITUDE', 'float',[dimidY]);
netcdf.putAtt(raw, varid, 'standard_name', 'latitude');
netcdf.putAtt(raw, varid, 'long_name', 'Station latitude');
netcdf.putAtt(raw, varid, 'units', 'degrees_north');
netcdf.defVarFill(raw, varid, false, fillValue);
netcdf.putVar(raw, varid, self.latitude);

varid = netcdf.defVar(raw,'LONGITUDE','float',[dimidX]);
netcdf.putAtt(raw, varid,'standard_name','longitude');
netcdf.putAtt(raw, varid,'long_name','Station longitude');
netcdf.putAtt(raw, varid,'units','degrees_east');
netcdf.defVarFill(raw, varid,false,fillValue);
netcdf.putVar(raw, varid,self.longitude);

% Insert data:
for k = keys(self)
  key = char(k);
  varid = netcdf.defVar(raw, key ,'float',[dimidZ, dimidT]);
  netcdf.putAtt(raw, varid, 'name', key);
  netcdf.putAtt(raw, varid, 'long_name', self.varNames(key));
  netcdf.putAtt(raw, varid, 'units', self.varNames(key));
  netcdf.defVarFill(raw, varid, false, fillValue);
  netcdf.putVar(raw, varid, self(key));
end

% define filtered group
filtered = netcdf.defGrp(root, 'filtered');
netcdf.putAtt(filtered, NC_GLOBAL, 'Comment', 'his group filtered data')

netcdf.close(root)

