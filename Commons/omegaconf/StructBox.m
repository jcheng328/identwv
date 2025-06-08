classdef  StructBox < matlab.mixin.indexing.RedefinesDot & StructNode 
    % box class, that stores dynamic properties
    % usage:
    %     sb = StructBox
    %     sb.(key) (= value)
    %
    %     "metadata", "parent", "root" are protected field names.
    properties (Access=protected)
        content {isstruct} = struct()
    end
    methods (Access=public)
        function obj = StructBox(metadata, parent)
            arguments
                metadata = Metadata
                parent = []
            end
            obj = obj@StructNode(metadata, parent);
        end
        function re_parents(self)
            for t = enumerate(fieldnames(self.content))
                key = t.item;
                if isa(self.content.(key), 'StructBox')
                    self.content.(key).parent = self;
                    self.content.(key).re_parents();
                end
            end
        end
        function ret = iskey(self, key)
            ret = any(strcmp(self.keys,key));
        end
        function ret = keys(self)
            ret = fieldnames(self.content);
        end
        function ret = pop(self, key)
            ret = [];
            if isfield(self.content, key)
                ret = self.content.(key);
                self.content = rmfield(self.content, key);
            end
        end
    end

    methods (Access=protected)
        function varargout = dotReference(self, indexOp)
            [varargout{1:nargout}] = self.content.(indexOp);
        end

        function self = dotAssign(self, indexOp, varargin)
            [self.content.(indexOp)] = varargin{:};
        end
        
        function n = dotListLength(self, indexOp, indexContext)
            n = listLength(self.content, indexOp, indexContext);
        end
    end
end