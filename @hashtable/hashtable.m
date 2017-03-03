%% hashtable class
%
% This class implement a hashtable and is part of us191 package (namespace)
% h = hashtable(keys, values)
%
% hashtable use same syntax than Matlab containers.Map object with
% some useful get and put methods, and give logical indexing.
% Instead of MATLAB containers.Map, hashtable lists keys in the order
% they are enter by default.
%
% hashtable is a part of package us191, use fully qualified
% package name like hashtable or use 'import us191' directive first
% in your function before use this class.
%
% hashtable is a handle class
%
%% Examples:
%
% h = hashtable
% import *;
% h = hashtable
% put(h, 'a', 1)
% put(h, {'b','c'},{2,3})
% remove(h, 'a')
% remove(h, {'b','c'})
% v = h('a')
% v = get(h, 'a')
% v = h.get('a')
% h('b') = 2
% h.clear
% h = hashtable({'a','b'}, {1,2})
% h.size
% h.keys
% isempty(h)
% iskey(h,'a')
% s = struct('field1',[1:3],'field2',rand(3))
% h('c') = s
% s = get(h, 'c')
% s = h.c
% v = h.c.field2
% h = hashtable('a', [1:2:20;1:3:30])
% v = h.a(1:3,:)
%
% class hashtable <a href="matlab:methods('hashtable')">methods</a>
%
% $Id$

%% COPYRIGHT & LICENSE
%  Copyright 2009 - IRD US191, all rights reserved.
%
%  This file is part of us191 Matlab package.
%
%    us191 package is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    us191 package is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
%    USA

