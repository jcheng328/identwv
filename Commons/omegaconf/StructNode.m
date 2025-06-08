classdef  StructNode < handle 
    % node class, that stores meta info and pointer to its parent.
    % usage: 
    %   sn = StructNode()
    %   sn = StructNode(metadata, parent)
    %   
    %   sn.metadata (= metadata)
    %   sn.parent (= parent)
    %   sn.root
    % 
    %   sn.get_flag('flag_name')
    %   sn.set_flag('flag_name', true/false/[]) # [] if unset
    %   sn.is_flags_root
    %   sn.set_flags_root(true/false)
    properties (Access=public)
        metadata {mustBeA(metadata, "Metadata")} = Metadata
        parent {mustBeAorEmpty(parent, "StructNode")} = []
    end
    properties (Dependent)
        root
    end
    methods (Access=public)
        % constructor
        function obj = StructNode(metadata, parent)
            arguments
                metadata {mustBeA(metadata, "Metadata")} = Metadata
                parent {mustBeAorEmpty(parent, "StructNode")} = []
            end
            obj.metadata = metadata;
            obj.parent = parent;
        end
    end
    methods
        function obj = get.root(obj)
            while ~isempty(obj.parent)
                obj = obj.parent;
            end
        end
    end
    methods (Access=public)
        function ret = get_flag(self, flag)
            arguments (Input)
                self
                flag {mustBeTextScalar}
            end
            arguments (Output)
                ret {isscalar, mustBeAorEmpty(ret, "logical")}
            end
            if ~isfield(self.metadata.flags, flag) 
                if self.metadata.flags_root || isempty(self.parent)
                    ret = [];
                    return
                end
                ret = self.parent.get_flag(flag);
            else
                ret = self.metadata.flags.(flag);
            end
        end
        function set_flag(self, flags, values)
            arguments (Input)
                self
                flags {mustBeText}
                values {isscalar, mustBeAorEmpty(values, "logical")}
            end
            if ~iscellstr(flags) %#ok<ISCLSTR>
                flags = cellstr(flags);
            end
            if numel(values) == 1
                values = repmat(values, size(flags));
            end
            if ~isequal(size(flags), size(values))
                me = MException("StructNode:sizeError", "Inconsistent lengths of input flag names and values");
                throw(me);
            end
            for t = enumerate(flags)
                idx = t.num; flag = t.item;
                value = values(idx);
                if isempty(value)
                    if isfield(self.metadata.flags, flag)
                        self.metadata.flags = rmfield(self.metadata.flags, flag);
                    end
                else
                    self.metadata.flags = addfield(self.metadata.flags, flag, value);
                end
            end
        end
        function ret = is_flags_root(self)
            arguments (Output)
                ret {islogical, isscalar} 
            end
            ret = self.metadata.flags_root;
        end
        function set_flags_root(self, flags_root)
            arguments (Input)
                self
                flags_root {islogical, isscalar} 
            end
            self.metadata.flags_root = flags_root;
        end
    end
end

function s = addfield(s, key, value) 
    if isempty(s)
        s = struct([]);
    end
    assert(numel(s)<2);
    if isempty(s)
        s(1).(key) = value;
    else
        s.(key) = value;
    end
end