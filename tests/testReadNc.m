function [ root, raw ] = testReadNc(varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% use clear mex to close an opened NetCDF file

if isempty(varargin)
  file = 'M:\CASSIOPEE\data-processing\CTD\data\nc\tmp\csp00102.nc';
else
  file = varargin{1};
end

ncid = netcdf.open(file,'nowrite');

% Get the number of groups, and their ncids
gids = netcdf.inqGrps(ncid);
for i = 1: length(gids)
  netcdf.inqGrpNameFull(gids(i));  % display group name
end 

% Return ID of named group
gid = netcdf.inqNcid(ncid,'raw');
% IDs of all variables in group
varids = netcdf.inqVarIDs(gid);
% Return ID associated with variable name
%varid = netcdf.inqVarID(ncid,varname);

for varid = varids
  % get information about variable
  [varname,xtype,dimids,natts] = netcdf.inqVar(gid,varid); %#ok<ASGLU>
end
netcdf.close(ncid);


% get information and data 
ncinfo(file,'TIME');
ncread(file,'TIME');
ncinfo(file,'raw');
ncinfo(file,'raw/sal00');
ncread(file,'raw/sal00');

% use containers.Map
root = containers.Map;
info = ncinfo(file);
for i = 1: length(info.Variables)
  root(info.Variables(i).Name) = i;
end

raw = containers.Map;
info = ncinfo(file, 'raw');
for i = 1: length(info.Variables)
  raw(info.Variables(i).Name) = i;
end