%% Classdef definition
% --------------------
classdef hashtable < handle
    
    % Properties definition
    % ---------------------
    properties (SetAccess = private, GetAccess = private)
        
        % cells used to store key/value
        key        = {};
        value      = {};
        
        % define containers.Map like properties
        Count      = 0;
        KeyType    = 'char';
        ValueType  = 'any';
        
        % the MagicField, set to 'data__' by default
        MagicField = 'data__';
        
        % enable/disable data access to MagicField
        AutoAccess = false;
        
    end
    
    % Class public methods
    % --------------------
    methods % (Access = public)
        
        % Constructor
        % -----------
        function self = hashtable(varargin)
            
            % copy constructor
            % ----------------
            if nargin == 1 && isa(varargin{1},'hashtable')
                self = varargin{1};
                return;
                
                % construct an empty hashtable using empty default key/value pair
                % ---------------------------------------------------------------
            elseif nargin == 0
                self.key   = {};
                self.value = {};
                
                % hashtable with sigle key/value pair or 2 cell array of
                % {keys}/{values}
                % -------------------------------------------------------------------
            elseif nargin == 2
                theArgs = varargin;
                
                % construct hashtable from {keys}/{values} pair
                % --------------------------------------------
                try
                    put(self, theArgs{1}, theArgs{2});
                catch Me %#ok<NASGU>
                    
                    % construct hashtable from next key/value pairs
                    % ---------------------------------------------
                    for i = 1 : length(theArgs{1})
                        put(self, theArgs{1}{i}, theArgs{2}{i});
                    end
                end % end catch
            else
                error('HASHTABLE:hashtable', 'Constructor not match.');
            end
        end
        
        % properties set/get methods
        % --------------------------
        function set.MagicField(self, value)
            if (~isempty(value)) && (~ischar(value))
                error('HASHTABLE:MagicField', 'property must be a string')
            end
            self.MagicField = value;
        end
        
        function magicField = get.MagicField(self)
            magicField = self.MagicField;
        end
        
        % accept nc.AutoAccess = true, false, 0 or 1
        % ------------------------------------------
        function set.AutoAccess(self, value)
            if value == 0 || value == 1
                value = logical(value);
            end
            if (~islogical(value))
                error('HASHTABLE:AutoAccess', 'property must be a boolean')
            end
            self.AutoAccess = value;
        end
        
        function autoAccess = get.AutoAccess(self)
            autoAccess = self.AutoAccess;
        end
        
        % clear or reset to empty hashtable
        % ---------------------------------
        function clear(self)
            
            % Clear hashtable
            % ---------------
            self.key   = {};
            self.value = {};
        end
        
        % return boolean true if key is in hashtable
        % ------------------------------------------
        function bool = isKey(self, key)
            
            % get index
            % ---------
            index = find(strcmp(self.key, key), 1);
            
            % return true if index not empty
            % ------------------------------
            bool = ~isempty(index);
        end
        
        % return boolean true if value is in hashtable
        % --------------------------------------------
        function bool = isValue(self, value)
            
            index = find(strcmp(self.value, value), 1);
            bool = ~isempty(index);
        end
        
        % return boolean true if hashtable is empty
        % -----------------------------------------
        function bool = isEmpty(self)
            
            bool = isempty(self.key);
        end
        
        % get hashtable value from key
        % ----------------------------
        function theValue = get(self, key)
            
            % initialize index to empty
            % -------------------------
            index = [];
            
            % get key index when keyType is char
            % ----------------------------------
            if ischar(key)
                index = find(strcmp(self.key, key));
                
                % get key index when keyType is numeric
                % -------------------------------------
            elseif isnumeric(key)
                for i=1:size(self.key,2)
                    if self.key{1,i} == key
                        index = i;
                        break;
                    end
                end
                
                % unsupported keyType index, error
                % --------------------------------
            else
                error('HASHTABLE:get','key type %s not supported\n', class(key));
            end
            % if key don't exist, return empty cell
            % or value from index otherwise
            % -------------------------------------
            if isempty(index)
                theValue = {};
            else
                theValue = self.value{index};
            end
        end
        
        % put value in the hashtable
        % --------------------------
        function put(self, key, value)
            
            % initialize index to empty
            % -------------------------
            index = [];
            
            % get key index when keyType is char
            % ----------------------------------
            if ischar(key)
                index = find(strcmp(self.key, key));
                
                % get key index when keyType is numeric
                % -------------------------------------
            elseif isnumeric(key)
                for i=1:size(self.key,2)
                    if self.key{1,i} == key
                        index = i;
                        break;
                    end
                end
                
                % unsupported keyType index, error
                % --------------------------------
            else
                error('HASHTABLE:put', 'key type %s not supported\n', class(key));
            end
            
            % if key don't exist in hashtable
            % -------------------------------
            if isempty(index)
                
                % if hashtable isempty, use first cell, end+1 otherwise
                % ------------------------------------------------
                if isempty(self.key)
                    self.key{1}   = key;
                    self.value{1} = value;
                    
                    % set KeyType property with first key type
                    % -----------------------------------------
                    self.KeyType = class(key);
                    
                else
                    
                    % check if key as same type of KeyType
                    % ------------------------------------
                    if strcmp(self.KeyType, class(key))
                        self.key{end+1}   = key;
                        self.value{end+1} = value;
                    else
                        error('HASHTABLE:put','Specified key type %s differ from KeyType %s.', ...
                            class(key), self.KeyType);
                    end
                end
                
                % update property Count
                % ---------------------
                self.Count = size(self);
                
                % if key exist, update value
                % -------------------------
            else
                self.value{index} = value;
            end
            
        end % end of put function
        
        % get list of keys from hashtable
        % -------------------------------
        function theValue = keys(self)
            theValue = self.key;
        end
        
        % remove key/value from hashtable
        % -------------------------------
        function remove(self, key)
            
            % Remove the key (and corresponding value) from hashtable
            % --------------------------------------------------------
            index = find(strcmp(self.key, key));
            if ~isempty(index)
                
                % make new cell with cells before and after removed key
                % -----------------------------------------------------
                self.key   = {self.key{1:index-1} self.key{index+1:end}};
                self.value = {self.value{1:index-1} self.value{index+1:end}};
                
                % update property Count
                % ---------------------
                self.Count = size(self);
            end
            
        end % end of remove
        
        % get hashtable size size
        % -----------------------
        function theValue = size(self)
            
            % Return the number of keys in hashtable
            % ---------------------------------------
            theValue = numel(self.key);
            
        end  % end of size
        
        % get values from hashtable in cell array
        % ----------------------------------
        function theValues = values(self)
            
            % return cell array value
            % -----------------------
            theValues = self.value;
            
        end % end of values
        
        % overloaded functions
        % --------------------
        
        % display an hashtable object
        % ---------------------------
        function disp(self)
            
            % convert logical AutoAccess to char
            % ----------------------------------
%             if self.AutoAccess, theAutoAccess = 'true'; else theAutoAccess = 'false'; end
%             if isempty(self.MagicField), mf ='[]'; else mf = self.MagicField; end
            
            % display hyperlink help
            % ----------------------
           
