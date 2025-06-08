classdef  StructConfig < StructBox
    % usage : 
    %   creation - config = StructConfig(content)
    %              config = StructConfig(config, parent=parent, flags=flags)
    %
    %   get values - config.(key)
    %   set values - config.(key) = value;  
    %
    %   get keys - config.keys()   # similar to dictionary.keys, or
    %                              # struct.fieldnames
    %   
    %   copy(config) # same parent, copy meta, 
    %   config.merge_with(config1, config2, ...) # same parent to config,
    %                                            # copy meta
    % 
    
    methods (Access=public)
        function obj = StructConfig(content, NameValueArgs)
            arguments 
                content = struct()
                NameValueArgs.parent {mustBeAorEmpty(NameValueArgs.parent, "StructConfig")} = []
                NameValueArgs.flags {mustBeAorEmpty(NameValueArgs.flags, "struct")} = []
            end

            if isa(content, 'StructConfig') 
                metadata = copy(content.metadata); % for subclasses of metadata
                if ~isempty(NameValueArgs.flags)
                    metadata.flags = NameValueArgs.flags;
                end
            elseif ~isempty(NameValueArgs.flags)
                metadata = Metadata(flags=NameValueArgs.flags);
            else
                metadata = Metadata;
            end
            parent = NameValueArgs.parent;
            obj = obj@StructBox(metadata, parent);

            obj.set_value(content);
            obj.re_parents();
        end
        function merge_with(self, varargin)
            for t = enumerate(varargin)
                other = t.item;
                if ~isempty(other)
                    self.set_value(other);
                end
            end
        end
        function merge_with_dotlist(self, varargin)
            for t = enumerate(varargin)
                arg = char(t.item);
                idx = strfind(arg, '=');
                assert(isscalar(idx)||isempty(idx));
                if isempty(idx)
                    key = arg;
                    value = [];
                else
                    key = arg(1:idx-1);
                    if isfile(arg(idx+1:end))
                        value = arg(idx+1:end); % keep value unchanged if argument is string for path
                    else
                        value = yamlread(arg(idx+1:end));
                    end
                end
                OmegaConf.update(self, key, value);
            end
        end
        function ret = get(self, key, default)
            arguments
                self
                key
                default = []
            end
            if ~iskey(self, key)
                ret = default;
            else
                ret = self.(key);
            end
        end
        function ret = to_struct(self)
            ret = struct();
            for t = enumerate(self.keys)
                key = t.item;
                if isa(self.(key), 'StructConfig')
                    ret.(key) = self.(key).to_struct();
                else
                    ret.(key) = copy(self.(key));
                end
            end
        end
        function c = unpack(s)
            c = cell(2*length(s.keys()), 1);
            c(1:2:end) = s.keys();
            c(2:2:end) = struct2cell(s.content);
        end
    end
    methods (Access=protected)
        function set_value(self, content)
            arguments
                self
                content {mustBeA(content, ["StructConfig", "struct"])}
            end
            if isa(content, 'StructConfig')
                keys = content.keys;
            else
                keys = fieldnames(content);
            end
            for t = enumerate(keys)
                key = t.item; value = content.(key);
                if isstruct(value)
                    value = StructConfig(value);
                end
                if self.iskey(key) && isa(self.(key), "StructConfig") && isa(value, "StructConfig")
                    self.(key).merge_with(value);
                else
                    self.(key) = value;
                end
            end
        end     
    end
    methods (Access=protected)
        function self = dotAssign(self, indexOp, varargin)
            if ~isempty(self.get_flag("readonly")) && self.get_flag("readonly")
                warning('The object of <StructConfig> is read-only!');
            else
                [self.content.(indexOp)] = varargin{:};
            end
        end
    end
end