%                 fprintf('<a href="matlab:help ctdPostProcessing.hashtable">ctdPostProcessing.hashtable</a>\n\n');
%                 fprintf('Package: ctdPostProcessing\n\n');
%                 fprintf('Properties:\n');
%                 fprintf('      Count:     %d\n',      self.Count);
%                 fprintf('    KeyType:    ''%s''\n',   self.KeyType);
%                 fprintf('  ValueType:    ''%s''\n',   self.ValueType);
                %fprintf(' MagicField:    ''%s''\n',   mf);
                %fprintf(' AutoAccess:     %s\n\n',    theAutoAccess);
          
            if ~isEmpty(self)
                %fprintf('\n');
                display( elements(self) );
            end
            % disp('list of <a href="matlab:methods(''hashtable'')">methods</a>');
            
        end % end of disp
        
        % Subscripted reference for objects
        % ---------------------------------
        function theValue = subsref(self, theStruct)
            
            % ex: h = Hashtable('key', value)
            % value = h.key
            % value = h('key')
            % if value is a structure, get field value:
            % fvalue = h.key.field
            % see help from substruct and subsref
            % -----------------------------------
            % theStruct is a struct array with two fields, type and subs
            % ----------------------------------------------------------
            switch (length(theStruct))
                
                % m('TEMP')
                % m.keys
                % ------
                case 1
                    if iscell(theStruct.subs)
                        theSubs = theStruct.subs{:};
                    else
                        theSubs = theStruct.subs;
                    end
                    switch theStruct.type
                        case {'()', '.'}
                            switch theSubs
                                case 'MagicField'
                                    theValue = builtin('subsref', self, theStruct);
                                    return
                                    
                                otherwise
                                    % m.TEMP
                                    theValue = get(self, theSubs);
                            end
                    end
                    % m('TEMP').long_name
                    % m.TEMP.long_name
                    % m.get('TEMP')
                    % get(m,'TEMP')
                    % m.isKey('TEMP')
                    % ------------------
                case 2
                    switch theStruct(1).type
                        
                        % m.TEMP.long_name
                        case {'()', '.'}
                            if iscell(theStruct(1).subs) %
                                theSubs = theStruct(1).subs{:};
                            else
                                theSubs = theStruct(1).subs;
                            end %
                            switch theSubs
                                case 'get'
                                    theValue = builtin('subsref', self, theStruct);
                                    
                                otherwise
                                    theValue = get(self, theSubs);
                                    
                                    switch theStruct(2).type
                                        case '()'
                                            % array indexing
                                            if isstruct(theValue) && ...
                                                    isfield(theValue, self.MagicField) && self.AutoAccess
                                                theValue = theValue.(self.MagicField);
                                            end
                                            theValue = theValue(theStruct(2).subs{1}, theStruct(2).subs{2});
                                        case '.'
                                            if isfield(theValue, theStruct(2).subs)
                                                theValue = theValue.(theStruct(2).subs);
                                            else
                                                error('''%s'' is not a valid field for structure ''%s''', ...
                                                    theStruct(2).subs, theSubs);
                                            end
                                        otherwise
                                            error('hashtable:subsasgn', '%s not permitted', theStruct(2).type);
                                            
                                    end
                            end
                        otherwise
                            error('hashtable:subsasgn', '%s not permitted', theStruct(1).type);
                    end
                    
                    % m.get('TEMP').name
                    % get(m,'TEMP').name  not allowed
                    % -------------------------------
                    %         case 3 % only for m.get('TEMP').data rule
                    %           switch theStruct(1).type
                    %             case {'.'}
                    %               switch theStruct(1).subs
                    %                 case 'get'
                    %                   if iscell(theStruct(2).subs)
                    %                     theKey = theStruct(2).subs{:};
                    %                   else
                    %                     theKey = theStruct(2).subs;
                    %                   end
                    %                   theValue = get(self, theKey);
                    %                   if isfield(theValue, theStruct(3).subs)
                    %                     theValue = get(get(self, 'theKey'), theStruct(3).subs);
                    %                   else
                    %                     error('(%s) is not struct member for key (%s)', ...
                    %                       theStruct(3).subs, theKey);
                    %                   end
                    %               end
                    %           end
                    
            end % end of switch length(theStruct)
            
            % if key/value is a structure and have MagicField defined and AutoAccess
            % mode is true, return value of this MagicField instead of structure
            % description
            % -------------------------------------------------------------------
            if isstruct(theValue) && isfield(theValue, self.MagicField) && self.AutoAccess
                theValue = theValue.(self.MagicField);
            end
            
        end % end of subsref
        
        % Subscripted assignment for object Hashtable
        % -------------------------------------------
        function self = subsasgn(self, theStruct, val)
            
            % ex: h = Hashtable('key', value)
            % h.key = value
            % h('key') = value
            % see help for subsasgn
            % ---------------------
            switch (length(theStruct))
                case 1
                    if iscell(theStruct.subs)
                        theSubs = theStruct.subs{:};
                    else
                        theSubs = theStruct.subs;
                    end
                    switch theStruct.type
                        case {'()', '.'}
                            switch theSubs
                                case {'MagicField', 'AutoAccess'}
                                    builtin('subsasgn', self, theStruct(1), val);
                                case {'Count', 'KeyType', 'ValueType'}
                                    %  do nothing
                                otherwise
                                    theValue = get(self, theSubs);
                                    if isempty(theValue)
                                        put(self, theSubs, val);
                                    elseif isstruct(theValue) && isfield(theValue, self.MagicField) ...
                                            && self.AutoAccess
                                        theValue.(self.MagicField) = val;
                                        put(self, theSubs, theValue);
                                    elseif isstruct(theValue) && isfield(theValue, self.MagicField) ...
                                            && ~self.AutoAccess
                                        theValue = val;
                                        put(self, theSubs, theValue);
                                    end
                            end
                            
                        otherwise
                            error('hashtable:subsasgn', '%s not permitted', theStruct.type);
                    end
                    
                case 2
                    %               if (length(theStruct(1).subs) ~= 1)
                    %                 error('Only single indexing is supported.');
                    %               end
                    %               theValue = get(self, theStruct(1).subs{1});
                    %               if isempty(theValue)
                    %                 put(self, theStruct(1).subs{1}, val);
                    %               elseif isstruct(theValue) && isfield(theValue, self.MagicField) ...
                    %                   && self.AutoAccess
                    %                 theValue.(self.MagicField) = val;
                    %                 put(self, theStruct(1).subs{1}, theValue);
                    %               elseif isstruct(theValue) && isfield(theValue, self.MagicField) ...
                    %                   && ~self.AutoAccess
                    %                 theValue = val;
                    %                 put(self, theStruct(1).subs{1}, theValue);
                    %               end
                    %
                    %             case '.'
                    %               switch theStruct(1).subs
                    %                 case {'MagicField', 'AutoAccess'}
                    %                   builtin('subsasgn', self, theStruct(1), val);
                    %                 case {'Count', 'KeyType', 'ValueType'}
                    %                   %  do nothing
                    %                 otherwise
                    %                   theValue = get(self,theStruct(1).subs{1});
                    %                   if isempty(theValue)
                    %                     put(self, theStruct(1).subs{1}, val);
                    %                   elseif isstruct(theValue) && isfield(theValue, self.MagicField) ...
                    %                       && self.AutoAccess
                    %                     theValue.(self.MagicField) = val;
                    %                     put(self, theStruct(1).subs{1}, theValue);
                    %                   elseif isstruct(theValue) && isfield(theValue, self.MagicField) ...
                    %                       && ~self.AutoAccess
                    %                     theValue = val;
                    %                     put(self, theStruct(1).subs{1}, theValue);
                    %                   end
                    %               end
                    %
                    %             otherwise
                    %               error('Invalid type.')
                    %           end
                    
                    switch theStruct(2).type
                        case '.'
                            theValue = get(self,theStruct(1).subs);
                            if isempty(theValue)
                                error('hashtable:subsasgn','empty value');
                            elseif isstruct(theValue) && isfield(theValue, self.MagicField) ...
                                    && self.AutoAccess
                                theValue.(self.MagicField) = val;
                                put(self, theStruct(1).subs, theValue);
                            elseif isstruct(theValue) && isfield(theValue, self.MagicField) ...
                                    && ~self.AutoAccess
                                theValue.(theStruct(2).subs) = val;
                                put(self, theStruct(1).subs, theValue);
                            end
                        otherwise
                            error('Invalid type.')
                    end
            end
            
            %??? Error using ==> subsasgn
            % Specified value type does not match the type expected for this container.
            % Specified key type does not match the type expected for this container.
            
        end % end of subsasgn
        
        % The concatenation of hashtable objects
        % Only vertical vectors of Map objects are allowed. You cannot create
        % an m-by-n array or a horizontal vector of s. For this reason,
        % vertcat is supported for Map objects, but not horzcat.
        % All keys in each map being concatenated must be of the same class
        % g = [f; h];
        % -------------------------------------------------------------------
        function vertcat(self, hash)
            for i = keys(hash)
                put(self, i{1}, get(hash, i{1}));
            end
            
        end % end of vertcat
        
    end % of public functions
    
    % protected methods
    % -----------------
    methods (Access = protected)
        
        % get elements from hashtable in cell array
        % ------------------------------------
        function theValue = elements(self)
            if ~isempty(self.key) && ~isempty(self.value)
                theValue(:,1) = self.key;
                theValue(:,2) = self.value;
            else
                theValue = {};
            end
            
        end % end of elements
        
    end % of protected functions
    
end % end of class